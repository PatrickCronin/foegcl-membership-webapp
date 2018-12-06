package TestHelper::WebApp;

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Util::Password ();
use HTTP::Status 'HTTP_OK';
use Sub::Exporter -setup => {
    exports => [
        qw(
            create_webapp_user
            login
            t
            url_for
            )
    ]
};
use Test::Mojo;

sub t { Test::Mojo->new('FOEGCL::Membership') }

sub create_webapp_user ( $schema, $username = 'testuser' ) {

    # Create a user to login as
    my $password = 'testpassword';

    $schema->resultset('AppUser')->create(
        {
            username => $username,
            password_hash =>
                FOEGCL::Membership::Util::Password->new->hash_password(
                $password),
            first_name => 'Test',
            last_name  => 'User',
        }
    );

    return ( $username, $password );
}

sub login ( $t, $username, $password ) {
    $t->get_ok( url_for( $t, 'login_form' ) )->status_is(HTTP_OK);

    my $saved = $t->ua->max_redirects;
    $t->ua->max_redirects(1);
    $t->post_ok(
        url_for( $t, 'login_form' ) => form => {
            username => $username,
            password => $password
        }
    )->status_is(HTTP_OK)->text_is( 'div.alert-success' => 'Welcome!' );
    $t->ua->max_redirects($saved);
}

sub url_for ( $t, $route_name, @render_args ) {
    $t->app->routes->lookup($route_name)->render(@render_args);
}

1;
