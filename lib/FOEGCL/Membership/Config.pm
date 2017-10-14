package FOEGCL::Membership::Config;

# ABSTRACT: A system configuration singleton class

use MooseX::Singleton;

use Config::INI::Reader ();
use MooseX::Types::Path::Tiny qw( Path );
use Path::Tiny qw( path );

has config_file => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    builder => '_build_config_file',
);

has legacy_database => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_legacy_database',
);

has migrator => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_migrator',
);

has webapp_database => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_webapp_database',
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

sub _build_legacy_database ( $self, @ ) {
    return $self->_config->{'Legacy Database'};
}

sub _build_migrator ( $self, @ ) {
    return $self->_config->{'Migrator'};
}

sub _build_webapp_database ( $self, @ ) {
    return $self->_config->{'WebApp Database Production'}
      if !$ENV{HARNESS_ACTIVE};

    my $test_database_config = {
        map {
                $_ => $_ eq 'database'
              ? $self->_config->{'WebApp Database Testing'}->{$_} . q{_}
              . time() . q{_}
              . $$
              : $self->_config->{'WebApp Database Testing'}->{$_}
          }
          keys $self->_config->{'WebApp Database Testing'}->%*
    };

    return $test_database_config;
}

sub _build_config ( $self, @ ) {
    return Config::INI::Reader->read_file( $self->config_file );
}

__PACKAGE__->meta->make_immutable;

1;
