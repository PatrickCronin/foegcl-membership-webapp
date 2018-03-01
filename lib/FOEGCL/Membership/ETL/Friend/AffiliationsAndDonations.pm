package FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations;

# ABSTRACT: Extract, transform and load a Friend's annual affiliations and donations

use FOEGCL::Membership::Moose;

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
    my %donations_by_year = partition_by { $_->year }
    $legacy_friend->donations->all;

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

        # Create the affiliation
        my $affiliation = $self->_schema->resultset('Affiliation')->create(
            {
                year      => $year,
                friend_id => $legacy_friend->friend_id,
            }
        );

        # Relate the donations to the membership
        my $donation_rs = $self->_schema->resultset('Donation');
        foreach my $amount (@donation_amounts) {
            $donation_rs->create(
                {
                    affiliation_id => $affiliation->id,
                    amount         => $amount,
                }
            );
        }

        # We are now safe to apply the membership type
        $affiliation->update(
            { membership_type => $membership_type->membership_type } )
            if $membership_type;

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

            $person->create_related(
                'affiliation_people',
                { affiliation_id => $affiliation->id }
            );
        }
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

    my @potential_membership_types
        = $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        { membership_amount => { '<=' => $donation_sum } },
        { order_by          => 'membership_max_people' },
        )->all;

    return undef if @potential_membership_types == 0;
    return $potential_membership_types[0]
        if @potential_membership_types == 1;

    # At this point, we have multiple potential membership types.
    # First check if there's one that meets our person requirement, and if so,
    # return it.

    my $smallest_qualifying_membership
        = first { $_->membership_max_people >= $num_people }
    @potential_membership_types;
    return $smallest_qualifying_membership
        if $smallest_qualifying_membership;

    # At this point, we have multiple potential membership types, and none of
    # them meet our person requirement. Return the one that allows the most
    # people.

    return $potential_membership_types[-1];
}

__PACKAGE__->meta->make_immutable;

1;
