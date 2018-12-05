package TestForWebApp::Reports;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Util::Password;
use HTTP::Status qw(HTTP_OK);
use Mojo::DOM ();
use Test::Mojo;

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub test_reports ( $self, @ ) {
    my $t = $self->_start_app_and_login;

    my %report = (

        # route name => anchor text
        'contributing_friends_report' => 'Contributing Friends',
        'current_membership_report'   => 'Current Membership',
    );

    my $dashboard = _url_for( $t, 'dashboard' );
    foreach my $route ( keys %report ) {

        $t->get_ok($dashboard)->status_is(HTTP_OK);

        my $url = _url_for( $t, $route );
        $t->text_is(
            "li > a[href=$url]" => $report{$route},
            "$report{$route} is listed as a link to $url"
        );

        $t->get_ok($url)->status_is(HTTP_OK)
            ->header_is( 'Content-Type' => 'application/pdf' )
            ->header_like(
            'Content-Disposition' => qr/^attachment; filename="[^"]*"$/ );
    }
}

sub _start_app_and_login ( $self, @ ) {

    # Create a user to login as
    $self->_schema->resultset('AppUser')->create(
        {
            username => 'testuser',
            password_hash =>
                FOEGCL::Membership::Util::Password->new->hash_password(
                'the_password'),
            first_name => 'Test',
            last_name  => 'User',
        }
    );

    # Start the app and login
    my $t = Test::Mojo->new('FOEGCL::Membership');

    $t->get_ok( _url_for( $t, 'login_form' ) )->status_is(HTTP_OK)
        ->element_exists('form input[name="username"]')
        ->element_exists('form input[name="password"]')
        ->element_exists('form input[type="submit"]');

    $t->ua->max_redirects(1);
    $t->post_ok(
        '/' => form => { username => 'testuser', password => 'the_password' }
    )->status_is(HTTP_OK)->text_is( 'div.alert-success' => 'Welcome!' );

    return $t;
}

sub _url_for ( $t, $route_name ) {
    $t->app->routes->lookup($route_name)->render;
}

__PACKAGE__->meta->make_immutable;

1;
