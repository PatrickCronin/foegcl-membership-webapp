package FOEGCL::Membership::Role::HasConfig;

# ABSTRACT: Enable easy access to the config object for Moose objects

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Config;

has _config => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Config',
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config ( $self, @ ) {
    return FOEGCL::Membership::Config->instance;
}

1;
