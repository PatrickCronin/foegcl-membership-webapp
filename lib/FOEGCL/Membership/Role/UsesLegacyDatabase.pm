package FOEGCL::Membership::Role::UsesLegacyDatabase;

# ABSTRACT: Facilitates Legacy database access

use FOEGCL::Membership::Moose::Role;

use English qw(-no_match_vars);
use FOEGCL::Membership::Schema::Legacy                    ();
use FOEGCL::Membership::Storage::LegacyDatabaseConnection ();

has _legacy_schema => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Schema::Legacy',
    lazy    => 1,
    builder => '_build_legacy_schema',
);

has _legacy_dbh => (
    is      => 'ro',
    isa     => 'DBI::db',
    lazy    => 1,
    builder => '_build_legacy_dbh',
);

sub _build_legacy_schema ( $self, @ ) {
    die q{Can't access Legacy schema unless on Windows}
        if $OSNAME !~ m/MSWin32/;

    return FOEGCL::Membership::Schema::Legacy->connect(
        FOEGCL::Membership::Storage::LegacyDatabaseConnection->new->db_config
            ->connect_info->@* );
}

sub _build_legacy_dbh ( $self, @ ) {
    return $self->_legacy_schema->storage->dbh;
}

1;
