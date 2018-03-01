package TestRole::TestsDB;

# ABSTRACT: Collection of actions that make testing with the DB easier

use FOEGCL::Membership::Moose::Role;

use Test::More;    # for note

with 'FOEGCL::Membership::Role::HasWebAppSchema';

around 'test_setup' => sub ( $orig, $self, @args ) {
    note 'Starting transaction...';
    $self->_schema->storage->txn_begin;

    $self->$orig(@args);
};

around 'test_teardown' => sub ( $orig, $self, @args ) {
    $self->$orig(@args);

    note 'Stopping transaction...';
    $self->_schema->storage->txn_rollback;
};

1;
