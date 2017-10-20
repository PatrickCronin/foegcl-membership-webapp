package FOEGCL::Membership::Role::DumpsDBICSchema;

# ABSTRACT: Dump the DBIC Schema to disk

use FOEGCL::Membership::Moose::Role;

use DBIx::Class::Schema::Loader qw( make_schema_at );
use MooseX::Getopt::OptionTypeMap ();

use FOEGCL::Membership::Types qw( Bool HashRef Path );
use Path::Tiny qw( path );

has debug => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_debug',
);

has dry_run => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_dry_run',
);

has dump_directory => (
    is        => 'ro',
    isa       => Path,
    coerce    => 1,
    predicate => '_has_dump_directory',
);

has overwrite_modifications => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_overwrite_modifications',
);

has quiet => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_quiet',
);

has _db_config => (
    is      => 'ro',
    does    => 'FOEGCL::Membership::Role::ConfiguresDatabase',
    lazy    => 1,
    builder => '_build_db_config',
);

has _loader_options => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_loader_options',
);

has _command_line_options => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_command_line_options',
);

has _default_loader_options => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_default_loader_options',
);

requires qw( _build_db_config );

with 'MooseX::Getopt::Dashes';

sub _build_loader_options ( $self, @ ) {
    return {};
}

sub _build_command_line_options ( $self, @ ) {
    my %cmd_line_options;

    # Booleans
    for my $arg (qw( debug dry_run quiet overwrite_modifications )) {
        my $predicate_method = "_has_$arg";
        if ( $self->$predicate_method ) {
            warn sprintf(
                'Overwriting %s (%s) with %s from the command line.',
                $arg, $self->_loader_options->{$arg},
                $self->$arg
            ) if exists $self->_loader_options->{$arg};

            $cmd_line_options{$arg} = $self->$arg;
        }
    }

    # Files
    if ( $self->_has_dump_directory ) {
        warn sprintf(
            'Overwriting %s (%s) with %s from the command line.',
            'dump_directory', $self->_loader_options->{dump_directory},
            $self->dump_directory
        ) if exists $self->_loader_options->{dump_directory};
        $cmd_line_options{dump_directory} = $self->dump_directory->stringify;
    }

    return \%cmd_line_options;
}

sub _build_default_loader_options ( $self, @ ) {
    return {
        additional_classes => ['FOEGCL::Membership::perlbase'],
        components         => [
            qw(
              InflateColumn::DateTime
              InflateColumn::Serializer
              TimeStamp
              )
        ],
        debug                   => 0,
        default_resultset_class => 'ResultSet',
        dump_directory          => './lib',
        filter_generated_code   => sub { return "#<<<\n$_[2]#>>>" },
        generate_pod            => 1,
        naming                  => 'current',
        only_autoclean          => 1,
        overwrite_modifications => 0,
        preserve_case           => 1,
        quiet                   => 0,
        skip_load_external      => 1,
        use_namespaces          => 1,
    };
}

sub run ($self) {
    my $schema = make_schema_at(
        $self->_db_config->schema_class_name,
        {
            $self->_default_loader_options->%*, $self->_loader_options->%*,
            $self->_command_line_options->%*,
        },
        [ $self->_db_config->connect_info ],
    );
    $schema->storage->disconnect;
}

1;
