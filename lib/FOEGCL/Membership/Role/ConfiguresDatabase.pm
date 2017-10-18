package FOEGCL::Membership::Role::ConfiguresDatabase;

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Types qw( HashRef Maybe NonEmptySimpleStr PackageName );

has dsn => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    builder => '_build_dsn',
);

has username => (
    is      => 'ro',
    isa     => Maybe[ NonEmptySimpleStr ], # allow undef
    lazy    => 1,
    builder => '_build_username',
);

has password => (
    is      => 'ro',
    isa     => Maybe[ NonEmptySimpleStr ], # allow undef
    lazy    => 1,
    builder => '_build_password',
);

has dbi_attributes => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_dbi_attributes',
);

has extra_attributes => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_extra_attributes',
);

has schema_class_name => (
    is => 'ro',
    isa => PackageName,
    lazy => 1,
    builder => '_build_schema_class_name'
);

requires qw( _build_dsn _build_schema_class_name );

with 'FOEGCL::Membership::Role::Singleton';

sub _build_username ( $self, @ ) {
    return undef;
}

sub _build_password ( $self, @ ) {
    return undef;
}

sub _build_dbi_attributes ( $self, @ ) {
    return {};
}

sub _build_extra_attributes ( $self, @ ) {
    return {};
}

sub connect_info ($self) {
    return ( $self->dsn, $self->username, $self->password,
        $self->dbi_attributes, $self->extra_attributes);
}

1;
