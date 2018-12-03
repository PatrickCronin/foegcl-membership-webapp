package FOEGCL::Membership;

use FOEGCL::Membership::Moose::Mojo;

extends 'Mojolicious';

with 'FOEGCL::Membership::Role::HasConfig';

sub startup {
    my $self = shift;

    $self->secrets( [ $self->_config->webapp_config->{session_key} ] );

    # Set the path to the templates and static assets
    splice $self->renderer->paths->@*, 0, scalar $self->renderer->paths->@*,
        $self->_config->website_dir->child('templates')->stringify;
    splice $self->static->paths->@*, 0, scalar $self->static->paths->@*,
        $self->_config->website_dir->child('static')->stringify;

    # Add our own plugin namespace and load our notification plugin
    push $self->plugins->namespaces->@*, 'FOEGCL::Membership::Mojo::Plugins';
    $self->plugins->register_plugin(
        'FOEGCL::Membership::Mojo::Plugin::NotificationHelpers', $self );

    my $r = $self->routes;
    $r->get('/')->to('login#login_form')->name('login_form');
    $r->post('/')->to('login#login_form')->name('login_form');
    $r->get('/logout')->to('login#logout');

    my $logged_in = $r->under('/')->to('login#logged_in');
    $logged_in->get('/dashboard')->to('dashboard#dashboard');
}

1;

