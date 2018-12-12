package FOEGCL::Membership::Storage::LegacyDatabaseConnection;

# ABSTRACT: Contains a schema and connection handle for a copy of the Legacy DB

use FOEGCL::Membership::Moose;

use Const::Fast 'const';
use FOEGCL::Membership::Storage::LegacyDatabaseConnectionConfig ();
use FOEGCL::Membership::Types
    qw( HashRef Maybe NonEmptySimpleStr PortNumber );
use Module::Runtime 'require_module';

has db_config => (
    is      => 'ro',
    does    => 'FOEGCL::Membership::Role::ConfiguresDatabaseConnection',
    lazy    => 1,
    default => sub {
        FOEGCL::Membership::Storage::LegacyDatabaseConnectionConfig->new;
    },
);

has schema => (
    init_arg => undef,
    is       => 'ro',
    isa      => 'DBIx::Class::Schema',
    lazy     => 1,
    builder  => '_build_schema',
    clearer  => '_clear_schema',
);

has dbh => (
    init_arg => undef,
    is       => 'ro',
    isa      => 'DBI::db',
    lazy     => 1,
    builder  => '_build_dbh',
    clearer  => '_clear_dbh',
);

with 'FOEGCL::Membership::Role::Singleton';

sub _build_schema ( $self, @ ) {
    my $class = $self->db_config->schema_class_name;
    require_module $class;

    return $class->connect( $self->db_config->connect_info->@* );
}

sub _build_dbh ( $self, @ ) {
    return $self->schema->storage->dbh;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
