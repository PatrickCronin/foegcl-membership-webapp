package FOEGCL::Membership::Role::UsesLegacyDatabase;

# ABSTRACT: Provides the Legacy database connection

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Storage::LegacyDatabaseConnection ();

sub _legacy_cxn;
sub _legacy_db_config;
sub _legacy_dbh;
sub _legacy_schema;
has _legacy_cxn => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Storage::LegacyDatabaseConnection',
    lazy    => 1,
    default => sub {
        FOEGCL::Membership::Storage::LegacyDatabaseConnection->instance;
    },
    handles => {
        _legach_db_config => 'db_config',
        _legacy_dbh       => 'dbh',
        _legacy_schema    => 'schema',
    },
);

1;
