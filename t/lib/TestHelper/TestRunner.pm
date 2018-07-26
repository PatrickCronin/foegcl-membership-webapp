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

use Class::Load qw( load_class );
use Const::Fast 'const';
use FOEGCL::Membership::Config::WebAppDatabase ();
use FOEGCL::Membership::Const qw(
    $STANDARD_TEST_DB_NAME
    $ETL_TEST_DB_NAME
);
use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use FOEGCL::Membership::Types qw(ArrayRef HashRef);
use List::Util 'any';
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

}

has _selected_classes => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    builder => '_build_selected_classes',
);

has _test_db_config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_test_db_config',
);

has _executor_roles => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { ['TestRole::ManageDB'] },
);

sub _build_selected_classes ( $self, @ ) {
    return TestHelper::TestLoader->new(
        specific_classes => $self->class,
        (
              $self->etl eq $ETL_IGNORE ? ( skip_dirs   => ['TestForETL'] )
            : $self->etl eq $ETL_ONLY   ? ( source_dirs => ['TestForETL'] )
            :                             ()
        ),
    )->test_class_packages;
}

sub _build_test_db_config ( $self, @ ) {
    my $is_etl_test = qr/ \A TestForETL:: /x;
    my %required_db = (
        $STANDARD_TEST_DB_NAME =>
            ( any { $_ !~ m/$is_etl_test/ } $self->_selected_classes->@* )
        ? 1
        : 0,
        $ETL_TEST_DB_NAME => (
            (
                any { $_ =~ m/$is_etl_test/ }
                $self->_selected_classes->@*
            ) ? 1 : 0,
        ),
    );

    my %db_config;
    my $prod_db_config = FOEGCL::Membership::Config::WebAppDatabase->instance;
    foreach my $db_name ( keys %required_db ) {
        next if !$required_db{$db_name};

        $db_config{$db_name} = $prod_db_config->clone( database => $db_name );

        die
            'Failed to change database name when cloning the production db config'
            if $db_config{$db_name}->database eq $prod_db_config->database;
    }

    return \%db_config;
}

sub run ($self) {
    $self->_test_db_config;
    $self->_load_executor_roles;

    try {
        $self->_maybe_setup_standard_test_db;
        $self->_maybe_setup_etl_test_db;

        diag 'Starting tests...';

        Test::Class::Moose::Runner->new(
            executor_roles   => $self->_executor_roles,
            jobs             => 1,
            set_process_name => 1,
            test_classes     => $self->_selected_classes,
            use_environment  => 1,
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

sub _load_executor_roles ( $self ) {
    foreach my $role ( $self->_executor_roles->@* ) {
        load_class $role;
    }
}

sub _maybe_setup_standard_test_db( $self ) {
    return if !exists $self->_test_db_config->{$STANDARD_TEST_DB_NAME};

    diag 'Creating the standard test database from source...';

    my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
        quiet     => 1,
        verbose   => 0,
        db_config => $self->_test_db_config->{$STANDARD_TEST_DB_NAME}
    );
    $migrator->create_or_update_database;
    $migrator->clear_connection;

    FOEGCL::Membership::Config::WebAppDatabase->add_version(
        $STANDARD_TEST_DB_NAME,
        $self->_test_db_config->{$STANDARD_TEST_DB_NAME},
    );
}

sub _maybe_setup_etl_test_db( $self ) {
    return if !exists $self->_test_db_config->{$ETL_TEST_DB_NAME};

    diag
        'Creating the ETL test database as a copy of the production database...';

    my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
        quiet   => 1,
        verbose => 0,
    );
    $migrator->copy_to($ETL_TEST_DB_NAME);
    $migrator->clear_connection;

    FOEGCL::Membership::Config::WebAppDatabase->add_version(
        $ETL_TEST_DB_NAME,
        $self->_test_db_config->{$ETL_TEST_DB_NAME},
    );
}

sub _drop_test_dbs( $self ) {
    foreach my $test_db ( keys $self->_test_db_config->%* ) {
        $self->_drop_db_if_exists($test_db);
    }
}

sub _drop_db_if_exists ( $self, $db_name ) {
    FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
        quiet   => 1,
        verbose => 0,
        db_config =>
            FOEGCL::Membership::Config::WebAppDatabase->version($db_name),
    )->drop_database;
}

no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;

1;
