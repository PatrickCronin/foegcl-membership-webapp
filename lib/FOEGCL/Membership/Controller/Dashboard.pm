package FOEGCL::Membership::Controller::Dashboard;

use FOEGCL::Membership::Moose::Mojo;

extends 'Mojolicious::Controller';

sub dashboard ($self) {
    $self->render;
}

1;
