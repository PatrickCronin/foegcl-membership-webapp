package FOEGCL::Membership::Role::TestsDB;

# ABSTRACT: Collection of actions that make testing with the DB easier

use FOEGCL::Membership::Moose::Role;

use Test::More;

with 'FOEGCL::Membership::Role::HasWebAppSchema';

around 'test_setup' => sub ( $orig, $self, @args ) {
    note 'Starting transaction';
    $self->_schema->storage->txn_begin;
    $self->$orig(@args);
};

around 'test_teardown' => sub ( $orig, $self, @args ) {
    note 'Stopping transaction';
    $self->_schema->storage->txn_rollback;
    $self->$orig(@args);
};

1;
