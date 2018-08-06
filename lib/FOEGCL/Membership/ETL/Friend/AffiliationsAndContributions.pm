package FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions;

# ABSTRACT: Extract, transform and load a Friend's annual affiliations and contributions

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Const qw(
    $INDIVIDUAL_MEMBERSHIP
    $HOUSEHOLD_MEMBERSHIP
);
use FOEGCL::Membership::Types qw(
    AffiliationYear
    PositiveOrZeroInt
    PositiveOrZeroNum
);
use List::Util qw(first sum0);
use List::UtilsBy qw(partition_by);
use Params::ValidationCompiler 'validation_for';

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub etl ( $self, $legacy_friend, @people ) {
    my %donations_by_year
        = partition_by { $_->year } $legacy_friend->donations->all;

    foreach my $year ( keys %donations_by_year ) {

        # Determine the correct membership type for the year
        my @donation_amounts = grep { $_ > 0 }
            map { 0 + $_->donation } $donations_by_year{$year}->@*;
        my $donation_sum = sum0 @donation_amounts;
        next if $donation_sum == 0;

        my $membership_type = $self->_qualifying_membership_type_for(
            {
                year         => $year,
                num_people   => scalar @people,
                donation_sum => $donation_sum,
            }
        );

        $self->_schema->storage->txn_do(
            sub {
                $self->_defer_constraints;

                # Create the affiliation
                my $affiliation
                    = $self->_schema->resultset('Affiliation')->create(
                    {
                        year            => $year,
                        friend_id       => $legacy_friend->friend_id,
                        membership_type => $membership_type->membership_type,
                    }
                    );

                # Relate the contributions to the affiliation
                foreach my $amount (@donation_amounts) {
                    $affiliation->create_related(
                        'contributions',
                        {
                            amount   => $amount,
                            received => "$year-01-01",
                        }
                    );
                }

                # Relate the people to the affiliation
                my $max_people;
                $max_people = $membership_type->membership_max_people
                    if $membership_type;

                my $count = 0;
                foreach my $person (@people) {
                    $count++;

                    if ( $max_people && $count > $max_people ) {
                        warn sprintf(
                            "Not adding %s to the %s affiliation because the membership is full.\n",
                            $person->first_name . q{ } . $person->last_name,
                            $year
                        );
                        next;
                    }

                    $affiliation->create_related(
                        'affiliation_people',
                        { person_id => $person->id }
                    );
                }

                $self->_restore_constraints;
            }
        );
    }
}

# Select the membership that is within budget and meets as much of the person
# requirement as possible.
sub _qualifying_membership_type_for ( $self, @args ) {
    my $validator = validation_for(
        params => [
            year         => { type => AffiliationYear },
            num_people   => { type => PositiveOrZeroInt },
            donation_sum => { type => PositiveOrZeroNum },
        ],
        named_to_list => 1,
    );
    my ( $year, $num_people, $donation_sum ) = $validator->(@args);

    my @affordable_membership_types
        = $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year              => $year,
            membership_amount => { '<=' => $donation_sum }
        },
        { order_by => [ 'membership_max_people', 'membership_amount' ] },
    )->all;

    return undef if @affordable_membership_types == 0;
    return $affordable_membership_types[0]
        if @affordable_membership_types == 1;

    # At this point, we have multiple affordable membership types. Let's
    # narrow that list to see which one(s) support the number of people
    # required.
    my @qualifying_membership_types
        = grep { $_->membership_max_people >= $num_people }
        @affordable_membership_types;

    # ETL deficiency: We cannot determine memberships qualifying for senior
    # or student rates with only data from the Legacy DB. So, if an affiliation
    # has paid enough for the regular type of membership, we'll just assign
    # that. If an affiliation has only paid enough for the reduced cost
    # memberships, we'll assign that.
    if ( $num_people == 1 ) {
        my ($individual_membership)
            = grep { $_->membership_type eq $INDIVIDUAL_MEMBERSHIP }
            @qualifying_membership_types;
        return $individual_membership if $individual_membership;
    }
    elsif ( $num_people == 2 ) {
        my ($household_membership)
            = grep { $_->membership_type eq $HOUSEHOLD_MEMBERSHIP }
            @qualifying_membership_types;
        return $household_membership if $household_membership;
    }

    # Next, we'll take the cheapest membership that matches our person
    # requirement, if one exists. Note the caveat to this approach directly
    # above.
    my $cheapest_qualifying_membership = first {
        $_->membership_max_people >= $num_people
    }
    @qualifying_membership_types;
    return $cheapest_qualifying_membership if $cheapest_qualifying_membership;

    # At this point, we have one or more potential membership types, but none
    # of them meet our person requirement. Return the one that allows the most
    # people.
    return $affordable_membership_types[-1];
}

__PACKAGE__->meta->make_immutable;

1;
