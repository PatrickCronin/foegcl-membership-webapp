package TestRole::ManageDB;

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Const qw(
    $STANDARD_TEST_DB_NAME
    $ETL_TEST_DB_NAME
);
use FOEGCL::Membership::Config::WebAppDatabase        ();
use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use Test::More;    # for diag
use Try::Tiny qw( catch finally try );

# Create a database copy for each test method.
around 'run_test_method' =>
    sub ( $orig, $self, $test_instance, $test_method, @args ) {
    my $base_db = _base_db_for_test_class($test_instance);
    my $temp_db = join '_', $base_db, 'method', time();

    try {
        diag "Preparing to run $test_method...";

        diag "Setting current database to $base_db...";
        FOEGCL::Membership::Config::WebAppDatabase->set_current($base_db);

        diag "Copying $base_db to $temp_db...";
        my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
            quiet   => 1,
            verbose => 0,
            db_config =>
                FOEGCL::Membership::Config::WebAppDatabase->version($base_db),
        );
        $migrator->copy_to($temp_db);
        $migrator->clear_connection;

        if (
            !FOEGCL::Membership::Config::WebAppDatabase->version_exists(
                $temp_db)
        ) {
            FOEGCL::Membership::Config::WebAppDatabase->add_version(
                $temp_db,
                $migrator->db_config->clone( database => $temp_db )
            );
        }

        diag "Setting current database to $temp_db...";
        FOEGCL::Membership::Config::WebAppDatabase->set_current($temp_db);

        $self->$orig( $test_instance, $test_method, @args );
    }
    catch {
        die "Failure in a test method: $_";
    }
    finally {
        diag "Finished testing $test_method...";

        if ( $test_instance->can('_reset_schema') ) {
            note 'Resetting schema attributes in the instance under test...';
            $test_instance->_reset_schema;
        }

        FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
            quiet   => 1,
            verbose => 0,
            db_config =>
                FOEGCL::Membership::Config::WebAppDatabase->version($temp_db),
        )->drop_database;

        my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
            quiet   => 1,
            verbose => 0,
            db_config =>
                FOEGCL::Membership::Config::WebAppDatabase->version($base_db),
        );
        $migrator->terminate_all_other_connections;
        $migrator->clear_connection;
    };
    };

sub _base_db_for_test_class ( $test_class ) {
    return $test_class =~ m/^TestForETL/
        ? $ETL_TEST_DB_NAME
        : $STANDARD_TEST_DB_NAME;
}

1;
