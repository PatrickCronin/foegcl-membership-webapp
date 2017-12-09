package TestFor::FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const qw(
    $GENERAL_DONATION
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);
use FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;
use Hash::Objectify qw( objectify );
use Test::Differences qw( eq_or_diff );
use Test::Fatal qw( exception );

sub test_create_general_donations_for ( $self, @ ) {
    my @test_cases = (
        {
            description => 'survives with no donations',
            in => [],
            expected => [],
        },
        {
            description => 'zero-valued donations are removed',
            in => [0, 3, 0],
            expected => [ [$GENERAL_DONATION, 3] ],
        },
        {
            description => 'donations are built as expected',
            in => [25, 35],
            expected => [
                [$GENERAL_DONATION, 25],
                [$GENERAL_DONATION, 35],
            ],
        },
    );

    foreach my $test_case ( @test_cases ) {
        eq_or_diff(
            [
                FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations::_create_general_donations_for(
                    $test_case->{in}->@*
                )
            ],
            $test_case->{expected},
            $test_case->{description}
        );
    }    
}

sub test_membership_donation_type_for ( $self, @ ) {
    my $year = 2017;
    my $household_membership_amount = 25;
    my $individual_membership_amount = 15;

    my @test_cases = (
        {
            description => 'plain household membership',
            in => {
                year => $year,
                num_people => 2,
                donation_sum => $household_membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'plain individual membership',
            in => {
                year => $year,
                num_people => 1,
                donation_sum => $individual_membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'one person paying enough for two',
            in => {
                year => $year,
                num_people => 1,
                donation_sum => $household_membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'two people paying enough for one',
            in => {
                year => $year,
                num_people => 2,
                donation_sum => $individual_membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'three people paying enough for two',
            in => {
                year => $year,
                num_people => 3,
                donation_sum => $household_membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'two people paying less than enough for one',
            in => {
                year => $year,
                num_people => 2,
                donation_sum => $individual_membership_amount / 2,
            },
            expected => undef,
        },
        {
            description => 'one person paying less than enough',
            in => {
                year => $year,
                num_people => 1,
                donation_sum => $individual_membership_amount / 2,
            },
            expected => undef,
        },
    );

    my $affiliations_and_donations_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new;

    foreach my $test_case (@test_cases) {
        my $mdt = $affiliations_and_donations_helper->_membership_donation_type_for(
            $test_case->{in}->@{ qw(year num_people donation_sum) }
        );

        eq_or_diff(
            ( defined $mdt ? $mdt->{donation_type} : undef ),
            $test_case->{expected},
            $test_case->{description}
        );
    }
}

sub test_transform_year_donations_for_type ( $self, @ ) {
    my $household_membership_amount = 25;
    my $individual_membership_amount = 15;

    my @test_cases = (
        {
            description => 'single donation equal to required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ $individual_membership_amount ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
            ],
        },
        {
            description => 'single donation above required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ $individual_membership_amount + 3 ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
                [ $GENERAL_DONATION, 3 ],
            ],
        },
        {
            description => 'multiple donations summing to required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ $individual_membership_amount - 10, 3, 6, 1 ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
            ],
        },
        {
            description => 'multiple donations summing to more than required amount, each less than the required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ $individual_membership_amount - 10, 3, 6, 2 ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
                [ $GENERAL_DONATION, 1 ],
            ],
        },
        {
            description => 'multiple donations summing to more than required amount, with one being equal to the required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ 5, $individual_membership_amount, 35 ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
                [ $GENERAL_DONATION, 5 ],
                [ $GENERAL_DONATION, 35 ],
            ],
        },
        {
            description => 'multiple donations summing to more than required amount, with one being more than the required amount',
            in => {
                membership_donation_type => $INDIVIDUAL_MEMBERSHIP,
                membership_amount => $individual_membership_amount,
                donations => [ $individual_membership_amount + 10, 50 ],
            },
            expected => [
                [ $INDIVIDUAL_MEMBERSHIP, $individual_membership_amount ],
                [ $GENERAL_DONATION, 10 ],
                [ $GENERAL_DONATION, 50 ],
            ],
        },
    );

    foreach my $test_case (@test_cases) {
        eq_or_diff(
            [
                FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations::_transform_year_donations_for_type(
                        $test_case->{in}->{membership_donation_type},
                        $test_case->{in}->{membership_amount},
                        $test_case->{in}->{donations}->@*,
                    )
            ],
            $test_case->{expected},
            $test_case->{description}
        );
    }

    like(
        exception {
            FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations::_transform_year_donations_for_type(
                $INDIVIDUAL_MEMBERSHIP,
                $individual_membership_amount,
                $individual_membership_amount - 3
            )
        },
        qr/This sub cannot handle donations total under membership_amount./,
        'chokes when donation sum is less than required amount'
    )
}

sub test_transform_donations_for_year ( $self, @ ) {
    my $year = 2017;
    my $household_membership_amount = 25;

    my $affiliations_and_donations_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new;

    eq_or_diff(
        $affiliations_and_donations_helper->_transform_donations_for_year(
            ( objectify { num_people => 2 } ),
            $year,
            $household_membership_amount - 10,
            10
        ),
        [ 
            [ $HOUSEHOLD_MEMBERSHIP, '25.00' ]
        ],
        'works for friend -> membership transitions'
    );
    
    eq_or_diff(
        $affiliations_and_donations_helper->_transform_donations_for_year(
            ( objectify { num_people => 2 } ),
            $year,
            10,
            1,
            1
        ),
        [ 
            [ $GENERAL_DONATION, 10 ],
            [ $GENERAL_DONATION, 1 ],
            [ $GENERAL_DONATION, 1 ],
        ],
        'works for friend -> non-membership transitions'
    );
}

__PACKAGE__->meta->make_immutable;

1;
