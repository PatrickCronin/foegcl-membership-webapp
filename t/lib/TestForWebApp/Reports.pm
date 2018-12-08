package TestForWebApp::Reports;

use FOEGCL::Membership::Test::Class::Moose;

use HTTP::Status 'HTTP_OK';
use TestHelper::WebApp qw( create_webapp_user login t url_for );

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub _is_pdf_report ($t) {
    $t->status_is(HTTP_OK)->header_is( 'Content-Type' => 'application/pdf' )
        ->header_like(
        'Content-Disposition' => qr/^attachment; filename="[^"]*"$/ );
}

sub _is_text_report ($t) {
    $t->status_is(HTTP_OK)
        ->header_is( 'Content-Type' => 'text/plain; charset=utf-8' )
        ->header_like(
        'Content-Disposition' => qr/^attachment; filename="[^"]*"$/ );
}

my %verify = (
    pdf  => \&_is_pdf_report,
    text => \&_is_text_report,
);

sub test_reports ( $self, @ ) {
    my ( $username, $password ) = create_webapp_user( $self->_schema );
    my $t = t();
    login( $t, $username, $password );

    my %report = (
        'blast_email_list' => {
            anchor_text => 'Blast Email List',
            type        => 'text',
        },
        'contributing_friends_report' => {
            anchor_text => 'Contributing Friends',
            type        => 'pdf',
        },
        'current_membership_report' => {
            anchor_text => 'Current Membership',
            type        => 'pdf',
        },
    );

    my $dashboard = url_for( $t, 'dashboard' );
    foreach my $route ( keys %report ) {
        $t->get_ok($dashboard)->status_is(HTTP_OK);

        my $url = url_for( $t, $route );
        $t->text_is(
            "li > a[href=$url]" => $report{$route}{anchor_text},
            "$report{$route}{anchor_text} is listed as a link to $url"
        );

        $t->get_ok($url);
        $verify{ $report{$route}{type} }->($t);
    }
}

__PACKAGE__->meta->make_immutable;

1;
