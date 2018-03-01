package TestForETL::Donations;

use FOEGCL::Membership::Test::Class::Moose;

use List::MoreUtils qw( apply );
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasWebAppSchema',
    'TestRole::TestsETL',
);

sub test_annual_donations ( $self, @ ) {
    my @migrated_annual_donations
        = $self->_schema->resultset('Donation')->search_rs(
        {},
        {
            select    => [ { sum => 'amount' } ],
            as        => ['donation_sum'],
            join      => 'affiliation',
            '+select' => ['affiliation.year'],
            '+as'     => ['year'],
            group_by  => ['year'],
        },
        )->hri->all;

    my %migrated = map { $_->{year} => 0 + $_->{donation_sum} }
        @migrated_annual_donations;

    my @legacy_annual_donations
        = $self->_legacy_schema->resultset('Donation')->search_rs(
        {},
        {
            select   => [ 'year', { sum => 'donation' } ],
            as       => [ 'year', 'donation_sum' ],
            group_by => ['year'],
        },
        )->hri->all;

    my %legacy = map { $_->{year} => 0 + $_->{donation_sum} }
        @legacy_annual_donations;

    eq_or_diff( \%migrated, \%legacy, 'Annual donation sums are equal' );
}

sub test_annual_donations_per_friend ( $self, @ ) {
    my @migrated_affiliation_donation_aggregates
        = apply { $_->{AnnualDonation} += 0 }
    $self->_schema->resultset('Donation')->search_rs(
        {},
        {
            select => [ { sum => 'amount' } ],
            as     => ['AnnualDonation'],
            join   => 'affiliation',
            '+select' => [ 'affiliation.friend_id', 'affiliation.year' ],
            '+as'     => [ 'FriendID',              'Year' ],
            group_by  => [ 'friend_id',             'year', ],
            order_by  => [ 'friend_id',             'year', ],
        }
    )->hri->all;

    my @legacy_friend_donation_aggregates
        = $self->_legacy_schema->resultset('Donation')->search_rs(
        {},
        {
            select => [ 'FriendID', 'Year', { sum => 'Donation' } ],
            as       => [ 'FriendID',           'Year', 'AnnualDonation' ],
            group_by => [ 'FriendID',           'Year' ],
            having   => \[ 'sum(Donation) > ?', 0 ],
            order_by => [ 'FriendID',           'Year' ],
        }
        )->hri->all;

    eq_or_diff(
        \@migrated_affiliation_donation_aggregates,
        \@legacy_friend_donation_aggregates,
        'Annual donations for all Friends are equal'
    );
}

__PACKAGE__->meta->make_immutable;

1;
