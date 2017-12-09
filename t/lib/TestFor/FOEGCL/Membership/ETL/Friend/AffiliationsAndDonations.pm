package TestFor::FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;

use FOEGCL::Membership::Test::Class::Moose;

use Const::Fast qw( const );
use FOEGCL::Membership::Const qw(
    $GENERAL_DONATION
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);
use FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;
use Hash::Objectify qw( objectify );
use Test::Differences qw( eq_or_diff );
use Test::Fatal qw( exception );

has _individual_mdt => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType',
    lazy    => 1,
    builder => '_build_individual_mdt',
);

has _household_mdt => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType',
    lazy    => 1,
    builder => '_build_household_mdt',
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

const my $YEAR => 2017;

sub _build_individual_mdt ( $self, @ ) {
    return $self->_schema->resultset('MembershipDonationType')->search_rs(
        {
            affiliation_year => $YEAR,
            donation_type    => $INDIVIDUAL_MEMBERSHIP,
        }
    )->single;
}

sub _build_household_mdt ( $self, @ ) {
    return $self->_schema->resultset('MembershipDonationType')->search_rs(
        {
            affiliation_year => $YEAR,
            donation_type    => $HOUSEHOLD_MEMBERSHIP,
        }
    )->single;
}

sub test_create_general_donations_for ( $self, @ ) {
    my @test_cases = (
        {
            description => 'survives with no donations',
            in          => [],
            expected    => [],
        },
        {
            description => 'zero-valued donations are removed',
            in          => [ 0, 3, 0 ],
            expected    => [ [ $GENERAL_DONATION, 3 ] ],
        },
        {
            description => 'donations are built as expected',
            in          => [ 25, 35 ],
            expected    => [
                [ $GENERAL_DONATION, 25 ],
                [ $GENERAL_DONATION, 35 ],
            ],
        },
    );

    foreach my $test_case (@test_cases) {
        eq_or_diff(
            [
                ## no critic (Subroutines::ProtectPrivateSubs)
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
    my @test_cases = (
        {
            description => 'plain household membership',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_household_mdt->membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'plain individual membership',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_individual_mdt->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'one person paying enough for two',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_household_mdt->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'two people paying enough for one',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_individual_mdt->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'three people paying enough for two',
            in          => {
                year         => $YEAR,
                num_people   => 3,
                donation_sum => $self->_household_mdt->membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'two people paying less than enough for one',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_individual_mdt->membership_amount / 2,
            },
            expected => undef,
        },
        {
            description => 'one person paying less than enough',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_individual_mdt->membership_amount / 2,
            },
            expected => undef,
        },
    );

    my $affiliations_and_donations_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new;

    foreach my $test_case (@test_cases) {
        ## no critic (Subroutines::ProtectPrivateSubs)
        my $mdt
            = $affiliations_and_donations_helper
            ->_membership_donation_type_for(
            year         => $test_case->{in}->{year},
            num_people   => $test_case->{in}->{num_people},
            donation_sum => $test_case->{in}->{donation_sum},
            );
        ## use critic

        eq_or_diff(
            ( defined $mdt ? $mdt->donation_type : undef ),
            $test_case->{expected},
            $test_case->{description}
        );
    }
}

sub test_transform_year_donations_for_type ( $self, @ ) {
    my @test_cases = (
        {
            description => 'single donation equal to required amount',
            in          => {
                mdt       => $self->_individual_mdt,
                donations => [ $self->_individual_mdt->membership_amount ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
            ],
        },
        {
            description => 'single donation above required amount',
            in          => {
                mdt => $self->_individual_mdt,
                donations =>
                    [ $self->_individual_mdt->membership_amount + 3 ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
                [ $GENERAL_DONATION, 3 ],
            ],
        },
        {
            description => 'multiple donations summing to required amount',
            in          => {
                mdt       => $self->_individual_mdt,
                donations => [
                    $self->_individual_mdt->membership_amount - 10, 3, 6, 1
                ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
            ],
        },
        {
            description =>
                'multiple donations summing to more than required amount, each less than the required amount',
            in => {
                mdt       => $self->_individual_mdt,
                donations => [
                    $self->_individual_mdt->membership_amount - 10, 3, 6, 2
                ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
                [ $GENERAL_DONATION, 1 ],
            ],
        },
        {
            description =>
                'multiple donations summing to more than required amount, with one being equal to the required amount',
            in => {
                mdt => $self->_individual_mdt,
                donations =>
                    [ 5, $self->_individual_mdt->membership_amount, 35 ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
                [ $GENERAL_DONATION, 5 ],
                [ $GENERAL_DONATION, 35 ],
            ],
        },
        {
            description =>
                'multiple donations summing to more than required amount, with one being more than the required amount',
            in => {
                mdt => $self->_individual_mdt,
                donations =>
                    [ $self->_individual_mdt->membership_amount + 10, 50 ],
            },
            expected => [
                [
                    $INDIVIDUAL_MEMBERSHIP,
                    $self->_individual_mdt->membership_amount
                ],
                [ $GENERAL_DONATION, 10 ],
                [ $GENERAL_DONATION, 50 ],
            ],
        },
    );

    foreach my $test_case (@test_cases) {
        eq_or_diff(
            [
                ## no critic (Subroutines::ProtectPrivateSubs)
                FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations::_transform_year_donations_for_type(
                    $test_case->{in}->{mdt},
                    $test_case->{in}->{donations}->@*,
                )
            ],
            $test_case->{expected},
            $test_case->{description}
        );
    }

    like(
        exception {
            ## no critic (Subroutines::ProtectPrivateSubs)
            FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations::_transform_year_donations_for_type(
                $self->_individual_mdt,
                $self->_individual_mdt->membership_amount - 3
                )
        },
        qr/This sub cannot handle donations total under membership_amount./,
        'chokes when donation sum is less than required amount'
    );
}

sub test_transform_donations_for_year ( $self, @ ) {
    my $affiliations_and_donations_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new;

    eq_or_diff(
        $affiliations_and_donations_helper->_transform_donations_for_year(
            ( objectify { num_people => 2 } ),
            $YEAR,
            $self->_household_mdt->membership_amount - 10,
            10
        ),
        [ [ $HOUSEHOLD_MEMBERSHIP, '25.00' ] ],
        'works for friend -> membership transitions'
    );

    eq_or_diff(
        $affiliations_and_donations_helper->_transform_donations_for_year(
            ( objectify { num_people => 2 } ),
            $YEAR,
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
