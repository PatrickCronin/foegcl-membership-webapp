package FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;

# ABSTRACT: Extract, transform and load a Friend's annual memberships and donations

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Const qw(
    $GENERAL_DONATION
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);
use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef HashRef );
use List::MoreUtils qw(part);
use List::Util qw(sum0);

has _annual_membership_donation_types => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    builder => '_build_annual_membership_donation_types',
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';


sub _build_annual_membership_donation_types ( $self, @ ) {
    my %annual_membership_donation_types;
    my @membership_donation_types
        = $self->_schema->resultset('MembershipDonationType')->search_rs(
             {
                donation_type => {
                    -in => [
                        ( $HOUSEHOLD_MEMBERSHIP, $INDIVIDUAL_MEMBERSHIP )
                    ]
                }
             }
        )->hri->all;

    $annual_membership_donation_types{ $_->{affiliation_year} }{ $_->{donation_type} } = $_
        for @membership_donation_types;

    return \%annual_membership_donation_types;
}

sub etl ($self, $legacy_friend, @people) {
    my %extracted_donations = _extract_donations( $legacy_friend );
    my %transformed_donations
        = $self->_transform_donations( $legacy_friend, %extracted_donations );

    foreach my $year ( keys %transformed_donations ) {
        next if ! sum0 map { $_->[1] } $transformed_donations{$year}->@*;

        # Create the year's affiliation
        my $affiliation = $self->_schema->resultset('Affiliation')->create(
            {
                affiliation_year => $year,
                friend_id        => $legacy_friend->friend_id,
            }
        );

        # Load the transformed donations
        for my $donation ($transformed_donations{$year}->@*) {
            $self->_schema->resultset('Donation')->create(
                {
                    affiliation_id => $affiliation->id,
                    donation_type  => $donation->[0],
                    amount         => $donation->[1],
                }
            );
        }

        # Relate the people to the affiliation
        my $membership_donation_type = $affiliation->membership_donation_type;
        my $max_people;
        $max_people = $membership_donation_type->membership_max_people
            if $membership_donation_type;

        my $person_cnt = 0;
        foreach my $person ( @people ) {
            $person_cnt++;

            if ( $max_people && $person_cnt > $max_people ) {
                # warn sprintf(
                #     'Not adding %s to %s membership because the membership is full.',
                #     $person->first_name . q{ } . $person->last_name,
                #     $year
                # );
                next;
            }

            $person->create_related(
                'affiliation_people',
                { affiliation_id => $affiliation->id }
            );
        }
    }
}

sub _extract_donations ( $legacy_friend ) {
    return () if ! $legacy_friend->donations;

    my %extracted_donations;
    push $extracted_donations{ $_->year }->@*, 0 + $_->donation
        for $legacy_friend->donations;

    return %extracted_donations;
}

sub _transform_donations ( $self, $legacy_friend, %extracted_donations ) {
    my %transformed_donations;
    foreach my $year ( keys %extracted_donations ) {
        $transformed_donations{$year}
            = $self->_transform_donations_for_year(
                $legacy_friend,
                $year,
                $extracted_donations{$year}->@*
            );
    }

    return %transformed_donations;
}

sub _transform_donations_for_year ( $self, $legacy_friend, $year, @donations ) {
    my $donations_total = sum0 @donations;

    my $membership_donation_type = $self->_membership_donation_type_for(
        $year,
        $legacy_friend->num_people,
        $donations_total
    );

    my @processed;
    if ($membership_donation_type) {
        @processed = _transform_year_donations_for_type(
            $membership_donation_type->{donation_type},
            $membership_donation_type->{membership_amount},
            @donations,
        );
    }
    else {
        @processed = _create_general_donations_for(@donations);
    }

    # use DDP;
    # my $processed_total = sum0 map { $_->[1] } @processed;
    # if ( $donations_total != $processed_total ) {
    #     my %debug = (
    #         legacy_friend       => $legacy_friend->friend_id,
    #         year                => $year,
    #         legacy_donations    => \@donations,
    #         legacy_total        => $donations_total,
    #         processed_donations => \@processed,
    #         processed_total     => $processed_total,
    #     );
    #     die np %debug;
    # }

    return \@processed;
}

sub _transform_year_donations_for_type (
    $membership_donation_type,
    $membership_amount,
    @donations
    ) {

    my @parts = part { 1 + ( $_ <=> $membership_amount ) } @donations;

    # Does a donation equal the expected amount? If so, its the membership; remaining are general donations.
    return (
        [ $membership_donation_type, shift $parts[1]->@* ],
        _create_general_donations_for(
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
        unshift $parts[0]->@*,
            $membership_amount,
            $sum - $membership_amount;
    }
    else {
        confess
            'This sub cannot handle donations total under membership_amount. '
            . ( sum0 @donations ) . q{ }
            . $membership_amount;
    }

    return _transform_year_donations_for_type(
        $membership_donation_type,
        $membership_amount,
        ( grep { $_ > 0 } map { $_->@* } grep { defined } @parts )
    );
}

sub _create_general_donations_for ( @amounts ) {
    return map { [ $GENERAL_DONATION, $_ ] } grep { $_ > 0 } @amounts;
}

sub _membership_donation_type_for( $self, $year, $num_people, $donation_sum ) {
    my $mdts = $self->_annual_membership_donation_types->{$year};

    if ($num_people >= 2
        && $donation_sum >= $mdts->{$HOUSEHOLD_MEMBERSHIP}->{membership_amount}) {
        return $mdts->{$HOUSEHOLD_MEMBERSHIP};
    }

    if ($donation_sum >= $mdts->{$INDIVIDUAL_MEMBERSHIP}->{membership_amount}) {
        return $mdts->{$INDIVIDUAL_MEMBERSHIP};
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;
