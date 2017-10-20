package FOEGCL::Membership::Role::TestsDB;

# ABSTRACT: Collection of actions that make testing with the DB easier

use FOEGCL::Membership::Moose::Role;

with 'FOEGCL::Membership::Role::HasWebAppSchema';

around 'test_setup' => sub {
    $self->_schema->storage->txn_begin;
};

around 'test_teardown' => sub {
    $self->_schema->storage->txn_rollback;
};

1;
