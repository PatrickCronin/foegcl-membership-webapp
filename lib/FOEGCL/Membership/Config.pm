package FOEGCL::Membership::Config;

# ABSTRACT: A system configuration singleton

use FOEGCL::Membership::Moose;

use Config::INI::Reader ();
use FOEGCL::Membership::Types qw( HashRef Path );
use List::Util 'first';
use Path::Tiny 'path';

#
# Paths
#
has project_root => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    default => sub { path(__FILE__)->parent(4) },
);

has storage_dir => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    default => sub ($self) { $self->project_root->child('storage') },
);

has website_dir => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    default => sub ($self) { $self->project_root->child('website') },
);

#
# File-based config
#
has _config_file => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    builder => '_build_config_file',
);

has _config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_config',
);

#
# DB config
#
has webapp_database_config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_webapp_database_config',
);

has legacy_database_config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_legacy_database_config',
);

#
# Misc
#
has webapp_config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_webapp_config',
);

with 'FOEGCL::Membership::Role::Singleton';

sub _build_config_file ( $self, @ ) {
    my @prioritized_paths = (
        $self->project_root->child( 'etc', 'foegcl-membership.conf' ),
        Path::Tiny::rootdir->child( 'etc', 'foegcl-membership.conf' ),
    );

    my $path = first { $_->exists } @prioritized_paths;
    die "Could not find a configuration file!\n" if !$path;
    return $path;
}

sub _build_config ( $self, @ ) {
    return Config::INI::Reader->read_file( $self->_config_file );
}

sub _build_webapp_database_config ( $self, @ ) {
    my $config = $self->_config->{'WebApp Database'};
    $self->_ensure_all_truthy( 'WebApp DB', $config );
    return $config;
}

sub _build_legacy_database_config ( $self, @ ) {
    my $config = $self->_config->{'Legacy Database'};
    $self->_ensure_all_truthy( 'Legacy DB', $config );
    return $config;
}

sub _build_webapp_config ( $self, @ ) {
    my $config = $self->_config->{'WebApp'};
    $self->_ensure_all_truthy( 'WebApp', $config );
    return $config;
}

sub _ensure_all_truthy ( $self, $type, $config ) {
    for my $key ( keys %$config ) {
        die "Could not find a value for the $type Config key $key!\n"
            if !$config->{$key};
    }
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
