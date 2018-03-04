package TestForETL::Affiliations;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions ();
use List::Util qw( min );
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasWebAppSchema',
    'TestRole::TestsETL',
);

sub test_affiliations ( $self, @ ) {

    # An affiliation should exist for each friend with a non-zero donation
    # in a given year.
    my @migrated_affiliations
        = $self->_schema->resultset('Affiliation')->search_rs(
        {},
        {
            select   => [qw( friend_id year )],
            as       => [qw( friend_id year )],
            order_by => [qw( friend_id year )],
        }
        )->hri->all;
    my %migrated_friend_affiliations;
    push $migrated_friend_affiliations{ $_->{friend_id} }->@*, $_->{year}
        for @migrated_affiliations;

    my @legacy_affiliations
        = $self->_legacy_schema->resultset('Donation')->search_rs(
        {
            donation => { '>' => 0 },
        },
        {
            select   => [qw( FriendID Year )],
            as       => [qw( friend_id year )],
            group_by => [qw( FriendID Year )],
        }
        )->hri->all;
    my %legacy_friend_affiliations;
    push $legacy_friend_affiliations{ $_->{friend_id} }->@*, $_->{year}
        for @legacy_affiliations;

    eq_or_diff(
        \%migrated_friend_affiliations,
        \%legacy_friend_affiliations,
        'affiliations exist for each friend donation year'
    );
}

sub test_memberhips ( $self, @ ) {
    my $membership_helper
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions->new;

    my $legacy_friend_rs = $self->_legacy_schema->resultset('Friend');
    while ( my $legacy_friend = $legacy_friend_rs->next ) {
        my %annual_donations
            = map { $_->{year} => $_->{total_donations} }
            $legacy_friend->donations->search_rs(
            {},
            {
                select   => [ 'year', { sum => 'donation' } ],
                as       => [ 'year', 'total_donations' ],
                group_by => ['year'],
            }
            )->hri->all;

        my %annual_max_people;
        my %expected_annual_membership_type;
        for my $year ( keys %annual_donations ) {
            my $expected_membership_type
                = $membership_helper->_qualifying_membership_type_for(
                year         => $year,
                num_people   => $legacy_friend->num_people,
                donation_sum => $annual_donations{$year}
                );

            if ( $annual_donations{$year} > 0 ) {
                $expected_annual_membership_type{$year}
                    = $expected_membership_type
                    ? $expected_membership_type->membership_type
                    : undef;

                $annual_max_people{$year}
                    = $expected_membership_type
                    ? $expected_membership_type->membership_max_people
                    : 2;    # Affiliations with null memberships are
                            # unrestrained, and 2 is the max number of poeple
                            # that can come from a friend.
            }
        }

        $self->_test_membership_types(
            $legacy_friend,
            %expected_annual_membership_type
        );
        $self->_test_membership_num_people(
            $legacy_friend,
            %annual_max_people
        );
    }
}

## no critic (Subroutines::ProhibitManyArgs)
sub _test_membership_types (
    $self, $legacy_friend,
    %expected_annual_membership_type
    ) {
    ## use critic
    my %actual_annual_membership_type
        = map { $_->{year} => $_->{membership_type} }
        $self->_schema->resultset('Affiliation')->search_rs(
        { friend_id => $legacy_friend->friend_id },
        )->hri->all;

    eq_or_diff(
        \%actual_annual_membership_type,
        \%expected_annual_membership_type,
        sprintf(
            'annual membership types agree for friend %d',
            $legacy_friend->friend_id
        )
    );
}

## no critic (Subroutines::ProhibitManyArgs)
sub _test_membership_num_people ( $self, $legacy_friend, %annual_max_people )
{
    ## use critic
    my %actual_annual_num_people
        = map { $_->{year} => $_->{num_people} }
        $self->_schema->resultset('Affiliation')->search_rs(
        { friend_id => $legacy_friend->friend_id, },
        {
            select => [
                'year',
                { count => 'affiliation_people.person_id' }
            ],
            as       => [ 'year', 'num_people' ],
            join     => 'affiliation_people',
            group_by => ['year'],
        }
        )->hri->all;

    my %expected_annual_num_people = map {
        $_ => min(
            $legacy_friend->num_people,
            exists $annual_max_people{$_} ? $annual_max_people{$_} : 2
            )
    } keys %annual_max_people;

    eq_or_diff(
        \%actual_annual_num_people,
        \%expected_annual_num_people,
        sprintf(
            'number of people in annual memberships agree for friend %d',
            $legacy_friend->friend_id
        )
    );
}

__PACKAGE__->meta->make_immutable;

1;
