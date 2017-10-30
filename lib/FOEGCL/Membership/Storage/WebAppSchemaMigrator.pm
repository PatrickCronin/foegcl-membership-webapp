package FOEGCL::Membership::Storage::WebAppSchemaMigrator;

# ABSTRACT: Create and/or update full copies of the database from the schema file

use FOEGCL::Membership::Moose;
extends 'Database::Migrator::Pg';

use DBI                                        ();
use FOEGCL::Membership::Config::WebAppDatabase ();
use FOEGCL::Membership::Types qw(Bool);
use IO::Prompt qw(prompt);

# Don't use the role here as we need the config available before creating
# object attributes
use FOEGCL::Membership::Config ();

# Create the attribute defaults for the WebApp database
my $db_config = FOEGCL::Membership::Config::WebAppDatabase->instance;
for my $attr (qw( database host username password port )) {
    has "+$attr" => ( default => sub { $db_config->$attr } );
}

# Create the attribute defaults for the migration
my $storage_dir = FOEGCL::Membership::Config->instance->storage_dir;
has '+migration_table' => ( default => sub { 'applied_migration' } );
has '+migrations_dir' =>
    ( default => sub { $storage_dir->child('migrations')->stringify } );
has '+schema_file' => (
    default => sub { $storage_dir->child('membership-webapp.sql')->stringify }
);

has 'drop_first' => (
    is => 'ro',
    isa => Bool,
    default => 0,
);

has '+dbh' => ( clearer => '_clear_dbh' );

sub _build_dbh {
    my ( $dsn, $username, $password, $dbi_attributes, $extra_attributes )
        = $db_config->connect_info;

    $dbi_attributes->{$_} = 1
        for qw( RaiseError PrintError PrintWarn ShowErrorStatement );

    my $dbh = DBI->connect( $dsn, $username, $password, $dbi_attributes );

    $dbh->do('SET CLIENT_MIN_MESSAGES = ERROR');

    return $dbh;
}

around 'create_or_update_database' => sub ( $orig, $self, @args ) {
    if ($self->drop_first) {
        $self->drop_database if prompt(
            'Are you sure you want to drop the existing database? ',
            -default => 'n',
            -until => qr/yn/i,
            -yn,
        );
    }

    $self->$orig(@args);
};

sub drop_database ($self) {
    $self->_maybe_disconnect;
    $self->_clear_dbh;
    $self->_drop_database;
}

sub _maybe_disconnect ( $self ) {
    $self->dbh->disconnect if $self->dbh && $self->dbh->ping;
}

__PACKAGE__->meta->make_immutable;

1;
