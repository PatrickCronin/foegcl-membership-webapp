package FOEGCL::Membership::Config;

# ABSTRACT: A system configuration singleton

use FOEGCL::Membership::Moose;

use Config::INI::Reader ();
use FOEGCL::Membership::Types qw( HashRef Path );
use List::Util 'first';
use Path::Tiny 'path';

has _dist_root => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    default => sub { path(__FILE__)->parent(4) },
);

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

has storage_dir => (
    is      => 'ro',
    isa     => Path,
    lazy    => 1,
    builder => '_build_storage_dir',
);

with 'FOEGCL::Membership::Role::Singleton';

sub _build_config_file ( $self, @ ) {
    my @prioritized_paths = (
        $self->_dist_root->child( 'etc', 'foegcl-membership.conf' ),
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

sub _ensure_all_truthy ( $self, $type, $config ) {
    for my $key ( keys %$config ) {
        die "Could not find a value for the $type Config key $key!\n"
            if !$config->{$key};
    }
}

sub _build_storage_dir ( $self, @ ) {
    return $self->_dist_root->child('storage');
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
