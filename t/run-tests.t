#!perl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::Migrator ();
use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner ();
use Try::Tiny qw( finally try );

run();
exit;

sub run {
    my $migrator = FOEGCL::Membership::Storage::Migrator->new;

    try {
        $migrator->create_or_update_database;
        Test::Class::Moose::Runner->new->runtests;
    }
    finally { $migrator->drop_database; die @_; };
}
