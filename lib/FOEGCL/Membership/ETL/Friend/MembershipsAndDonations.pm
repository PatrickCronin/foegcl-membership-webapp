package FOEGCL::Membership::ETL::Friend::MembershipsAndDonations;

# ABSTRACT: Extract, transform and load a Friend's annual memberships and donations

use FOEGCL::Membership::Moose;

use Data::Printer;
use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef HashRef );
use List::MoreUtils qw(part);
use List::Util qw(sum0);

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

has people => (
    is  => 'ro',
    isa => 'ArrayRef [FOEGCL::Membership::Schema::WebApp::Result::Person]',
    required => 1,
);

has _annual_donations => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_annual_donations',
);

has _processed_annual_donations => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_processed_annual_donations',
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub _build_annual_donations ($self) {
    my %annual_donations;
    push $annual_donations{ $_->year }->@*, 0 + $_->donation
        for $self->legacy_friend->donations;

    return \%annual_donations;
}

sub _build_processed_annual_donations ($self) {
    my %processed_annual_donations;
    foreach my $donation_year ( keys $self->_annual_donations->%* ) {
        $processed_annual_donations{$donation_year}
            = $self->_process_donations_for_year($donation_year);
    }

    return \%processed_annual_donations;
}

sub etl ($self) {
    foreach my $donation_year ( keys $self->_processed_annual_donations->%* )
    {

        # Create the year's membership
        my $membership = $self->_schema->resultset('Membership')->create(
            {
                membership_year => $donation_year,
                friend_id       => $self->legacy_friend->friend_id,
            }
        );

        # Create the donations
        my @donations
            = $self->_processed_annual_donations->{$donation_year}->@*;
        for my $donation (@donations) {
            $self->_schema->resultset('Donation')->create(
                {
                    membership_id => $membership->id,
                    donation_type => $donation->[0],
                    amount        => $donation->[1],
                }
            );
        }

        # Relate the people to the membership
        my $max_people = 0;
        my $membership_type
            = $self->_schema->resultset('MembershipDonationType')->search_rs(
            {
                membership_year => $donation_year,
                donation_type   => { -in => [ map { $_->[0] } @donations ] },
            },
            { columns => ['membership_max_people'] }
            )->first;
        $max_people = $membership_type->membership_max_people
            if $membership_type;

        my $person_cnt = 0;
        foreach my $person ( $self->people->@* ) {
            $person_cnt++;

            if ( $person_cnt > $max_people ) {
                warn sprintf(
                    'Not adding %s to %s membership because the membership is full.',
                    $person->first_name . q{ } . $person->last_name,
                    $donation_year
                );
                next;
            }

            $person->create_related(
                'person_memberships',
                { membership_id => $membership->id }
            );
        }
    }
}

sub _process_donations_for_year ( $self, $year ) {
    my @donations       = $self->_annual_donations->{$year}->@*;
    my @given           = @donations;
    my $donations_total = sum0 @donations;

    my %membership_req = $self->_membership_requirements_for_year($year);

    my @processed;
    if ( $donations_total >= $membership_req{expected_amount} ) {
        @processed = $self->_process_year_donations_for_type(
            membership_type   => $membership_req{expected_type},
            membership_amount => $membership_req{expected_amount},
            donations         => \@donations
        );
    }
    elsif ($year < 2017
        && $donations_total >= $membership_req{other_amount} ) {
        @processed = $self->_process_year_donations_for_type(
            membership_type   => $membership_req{other_type},
            membership_amount => $membership_req{other_amount},
            donations         => \@donations
        );
    }
    else {
        @processed = $self->_create_general_donations_for(@donations);
    }

    my $sum0_given = sum0 @given;
    my $sum0_processed = sum0 map { $_->[1] } @processed;
    if ( $sum0_given != $sum0_processed ) {
        my %debug = (
            legacy_friend       => $self->legacy_friend->friend_id,
            year                => $year,
            legacy_donations    => \@given,
            legacy_total        => $sum0_given,
            processed_donations => \@processed,
            processed_total     => $sum0_processed,
        );
        die np %debug;
    }

    return \@processed;
}

sub _process_year_donations_for_type ( $self, %args ) {
    my $membership_type   = $args{membership_type};
    my $membership_amount = $args{membership_amount};
    my @donations         = $args{donations}->@*;

    my @parts = part { 1 + ( $_ <=> $membership_amount ) } @donations;

    # Does a donation equal the expected amount? If so, its the membership; remaining are general donations.
    return (
        [ $membership_type, shift $parts[1]->@* ],
        $self->_create_general_donations_for(
            grep { $_ > 0 } map { $_->@* } grep { defined } @parts
        )
    ) if defined $parts[1];

    # Does a single donation total more than the expected membership amount? If so, split it.
    if ( defined $parts[2] ) {
        my $combined_donation = shift $parts[2]->@*;
        unshift $parts[2]->@*,
            $membership_amount,
            $combined_donation - $membership_amount;
    }

    # Does a sum of the donations total the expected amount or more? If so, add 'em up and split the total if necessary.
    elsif ( ( sum0 @donations ) >= $membership_amount ) {
        my $sum = 0;
        while ( @donations && $sum < $membership_amount ) {
            $sum += shift $parts[0]->@*;
        }
        unshift $parts[0]->@*, $membership_amount, $sum - $membership_amount;
    }
    else {
        confess
            'This sub cannot handle donations total under membership_amount. '
            . ( sum0 @donations ) . q{ }
            . $membership_amount;
    }

    return $self->_process_year_donations_for_type(
        membership_amount => $membership_amount,
        membership_type   => $membership_type,
        donations =>
            [ grep { $_ > 0 } map { $_->@* } grep { defined } @parts ]
    );
}

sub _create_general_donations_for ( $self, @amounts ) {
    return map { [ 'general_donation', $_ ] } grep { $_ > 0 } @amounts;
}

sub _membership_requirements_for_year ( $self, $year ) {
    my %membership_requirements
        = map { $_->donation_type => $_->membership_amount }
        $self->_schema->resultset('MembershipDonationType')
        ->search_rs( { membership_year => $year } )->all;

    my $is_currently_household
        = defined $self->legacy_friend->spouse_first_name
        && trim( $self->legacy_friend->spouse_first_name ) ne q{};

    return (
          'expected_type' => $is_currently_household
        ? 'household_membership'
        : 'individual_membership',
        'expected_amount' => $is_currently_household
        ? $membership_requirements{household_membership}
        : $membership_requirements{individual_membership},
        'other_type' => $is_currently_household
        ? 'individual_membership'
        : 'household_membership',
        'other_amount' => $is_currently_household
        ? $membership_requirements{individual_membership}
        : $membership_requirements{household_membership}
    );
}

__PACKAGE__->meta->make_immutable;

1;
