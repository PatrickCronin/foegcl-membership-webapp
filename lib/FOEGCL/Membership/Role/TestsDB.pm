package FOEGCL::Membership::Role::TestsDB;

# ABSTRACT: Collection of actions that make testing with the DB easier

use FOEGCL::Membership::Moose::Role;

# XXX: Parameterize this role with a transaction_each attribute (class|method)

around 'test_startup' => sub {

    # XXX: Start transaction
};

around 'test_shutdown' => sub {

    # XXX: Rollback transaction
};

1;
