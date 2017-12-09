package TestFor::FOEGCL::Membership::Const;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const qw(
    $GENERAL_DONATION
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);

sub test_constants ( $self, @ ) {
    ok( $GENERAL_DONATION, 'general_donation' );
    ok( $HOUSEHOLD_MEMBERSHIP, 'household_membership' );
    ok( $INDIVIDUAL_MEMBERSHIP, 'individual_membership' );
}

__PACKAGE__->meta->make_immutable;

1;