package TestForWebApp::Login;

use FOEGCL::Membership::Test::Class::Moose;

use HTTP::Status qw(HTTP_FOUND HTTP_OK HTTP_UNAUTHORIZED);
use TestHelper::WebApp qw( create_webapp_user t url_for );

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub test_login ( $self, @ ) {
    my ( $username, $password ) = create_webapp_user( $self->_schema );
    my $t = t();

    # Load login page
    my $login_form_url = url_for( $t, 'login_form' );
    $t->get_ok($login_form_url)->status_is(HTTP_OK)
        ->element_exists('form input[name="username"]')
        ->element_exists('form input[name="password"]')
        ->element_exists('form input[type="submit"]');

    # Login fails
    $t->post_ok(
        $login_form_url => form => {
            username => 'not a user',
            password => 'invalid'
        }
    )->status_is(HTTP_UNAUTHORIZED)->header_is( Location => undef )
        ->content_like(qr/Login failed[.]/);

    # Login succeeds
    $t->post_ok(
        $login_form_url => form => {
            username => $username,
            password => $password,
        }
    )->status_is(HTTP_FOUND)->header_is( Location => '/dashboard' );

    # Logout succeeds
    $t->ua->max_redirects(1);
    $t->get_ok('/logout')->status_is(HTTP_OK)
        ->content_like(qr/logged out successfully/);
}

__PACKAGE__->meta->make_immutable;

1;
