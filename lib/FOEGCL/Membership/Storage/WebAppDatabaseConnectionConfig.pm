package FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig;

# ABSTRACT: Contains all config necessary to connect to a copy of the WebApp DB

use FOEGCL::Membership::Moose;

use Const::Fast 'const';
use FOEGCL::Membership::Types
    qw( HashRef Maybe NonEmptySimpleStr PortNumber );

has dsn => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    default => sub ($self) {
        sprintf(
            'dbi:Pg:dbname=%s;host=%s;port=%s',
            $self->database,
            $self->host,
            $self->port,
        );
    },
);

has host => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    default => sub ($self) { $self->_cfg->{host} },
);

has port => (
    is      => 'ro',
    isa     => PortNumber,
    lazy    => 1,
    default => sub ($self) { $self->_cfg->{port} },
);

has username => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    default => sub ($self) { $self->_cfg->{username} },
);

has password => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    default => sub ($self) { $self->_cfg->{password} },
);

has database => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    default => sub ($self) { $self->_cfg->{database} },
);

has _cfg => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    default => sub ($self) { $self->_config->webapp_database_config },
);

with qw(
    FOEGCL::Membership::Role::ConfiguresDatabaseConnection
    FOEGCL::Membership::Role::HasConfig
);

const my $SCHEMA_CLASS_NAME => 'FOEGCL::Membership::Schema::WebApp';

sub dbi_attributes ( $self, @ ) {
    +{
        AutoCommit         => 1,
        RaiseError         => 1,
        PrintError         => 1,
        PrintWarn          => 1,
        ShowErrorStatement => 1,
        quote_char         => q{"},
        name_sep           => q{.},
    };
}

# Useful for when connecting directly to a schema object; not for DBI directly
sub extra_attributes { +{} }

sub schema_class_name { $SCHEMA_CLASS_NAME }

__PACKAGE__->meta->make_immutable;

1;
