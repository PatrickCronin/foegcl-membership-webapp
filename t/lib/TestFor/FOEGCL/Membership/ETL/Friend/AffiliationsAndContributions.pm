package TestFor::FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions;

use FOEGCL::Membership::Test::Class::Moose;

use Const::Fast qw( const );
use FOEGCL::Membership::Const qw(
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
    $SENIOR_HOUSEHOLD_MEMBERSHIP
    $SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP
);
use FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions;
use Hash::Objectify qw( objectify );
use Test::Differences qw( eq_or_diff );
use Test::Fatal qw( exception );

has _individual_mtp => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter',
    lazy    => 1,
    builder => '_build_individual_mtp',
);

has _household_mtp => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter',
    lazy    => 1,
    builder => '_build_household_mtp',
);

has _senior_household_mtp => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter',
    lazy    => 1,
    builder => '_build_senior_household_mtp',
);

has _senior_student_individual_mtp => (
    is => 'ro',
    isa =>
        'FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter',
    lazy    => 1,
    builder => '_build_senior_student_individual_mtp',
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

const my $YEAR => 2017;

sub _build_individual_mtp ( $self, @ ) {
    return $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $YEAR,
            membership_type => $INDIVIDUAL_MEMBERSHIP,
        }
    )->one_row;
}

sub _build_household_mtp ( $self, @ ) {
    return $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $YEAR,
            membership_type => $HOUSEHOLD_MEMBERSHIP,
        }
    )->one_row;
}

sub _build_senior_household_mtp ( $self, @ ) {
    return $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $YEAR,
            membership_type => $SENIOR_HOUSEHOLD_MEMBERSHIP,
        }
    )->one_row;
}

sub _build_senior_student_individual_mtp ( $self, @ ) {
    return $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $YEAR,
            membership_type => $SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP,
        }
    )->one_row;
}

sub test_membership_donation_type_for ( $self, @ ) {
    my @test_cases = (
        {
            description => 'plain household membership',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_household_mtp->membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'plain individual membership',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_individual_mtp->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'senior household membership',
            in          => {
                year       => $YEAR,
                num_people => 2,
                donation_sum =>
                    $self->_senior_household_mtp->membership_amount,
            },
            expected => $SENIOR_HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'plain senior/student individual membership',
            in          => {
                year       => $YEAR,
                num_people => 1,
                donation_sum =>
                    $self->_senior_student_individual_mtp->membership_amount,
            },
            expected => $SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'one person paying enough for two',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_household_mtp->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'two people paying enough for one',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_individual_mtp->membership_amount,
            },
            expected => $INDIVIDUAL_MEMBERSHIP,
        },
        {
            description => 'three people paying enough for two',
            in          => {
                year         => $YEAR,
                num_people   => 3,
                donation_sum => $self->_household_mtp->membership_amount,
            },
            expected => $HOUSEHOLD_MEMBERSHIP,
        },
        {
            description => 'two people paying less than enough for one',
            in          => {
                year         => $YEAR,
                num_people   => 2,
                donation_sum => $self->_individual_mtp->membership_amount / 2,
            },
            expected => undef,
        },
        {
            description => 'one person paying less than enough',
            in          => {
                year         => $YEAR,
                num_people   => 1,
                donation_sum => $self->_individual_mtp->membership_amount / 2,
            },
            expected => undef,
        },
    );

    my $affiliations_and_contributions_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions->new;

    foreach my $test_case (@test_cases) {
        ## no critic (Subroutines::ProtectPrivateSubs)
        my $mdt
            = $affiliations_and_contributions_helper
            ->_qualifying_membership_type_for(
            year         => $test_case->{in}->{year},
            num_people   => $test_case->{in}->{num_people},
            donation_sum => $test_case->{in}->{donation_sum},
            );
        ## use critic

        eq_or_diff(
            ( defined $mdt ? $mdt->membership_type : undef ),
            $test_case->{expected},
            $test_case->{description}
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;
