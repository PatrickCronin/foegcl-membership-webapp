package TestHelper::TestRunner;

# ABSTRACT:

use Moose::Util::TypeConstraints 'enum';
use FOEGCL::Membership::Moose;

=head1 DESCRIPTION

The standard tests run against a test database, while the ETL validation
tests run against the production database. After initial deployment, we'll
never want to run the ETL validation tests again. This runner ensures that
only one set of tests is run at a time, and controls which database is used
to do that.

=cut

use lib 't/lib';    # Find the TestHelper dir

use FOEGCL::Membership::Config::WebAppDatabase        ();
use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use FOEGCL::Membership::Types 'ArrayRef';
use List::Util 'pairkeys';
use Test::Class::Moose::Runner ();
use Test::More;     # for note
use TestHelper::TestLoader ();
use Try::Tiny qw( catch finally try );

with 'MooseX::Getopt::Dashes';

# Can't use Const::Fast because these contain CODE refs.
# Array so that first item can be interpreted as default
my @TEST_SET = (
    standard       => \&_run_standard_tests,
    etl_validation => \&_run_etl_validation_tests,
);

{
    my $test_set_type = enum 'TestSet', [ pairkeys @TEST_SET ];
    has test_set => (
        is            => 'ro',
        isa           => 'TestSet',
        default       => sub { $TEST_SET[0] },
        documentation => 'Which test set to run. Available options: '
            . ( join q{, }, $test_set_type->values->@* )
            . ". Defaults to $TEST_SET[0].",
    );
}

has test_class => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
    documentation =>
        'A specific test class to run. Can either be a filename relative to t/lib, or a package name. Can be specified multiple times. If not specified, the test harness will run all the test classes in the test set.',
);

sub run ( $self ) {
    my %dispatch_table  = (@TEST_SET);
    my $dispatch_method = $dispatch_table{ $self->test_set };
    $self->$dispatch_method;
}

sub _run_standard_tests ($self) {
    my $migrator;
    try {
        note 'Creating test database '
            . FOEGCL::Membership::Config::WebAppDatabase->new->database
            . '...';
        $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
            quiet   => 1,
            verbose => 0,
        );
        $migrator->create_or_update_database;

        Test::Class::Moose::Runner->new(
            jobs             => 1,
            set_process_name => 1,
            test_classes     => TestHelper::TestLoader->new(
                specific_classes => $self->test_class,
                skip_dirs        => ['TestForETL'],
                )->test_class_packages,
            use_environment => 1,
        )->runtests;
    }
    catch {
        die $_;
    }
    finally {
        note 'Dropping test database...';
        $migrator->drop_database;
    };
}

sub _run_etl_validation_tests ($self) {

    # The WebAppDatabase config object will normally provide the test DB when
    # run under a test harness. This variable changes its behavior to to
    # provide the primary DB despite being run under a test harness.
    local $ENV{TEST_PRODUCTION_DB} = 1;

    # Send a signal to the ETL tests that we're running under the correct test
    # harness.
    local $ENV{TEST_ETL} = 1;

    Test::Class::Moose::Runner->new(
        jobs             => 1,
        set_process_name => 1,
        test_classes     => TestHelper::TestLoader->new(
            specific_classes => $self->test_class,
            source_dirs      => ['TestForETL'],
            )->test_class_packages,
        use_environment => 1,
    )->runtests;
}

no Moose::Util::TypeConstraints;

__PACKAGE__->meta->make_immutable;

1;
