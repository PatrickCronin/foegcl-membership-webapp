package FOEGCL::Membership::Const;

use FOEGCL::Membership::perlbase;

use Const::Fast 'const';

const our $HOUSEHOLD_MEMBERSHIP  => 'household_membership';
const our $INDIVIDUAL_MEMBERSHIP => 'individual_membership';
const our $STANDARD_TEST_DB_NAME => 'foegcl_membership_test_std';
const our $ETL_TEST_DB_NAME      => 'foegcl_membership_test_etl';

use base qw(Exporter);
our @EXPORT_OK = qw(
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
    $STANDARD_TEST_DB_NAME
    $ETL_TEST_DB_NAME
);

1;
