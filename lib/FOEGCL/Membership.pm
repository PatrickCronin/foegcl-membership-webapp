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

    _set_up_report_routes($logged_in);
}

sub _set_up_report_routes($logged_in) {
    my $report = $logged_in->under('/report');
    $report->get('blast-email-list')->to('report#blast_email_list')
        ->name('blast_email_list');
    $report->get('contributing-friends')->to('report#contributing_friends')
        ->name('contributing_friends_report');
    $report->get('current-membership')->to('report#current_membership')
        ->name('current_membership_report');
}

1;

