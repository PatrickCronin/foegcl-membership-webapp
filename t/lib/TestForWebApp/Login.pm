package TestForWebApp::Login;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Util::Password;
use HTTP::Status qw(HTTP_FOUND HTTP_OK HTTP_UNAUTHORIZED);
use Test::Mojo;

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub test_login ( $self, @ ) {
    my $t = Test::Mojo->new('FOEGCL::Membership');

    # Load login page
    $t->get_ok('/')->status_is(HTTP_OK)
        ->element_exists('form input[name="username"]')
        ->element_exists('form input[name="password"]')
        ->element_exists('form input[type="submit"]');

    # Login fails
    $t->post_ok(
        '/' => form => { username => 'not a user', password => 'invalid' } )
        ->status_is(HTTP_UNAUTHORIZED)->header_is( Location => undef )
        ->content_like(qr/Login failed[.]/);

    # Login succeeds
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
    $t->post_ok(
        '/' => form => { username => 'testuser', password => 'the_password' }
    )->status_is(HTTP_FOUND)->header_is( Location => '/dashboard' );

    # Logout succeeds
    $t->ua->max_redirects(1);
    $t->get_ok('/logout')->status_is(HTTP_OK)
        ->content_like(qr/logged out successfully/);
}

__PACKAGE__->meta->make_immutable;

1;
