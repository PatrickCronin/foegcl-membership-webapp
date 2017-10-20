#!perl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();
use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner ();
use Try::Tiny qw( catch finally try );

run();

sub run {
    my $migrator = FOEGCL::Membership::Storage::WebAppSchemaMigrator->new;

    my $result;
    try {
        $migrator->create_or_update_database;
        Test::Class::Moose::Runner->new->runtests;
    }
    catch {
        $result = $_;
    }
    finally {
        $migrator->drop_database;
    };

    die $result if $result;
}
