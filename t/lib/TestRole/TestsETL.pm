package TestRole::TestsETL;

use FOEGCL::Membership::Moose::Role;

use Test::More;

with 'FOEGCL::Membership::Role::HasWebAppSchema';

around 'test_startup' => sub ( $orig, $self, @args ) {
    if ( !$ENV{TEST_ETL} ) {
        $self->test_skip(
            '--test-set=etl_validation should be used to run these tests.');
    }
    else {
        note 'Starting transaction...';
        $self->_schema->storage->txn_begin;

        $self->$orig(@args);
    }
};

around 'test_shutdown' => sub ( $orig, $self, @args ) {
    $self->$orig(@args);

    note 'Stopping transaction...';
    $self->_schema->storage->txn_rollback;
};

1;
