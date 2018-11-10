package FOEGCL::Membership::Role::UsesWebAppDatabase;

# ABSTRACT: Provides the "current" WebApp database connection

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Storage::WebAppDatabaseConnection      ();
use FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache ();

sub _cxn;
sub _db_config;
sub _dbh;
sub _schema;
sub _defer_constraints;
sub _restore_constraints;
has _cxn => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Storage::WebAppDatabaseConnection',
    lazy    => 1,
    builder => '_build_cxn',
    handles => {
        _db_config           => 'db_config',
        _dbh                 => 'dbh',
        _schema              => 'schema',
        _defer_constraints   => 'defer_constraints',
        _restore_constraints => 'restore_constraints',
    },
    clearer => 'reset_connection',    # supports per-test-method databases
);

sub _build_cxn ( $self, @ ) {
    my $cache = FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache
        ->instance;

    my $current = $cache->get_current;
    return $current if $current;

    my $default = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new;
    $cache->set( $default->db_config->database, $default );
    $cache->set_current( $default->db_config->database );

    return $default;
}

1;
