package FOEGCL::Membership::Storage::WebAppSchemaMigrator;

# ABSTRACT: Create and/or update full copies of the database from the schema file

use FOEGCL::Membership::Moose;
extends 'Database::Migrator::Pg';

use DBI                                        ();
use FOEGCL::Membership::Config::WebAppDatabase ();

# Don't use the role here as we need the config available before creating
# object attributes
use FOEGCL::Membership::Config ();

# Create the attribute defaults for the WebApp database connect_info
my $connect_info =
  FOEGCL::Membership::Config::WebAppDatabase->instance->connect_info;
for my $attr (qw( database host username password port )) {
    has "+$attr" => ( default => $connect_info->$attr );
}

# Create the attribute defaults for the migration
my $config = FOEGCL::Membership::Config->instance->config;
has '+migration_table' => ( default => 'applied_migration' );
has '+migrations_dir'
    => ( default => $config->storage_dir->child('migrations') );
has '+schema_file'
    => ( default => $config->storage_dir->child('membership-webapp.sql') );

sub _build_dbh {
    my ( $dsn, $username, $password, $dbi_attributes, $extra_attributes ) =
      $db_config->connect_info;

    $dbi_attributes->{$_} = 1
      for qw( RaiseError PrintError PrintWarn ShowErrorStatement );

    my $dbh = DBI->connect( $dsn, $username, $password, $dbi_attributes );

    $dbh->do('SET CLIENT_MIN_MESSAGES = ERROR');

    return $dbh;
}

sub drop_database ($self) {
    $self->_maybe_disconnect;
    $self->_drop_database;
}

sub _maybe_disconnect ( $self ) {
    $self->dbh->disconnect if $self->dbh && $self->dbh->ping;
}

__PACKAGE__->meta->make_immutable;

1;
