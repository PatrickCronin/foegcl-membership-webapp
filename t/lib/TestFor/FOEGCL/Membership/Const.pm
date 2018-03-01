package TestFor::FOEGCL::Membership::Const;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const
    qw( $HOUSEHOLD_MEMBERSHIP $INDIVIDUAL_MEMBERSHIP );

sub test_constants ( $self, @ ) {
    is(
        $HOUSEHOLD_MEMBERSHIP,
        'household_membership',
        'HOUSEHOLD_MEMBERSHIP'
    );
    is(
        $INDIVIDUAL_MEMBERSHIP,
        'individual_membership',
        'INDIVIDUAL_MEMBERSHIP'
    );
}

__PACKAGE__->meta->make_immutable;

1;
