package TestForWebApp::Reports;

use FOEGCL::Membership::Test::Class::Moose;

use HTTP::Status 'HTTP_OK';
use TestHelper::WebApp qw( create_webapp_user login t url_for );

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub test_reports ( $self, @ ) {
    my ( $username, $password ) = create_webapp_user( $self->_schema );
    my $t = t();
    login( $t, $username, $password );

    my %report = (

        # route name => anchor text
        'contributing_friends_report' => 'Contributing Friends',
        'current_membership_report'   => 'Current Membership',
    );

    my $dashboard = url_for( $t, 'dashboard' );
    foreach my $route ( keys %report ) {
        $t->get_ok($dashboard)->status_is(HTTP_OK);

        my $url = url_for( $t, $route );
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

__PACKAGE__->meta->make_immutable;

1;
