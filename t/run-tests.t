#!perl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner ();
use Try::Tiny qw( catch finally try );

run();

sub run {
    my $migrator;
    try {
        if ( !$ENV{TEST_PRIMARY_DB} ) {
            $migrator
                = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
                quiet   => 1,
                verbose => 0,
                );
            $migrator->create_or_update_database;
        }

        Test::Class::Moose::Runner->new(
            jobs             => 1,
            set_process_name => 1,
            test_classes     => \@ARGV,
            use_environment  => 1,
        )->runtests;
    }
    catch {
        die $_;
    }
    finally {
        $migrator->drop_database if !$ENV{TEST_PRIMARY_DB};
    };
}
