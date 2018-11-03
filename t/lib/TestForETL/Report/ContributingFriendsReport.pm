package TestForETL::Report::ContributingFriendsReport;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::UsesLegacyDatabase',
    'FOEGCL::Membership::Role::UsesWebAppDatabase',
);

sub test_contributing_friends ( $self, @ ) {
    my $got = $self->_dbh->selectall_arrayref(<<'SQL');
        SELECT year, friend_id
        FROM report_contributing_friends_annual_friend_contribution_agg
        ORDER BY year, friend_id
SQL

    my $expected = $self->_legacy_dbh->selectall_arrayref(<<'SQL');
        SELECT DISTINCT Year, FriendID
        FROM Donations
        WHERE Donation > 0
        ORDER BY Year, FriendID
SQL

    eq_or_diff( $got, $expected, 'Contributing friends are equal' );
}

sub test_renewees ( $self, @ ) {
    my $got = $self->_dbh->selectall_arrayref(<<'SQL');
        SELECT year, renewee_friend_id
        FROM report_contributing_friends_renewees
        ORDER BY year, renewee_friend_id
SQL

    my $expected = $self->_legacy_dbh->selectall_arrayref(<<'SQL');
        SELECT Year, FriendID
        FROM DonatingMembershipRenewalsBase
        ORDER BY Year, FriendID
SQL

    eq_or_diff( $got, $expected, 'Renewee friends are identical' );
}

sub test_refreshees ( $self, @ ) {
    my $got = $self->_dbh->selectall_arrayref(<<'SQL');
        SELECT year, refreshee_friend_id
        FROM report_contributing_friends_refreshees
        ORDER BY year, refreshee_friend_id
SQL

    my $expected = $self->_legacy_dbh->selectall_arrayref(<<'SQL');
        SELECT Year, FriendID
        FROM DonatingMembershipReturneeBase
        ORDER BY Year, FriendID
SQL

    eq_or_diff( $got, $expected, 'Refreshee friends are identical' );
}

sub test_first_timers ( $self, @ ) {
    my $got = $self->_dbh->selectall_arrayref(<<'SQL');
        SELECT first_contribution_year, friend_id
        FROM report_contributing_friends_earliest_friend_contributions
        ORDER BY first_contribution_year, friend_id
SQL

    my $expected = $self->_legacy_dbh->selectall_arrayref(<<'SQL');
        SELECT [First Year], FriendID
        FROM DonatingMembershipFirstDonationYear
        ORDER BY [First Year], FriendID
SQL

    eq_or_diff( $got, $expected, 'First timer friends are identical' );
}

sub test_contributions ( $self, @ ) {
    my $got = $self->_dbh->selectall_arrayref(<<'SQL');
        SELECT year, friend_id, CAST(CAST(amount AS NUMERIC) AS FLOAT8) * 1
        FROM contribution
        INNER JOIN affiliation USING (affiliation_id)
        ORDER BY year, friend_id, amount
SQL

    my $expected = $self->_legacy_dbh->selectall_arrayref(<<'SQL');
        SELECT Year, FriendID, Donation
        FROM Donations
        WHERE Donation > 0
        ORDER BY Year, FriendID, Donation
SQL

    eq_or_diff(
        $got, $expected, 'Contributions are identical',
        { context => 3 }
    );
}

__PACKAGE__->meta->make_immutable;

1;
