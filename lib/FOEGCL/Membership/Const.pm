package FOEGCL::Membership::Const;

use FOEGCL::Membership::perlbase;

use Const::Fast 'const';

const our $HOUSEHOLD_MEMBERSHIP  => 'household_membership';
const our $INDIVIDUAL_MEMBERSHIP => 'individual_membership';

use base qw(Exporter);
our @EXPORT_OK = qw(
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);

1;
