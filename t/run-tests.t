#!perl

use Modern::Perl;

use FOEGCL::Membership::Storage::Migrator ();
use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner ();

run();
exit;

sub run {
    my $migrator = FOEGCL::Membership::Storage::Migrator->new;
    $migrator->create_or_update_database;

    Test::Class::Moose::Runner->new->runtests;

    $migrator->drop_database;
}
