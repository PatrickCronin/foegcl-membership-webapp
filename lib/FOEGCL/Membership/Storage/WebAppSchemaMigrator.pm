package FOEGCL::Membership::Storage::WebAppSchemaMigrator;

# ABSTRACT: Create and/or update full copies of the database from the schema file and migrations

use FOEGCL::Membership::Moose;
extends 'Database::Migrator::Pg';

use DBI                                                         ();
use FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig ();
use FOEGCL::Membership::Types 'Bool';
use IO::Prompt::Tiny 'prompt';
use Try::Tiny 'try';

# Don't use the role here as we need the config available before creating
# object attributes
use FOEGCL::Membership::Config ();

has db_config => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig',
    lazy    => 1,
    default => sub {
        FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig->new;
    },
);

# Setup the attribute defaults for the WebApp database
for my $attr (qw( database host username password port )) {
    has "+$attr" => (
        lazy    => 1,
        default => sub { shift->db_config->$attr },
    );
}

# Create the attribute defaults for the migration
my $storage_dir = FOEGCL::Membership::Config->instance->storage_dir;
has '+migration_table' => ( default => sub { 'applied_migration' } );
has '+migrations_dir'  => ( builder => '_build_migrations_dir' );
has '+schema_file'     => (
    default => sub { $storage_dir->child('membership-webapp.sql')->stringify }
);

# Other attribute modifications
has '+dbh'     => ( clearer => '_clear_dbh' );
has '+verbose' => ( default => 1 );

# Allow the schema to be dropped first
has drop_first => (
    is            => 'ro',
    isa           => Bool,
    default       => 0,
    documentation => 'whether or not the database should be dropped first',
);

sub DEMOLISH ( $self, @ ) {
    $self->clear_connection;
}

sub _build_dbh ( $self, @ ) {
    my $dbh = DBI->connect( $self->db_config->connect_info->@[ 0 .. 3 ] )
        or die DBI->errstr;
    $dbh->do('SET CLIENT_MIN_MESSAGES = NOTICE');

    return $dbh;
}

sub _build_migrations_dir ( $self, @ ) {
    my $migrations_dir = $storage_dir->child('migrations');
    $migrations_dir->mkpath if !$migrations_dir->exists;
    return $migrations_dir->stringify;
}

around 'create_or_update_database' => sub ( $orig, $self, @args ) {
    if ( $self->drop_first ) {
        my $answer;
        do {
            $answer = prompt(
                'Are you sure you want to drop the existing database?', 'n' );
        } while $answer !~ m/\A (?:y(?:es)?|no?)  \z/ix;

        $self->_drop_database if $answer =~ m/\A y(?:es)? \z/ix;
    }

    $self->$orig(@args);
};

sub copy_to ( $self, $to ) {
    $self->dbh->do(<<"SQL") or die $self->dbh->errstr;
        CREATE DATABASE @{[ $to ]}
        WITH TEMPLATE @{[ $self->database ]}
        OWNER @{[ $self->username ]}
SQL
}

sub database_exists ($self) {

    # SUPER has _database_exists as an attribute
    # We don't want stale information
    $self->_build_database_exists;
}

sub drop_database ($self) {
    if ( $self->database_exists ) {
        $self->terminate_all_other_connections;
        $self->clear_connection;
        $self->_drop_database;
    }
}

sub terminate_all_other_connections ($self) {
    $self->dbh->do(
        <<'SQL', undef, $self->database ) or die $self->dbh->errstr;
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE pid <> pg_backend_pid()
        AND datname = ?
SQL
}

sub get_connections ($self) {
    $self->dbh->selectall_arrayref(
        <<'SQL', { Slice => {} }, $self->database ) or die $self->dbh->errstr;
        SELECT pid, pg_backend_pid() as my_pid, datname, state, query
        FROM pg_stat_activity
        WHERE pid <> pg_backend_pid()
        AND datname = ?
SQL
}

sub clear_connection ($self) {
    $self->_maybe_disconnect;
    $self->_clear_dbh;
}

sub _maybe_disconnect ( $self ) {
    $self->dbh->disconnect if $self->_is_connected;
}

sub _is_connected ( $self ) {
    return try { $self->dbh && $self->dbh->ping; 1; } || 0;
}

__PACKAGE__->meta->make_immutable;

1;
