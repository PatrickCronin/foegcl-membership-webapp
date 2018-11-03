package TestForETL::Contributions;

use FOEGCL::Membership::Test::Class::Moose;

use List::MoreUtils qw( apply );
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::UsesLegacyDatabase',
    'FOEGCL::Membership::Role::UsesWebAppDatabase',
);

sub test_annual_contributions ( $self, @ ) {
    my @migrated_annual_contributions
        = $self->_schema->resultset('Contribution')->search_rs(
        {},
        {
            select    => [ { sum => 'amount' } ],
            as        => ['contribution_sum'],
            join      => 'affiliation',
            '+select' => ['affiliation.year'],
            '+as'     => ['year'],
            group_by  => ['year'],
        },
    )->hri->all;

    my %migrated = map { $_->{year} => 0 + $_->{contribution_sum} }
        @migrated_annual_contributions;

    my @legacy_annual_contributions
        = $self->_legacy_schema->resultset('Donation')->search_rs(
        {},
        {
            select   => [ 'year', { sum => 'donation' } ],
            as       => [ 'year', 'donation_sum' ],
            group_by => ['year'],
        },
    )->hri->all;

    my %legacy = map { $_->{year} => 0 + $_->{donation_sum} }
        @legacy_annual_contributions;

    eq_or_diff( \%migrated, \%legacy, 'Annual contribution sums are equal' );
}

sub test_annual_contributions_per_friend ( $self, @ ) {
    my @migrated_affiliation_contribution_aggregates
        = apply { $_->{Annualcontribution} += 0 }
    $self->_schema->resultset('Contribution')->search_rs(
        {},
        {
            select    => [ { sum => 'amount' } ],
            as        => ['Annualcontribution'],
            join      => 'affiliation',
            '+select' => [ 'affiliation.friend_id', 'affiliation.year' ],
            '+as'     => [ 'FriendID', 'Year' ],
            group_by  => [ 'friend_id', 'year', ],
            order_by  => [ 'friend_id', 'year', ],
        }
    )->hri->all;

    my @legacy_friend_donation_aggregates
        = $self->_legacy_schema->resultset('Donation')->search_rs(
        {},
        {
            select => [ 'FriendID', 'Year', { sum => 'donation' } ],
            as       => [ 'FriendID', 'Year', 'Annualcontribution' ],
            group_by => [ 'FriendID', 'Year' ],
            having   => \[ 'sum(donation) > ?', 0 ],
            order_by => [ 'FriendID',           'Year' ],
        }
    )->hri->all;

    eq_or_diff(
        \@migrated_affiliation_contribution_aggregates,
        \@legacy_friend_donation_aggregates,
        'Annual contributions for all Friends are equal'
    );
}

__PACKAGE__->meta->make_immutable;

1;
