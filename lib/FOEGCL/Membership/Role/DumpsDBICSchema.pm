package FOEGCL::Membership::Role::DumpsDBICSchema;

# ABSTRACT: Dump the DBIC Schema to disk

use FOEGCL::Membership::Moose::Role;

use Const::Fast qw( const );
use DBIx::Class::Schema::Loader qw( make_schema_at );
use MooseX::Getopt::OptionTypeMap ();

use FOEGCL::Membership::Types qw( Bool HashRef Path );
use Path::Tiny qw( path );

const my %ARG_CONSTANT => (
    debug => 0,
    dump_directory => './lib',
    dry_run => 0,
    overwrite_modifications => 0,
    quiet => 1,
);

has debug => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_debug',
    documentation => "Whether or not debug messages should be displayed. Defaults to $ARG_CONSTANT{debug}.",
);

has dry_run => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_dry_run',
    documentation => qq{If true, don't actually write out the generated files. Defaults to $ARG_CONSTANT{dry_run}.},
);

has dump_directory => (
    is        => 'ro',
    isa       => Path,
    coerce    => 1,
    predicate => '_has_dump_directory',
    documentation => "The Schema root directory within which the Result and ResultSet classes will be dumped. Defaults to $ARG_CONSTANT{dump_directory}.",
);

has overwrite_modifications => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_overwrite_modifications',
    documentation => "Whether or not to update manually-modified files. Defaults to $ARG_CONSTANT{overwrite_modifications}.",
);

has quiet => (
    is        => 'ro',
    isa       => Bool,
    predicate => '_has_quiet',
    documentation => "Whether or not to print status messages. Defaults to $ARG_CONSTANT{quiet}.",
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

# Should be overridden by consuming classes
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
        debug                   => $ARG_CONSTANT{debug},
        default_resultset_class => 'ResultSet',
        dry_run                 => $ARG_CONSTANT{dry_run},
        dump_directory          => $ARG_CONSTANT{dump_directory},
        filter_generated_code   => sub { return "#<<<\n$_[2]#>>>" },
        generate_pod            => 1,
        naming                  => 'current',
        only_autoclean          => 1,
        overwrite_modifications => $ARG_CONSTANT{overwrite_modifications},
        preserve_case           => 1,
        quiet                   => $ARG_CONSTANT{quiet},
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
