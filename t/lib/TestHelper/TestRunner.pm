package TestHelper::TestRunner;

# ABSTRACT:

use FOEGCL::Membership::Moose;

=head1 DESCRIPTION

The standard tests run against a test database, while the ETL validation
tests run against the production database. After initial deployment, we'll
never want to run the ETL validation tests again. This runner ensures that
only one set of tests is run at a time, and controls which database is used
to do that.

=cut

use lib 't/lib';    # Find the TestHelper dir

use Const::Fast 'const';
use FOEGCL::Membership::Const qw(
    $STANDARD_TEST_DB_NAME
    $ETL_TEST_DB_NAME
);
use FOEGCL::Membership::Storage::WebAppDatabaseConnection      ();
use FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache ();
use FOEGCL::Membership::Storage::WebAppSchemaMigrator          ();
use FOEGCL::Membership::Types qw(ArrayRef Bool HashRef);
use List::MoreUtils 'part';
use List::Util qw(any shuffle);
use Module::Runtime 'require_module';
use Test::Class::Moose::Runner ();
use Test::More;    # for diag
use TestHelper::TestLoader ();
use Try::Tiny qw( catch finally try );

with 'MooseX::Getopt::Dashes';

const my $ETL_IGNORE  => 'ignore';
const my $ETL_INCLUDE => 'include';
const my $ETL_ONLY    => 'only';

has class => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
    documentation =>
        'A specific test class to run. Can either be a filename relative to t/lib, or a package name. Can be specified multiple times. If not specified, the test harness will run all test classes.',
);

{
    use Moose::Util::TypeConstraints 'enum';
    my $etl_enum = enum( [ $ETL_IGNORE, $ETL_INCLUDE, $ETL_ONLY ] );
    has etl => (
        is            => 'ro',
        isa           => $etl_enum,
        lazy          => 1,
        default       => sub { $ETL_IGNORE },
        documentation => 'Run ETL tests? Possible values: '
            . ( join q{,}, $etl_enum->values->@* )
            . ". Defaults to $ETL_IGNORE. Setting is ignored when a specific class is given.",
    );
    no Moose::Util::TypeConstraints;
}

has method => (
    is            => 'ro',
    isa           => ArrayRef,
    default       => sub { [] },
    documentation => 'A specific test method to run.',
);

has randomize_classes => (
    is            => 'ro',
    isa           => Bool,
    default       => sub { 0 },
    documentation => 'Run classes in a random order. Defaults to 0.',
);

has randomize_methods => (
    is            => 'ro',
    isa           => Bool,
    default       => sub { 0 },
    documentation => 'Run methods in a random order. Defaults to 0.',
);

has _selected_classes => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    builder => '_build_selected_classes',
);

has _executor_roles => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { ['TestRole::ManageDB'] },
);

has _connections => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache',
    lazy    => 1,
    default => sub {
        FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache->instance;
    },
);

sub _build_selected_classes ( $self, @ ) {
    my $selected_classes = TestHelper::TestLoader->new(
        specific_classes => $self->class,
        (
              $self->etl eq $ETL_IGNORE ? ( skip_dirs   => ['TestForETL'] )
            : $self->etl eq $ETL_ONLY   ? ( source_dirs => ['TestForETL'] )
            :                             ()
        ),
    )->test_class_packages;

    # Always run TestForDB::DBICClassesMatchSchema last if it's going to be
    # run. It calls make_schema_at from DBIx::Class::Schema::Loader which
    # generates the schema, but also modifies %INC with the "new" schema
    # location, which is promptly deleted before the next test can be run,
    # leaving the %INC entries for the DBIC classes high and dry.
    # Interestingly, they still worked to an extent, but resultset classes
    # came back as being references to DBIx::Class::Schema and not
    # FOEGCL::Membership::Schema::WebApp::ResultSet.
    my @part = part {
        $_ ne 'TestForDB::DBICClassesMatchSchema' ? 0 : 1
    }
    @$selected_classes;

    my @any_time    = $part[0] ? $part[0]->@* : ();
    my @only_at_end = $part[1] ? $part[1]->@* : ();

    return $self->randomize_classes
        ? [ shuffle(@any_time), @only_at_end ]
        : [ @any_time, @only_at_end ];
}

sub run ($self) {
    $self->_setup_standard_test_db if $self->_requires_standard_test_db;
    $self->_setup_etl_test_db      if $self->_requires_etl_test_db;
    $self->_load_executor_roles;

    try {
        diag 'Starting tests...';

        my $method_options = join '|', map { "\Q$_\E" } $self->method->@*;

        Test::Class::Moose::Runner->new(
            executor_roles   => $self->_executor_roles,
            jobs             => 1,
            randomize        => $self->randomize_methods,
            set_process_name => 1,
            test_classes     => $self->_selected_classes,
            use_environment  => 1,
            (
                $self->method->@*
                ? ( include => qr/$method_options/ )
                : ()
            )
        )->runtests;
    }
    catch {
        die "Failure in the test run: $_";
    }
    finally {
        diag 'Done running tests...';
        $self->_drop_test_dbs;
    };
}

sub _setup_standard_test_db ( $self ) {
    diag 'Creating the standard test database from source...';

    my $cxn = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new(
        db_config =>
            FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig->new(
            database => $STANDARD_TEST_DB_NAME,
            ),
    );
    $self->_connections->set( $STANDARD_TEST_DB_NAME, $cxn );
    $cxn->migrator->create_or_update_database;

    # Don't clear the migrator connections here; we'll need them for each test
}

sub _setup_etl_test_db ( $self ) {
    diag
        'Creating the ETL test database as a copy of the production database...';

    my $prod_cxn = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new;
    $prod_cxn->migrator->copy_to($ETL_TEST_DB_NAME);
    $prod_cxn->migrator->clear_connection;

    my $cxn = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new(
        db_config =>
            FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig->new(
            database => $ETL_TEST_DB_NAME,
            ),
    );
    $self->_connections->set( $ETL_TEST_DB_NAME, $cxn );

    # Don't clear the migrator connections here; we'll need them for each test
}

sub _load_executor_roles ( $self ) {
    foreach my $role ( $self->_executor_roles->@* ) {
        require_module $role;
    }
}

sub _drop_test_dbs( $self ) {
    foreach my $test_db ( $STANDARD_TEST_DB_NAME, $ETL_TEST_DB_NAME ) {
        my $cxn = $self->_connections->get($test_db);
        if ($cxn) {
            diag "Dropping $test_db...";
            $cxn->reset_connection;
            $cxn->migrator->drop_database;
            $self->_connections->delete($test_db);
        }
    }
}

{
    my $is_etl_test = qr/ \A TestForETL:: /x;

    sub _requires_standard_test_db ( $self ) {
        return any { $_ !~ m/$is_etl_test/ } $self->_selected_classes->@*;
    }

    sub _requires_etl_test_db ( $self ) {
        return any { $_ =~ m/$is_etl_test/ } $self->_selected_classes->@*;
    }
}

__PACKAGE__->meta->make_immutable;

1;
