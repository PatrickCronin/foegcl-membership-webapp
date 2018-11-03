package FOEGCL::Membership::Role::ConfiguresDatabaseConnection;

# ABSTRACT: Interface for Database Connection Config objects

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Types 'ArrayRef';

has connect_info => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    default => sub ($self) {
        [
            $self->dsn,
            $self->username,
            $self->password,
            $self->dbi_attributes,
            $self->extra_attributes,
        ]
    },
);

requires qw(
    dsn
    username
    password
    dbi_attributes
    extra_attributes
    schema_class_name
);

1;
