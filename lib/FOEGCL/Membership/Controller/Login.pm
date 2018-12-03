package FOEGCL::Membership::Controller::Login;

use FOEGCL::Membership::Moose::Mojo;

use FOEGCL::Membership::Util::Password;
use HTTP::Status 'HTTP_UNAUTHORIZED';

extends 'Mojolicious::Controller';

sub login_form ($self) {
    return $self->redirect_to('dashboard')
        if $self->session('username');

    # Only check POST params
    my $username = $self->req->body_params->param('username');
    my $password = $self->req->body_params->param('password');

    return $self->render
        if !defined $username && !defined $password;

    my $crypt = FOEGCL::Membership::Util::Password->new();
    if ( !$crypt->check_password( $username // q{}, $password // q{} ) ) {
        $self->add_stash_error(
            'Login failed. The username and/or password is not correct.');
        return $self->render( status => HTTP_UNAUTHORIZED );
    }

    $self->session( username => $username );
    $self->add_flash_success('Welcome!');
    $self->redirect_to('dashboard');
}

sub logged_in ($self) {
    return 1 if $self->session('username');
    $self->redirect_to('login_form');
    return undef;
}

sub logout ($self) {
    $self->session( expires => 1 );
    my $logout_url = $self->url_for('login_form')->query( logged_out => 1 );
    $self->redirect_to($logout_url);
}

1;
