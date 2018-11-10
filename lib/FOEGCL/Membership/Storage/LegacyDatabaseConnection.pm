package FOEGCL::Membership::Storage::LegacyDatabaseConnection;

# ABSTRACT: Contains a schema and connection handle for a copy of the Legacy DB

use FOEGCL::Membership::Moose;

use Const::Fast 'const';
use FOEGCL::Membership::Types
    qw( HashRef Maybe NonEmptySimpleStr PortNumber );

has db_config => (
    is      => 'ro',
    does    => 'ConfiguresDatabaseConnection',
    required => 1,
);

has schema => (
    init_arg => undef,
    is      => 'ro',
    isa     => 'DBIx::Class::Schema',
    lazy    => 1,
    builder => '_build_schema',
    clearer => '_clear_schema',
);

has dbh => (
    init_arg => undef,
    is      => 'ro',
    isa     => 'DBI::db',
    lazy    => 1,
    builder => '_build_dbh',
    clearer => '_clear_dbh',
);

sub _build_schema ( $self, @ ) {
    return $SCHEMA_CLASS_NAME->connect(
        $self->db_config->connect_info->@*
    );
}

sub _build_dbh ( $self, @ ) {
    return $self->schema->storage->dbh;
}

__PACKAGE__->meta->make_immutable;

1;
