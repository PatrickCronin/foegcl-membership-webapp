package TestRole::ManageDB;

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Const qw(
    $STANDARD_TEST_DB_NAME
    $ETL_TEST_DB_NAME
);
use FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache ();
use FOEGCL::Membership::Storage::WebAppSchemaMigrator          ();
use Test::More;    # for diag
use Try::Tiny qw( catch finally try );

has _connections => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache',
    lazy    => 1,
    default => sub {
        FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache->instance;
    },
);

# Create a database copy for each test method.
around 'run_test_method' =>
    sub ( $orig, $self, $test_instance, $test_method, @args ) {

    my $base_db = _base_db_for_test_class($test_instance);
    my $temp_db = join '_', $base_db, 'method', time();

    try {
        diag "Preparing to run $test_method...";

        diag "Copying $base_db to $temp_db...";
        my $base_cxn = $self->_connections->get($base_db);
        $base_cxn->migrator->copy_to($temp_db);

        diag "Setting current database to $temp_db...";
        my $cxn = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new(
            db_config =>
                FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig
                ->new(
                database => $temp_db,
                ),
        );
        $self->_connections->set( $temp_db, $cxn );
        $self->_connections->set_current($temp_db);

        $self->$orig( $test_instance, $test_method, @args );
    }
    catch {
        die "Failure in a test method: $_";
    }
    finally {
        diag "Finished testing $test_method...";

        if ( $test_instance->can('reset_connection') ) {
            note 'Resetting schema attributes in the instance under test...';
            $test_instance->reset_connection;
        }

        my $cxn = $self->_connections->get($temp_db);
        if ($cxn) {
            diag "Dropping $temp_db...";
            $cxn->reset;
            $cxn->migrator->drop_database;
            $self->_connections->delete($temp_db);
        }
    };
    };

sub _base_db_for_test_class ( $test_class ) {
    return $test_class =~ m/^TestForETL/
        ? $ETL_TEST_DB_NAME
        : $STANDARD_TEST_DB_NAME;
}

1;
