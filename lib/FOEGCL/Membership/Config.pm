package FOEGCL::Membership::Config;

# ABSTRACT: A system configuration singleton

use FOEGCL::Membership::Moose;

use Config::INI::Reader ();
use FOEGCL::Membership::Types qw( HashRef Path );
use Path::Tiny qw( path );

has config_file => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    builder => '_build_config_file',
);

has _config => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config_file ( $self, @ ) {
    return path(__FILE__)
      ->parent->parent->parent->parent->child( 'etc',
        'foegcl-membership.conf' );
}

with 'FOEGCL::Membership::Role::Singleton';

}

sub _build_config ( $self, @ ) {
    return Config::INI::Reader->read_file( $self->config_file );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
