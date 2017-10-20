#!perl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner ();
use Try::Tiny qw( catch finally try );

run();

sub run {
    my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new;

    try {
        $migrator->create_or_update_database;
        Test::Class::Moose::Runner->new->runtests;
    }
    catch {
        die $_;
    }
    finally {
        $migrator->drop_database;
    };
}
