package FOEGCL::Membership::Role::HasSchema;

# ABSTRACT: Provides the WebApp schema to Moose objects

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Schema::WebApp ();
use FOEGCL::Membership::Config::WebAppDatabase ();

has _schema => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Schema::WebApp',
    lazy    => 1,
    builder => '_build_schema',
);

sub _build_schema ( $self, @ ) {
    return FOEGCL::Membership::Schema::WebApp->connect(
        FOEGCL::Membership::Config::WebAppDatabase->instance->connect_info );
}

1;
