package TestFor::FOEGCL::Membership::ETL;

use FOEGCL::Membership::Test::Class::Moose;

use DBI qw(:sql_types);
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasSchema',
    'FOEGCL::Membership::Role::TestsDB',
);

sub test_startup ( $self, @ ) {
    $self->test_skip('TEST_ETL environment variable not set')
      if !$ENV{TEST_ETL};
}

sub test_setup ( $self, @ ) {
    my $test_method = $self->test_report->current_method;

# $self->test_skip('not now') if $test_method->name ne 'test_annual_membership_count';
}

sub test_city_state_zip ( $self, @ ) {
    eq_or_diff(
        [
            map {
                +{
                    city  => $_->{city},
                    state => $_->{state_abbr},
                    zip   => $_->{zip},
                  }
            } $self->_schema->resultset('CityStateZip')->hri->all
        ],
        [
            map {
                +{
                    city  => $_->{City},
                    state => $_->{State},
                    zip   => $_->{PostalCode},
                  }
            } $self->_legacy_schema->resultset('CityStateZip')->hri->all
        ],
        'City, State and Zip transferred successfully'
    );
}

sub test_annual_donation_sum ($self) {
    my $new_annual_donations_rs =
      $self->_schema->resultset('Donation')->search(
        {},
        {
            select => [ 'affiliation_year', { sum => 'amount' } ],
            as       => [qw( affiliation_year donation_sum )],
            group_by => [qw(affiliation_year)],
        },
      );

    my %new;
    while ( my $donation = $new_annual_donations_rs->next ) {
        $new{ $donation->get_column('affiliation_year') } =
          0 + $donation->get_column('donation_sum');
    }

    my $legacy_annual_donations_rs =
      $self->_legacy_schema->resultset('Donation')->search(
        {},
        {
            select   => [ 'year', { sum => 'donation' } ],
            as       => [qw( year donation_sum )],
            group_by => [qw( year )]
        },
      );

    my %legacy;
    while ( my $donation = $legacy_annual_donations_rs->next ) {
        $legacy{ $donation->get_column('year') } =
          0 + $donation->get_column('donation_sum');
    }

    eq_or_diff( \%new, \%legacy, 'Annual donation sums are equal' );
}

sub test_annual_membership_count ( $self, @ ) {
    my $years =
      $self->_legacy_schema->storage->dbh->selectcol_arrayref(<<'SQL');
    SELECT DISTINCT year
    FROM Donations
SQL

    for my $year ( @{$years} ) {
        my $minimum_donation =
          0 +
          $self->_schema->resultset('AffiliationYearMembershipLevel')->find(
            { affiliation_year => $year },
            {
                select => [ { min => 'amount' } ],
                as     => ['min_membership_amount'],
            },
          )->get_column('min_membership_amount');

        my $legacy_membership_sth =
          $self->_legacy_schema->storage->dbh->prepare(<<'SQL');
    SELECT FriendID, SUM(Donation)
    FROM Donations
    WHERE Year = ?
    GROUP BY FriendID
    HAVING SUM(Donation) >= ?
    ORDER BY FriendID
SQL

        $legacy_membership_sth->bind_param( 1, $year,             SQL_NUMERIC );
        $legacy_membership_sth->bind_param( 2, $minimum_donation, SQL_NUMERIC );
        $legacy_membership_sth->execute;
        my $legacy_membership =
          [ map { $_->[0] } $legacy_membership_sth->fetchall_arrayref->@* ];

        eq_or_diff(
            [
                $self->_schema->resultset('Donation')->search(
                    { affiliation_year => $year, is_for_membership => 1 },
                    {
                        '+select' => 'affiliation.legacy_friend_id',
                        '+as'     => 'legacy_friend_id',
                        join      => [qw( donation_type affiliation )],
                        order_by  => 'legacy_friend_id',
                    },
                )->get_column('legacy_friend_id')->all
            ],
            $legacy_membership,

            # \@other_legacy_membership,
            "Membership agrees for $year"
        );
    }
}

sub test_friend_emails ( $self, @ ) {

    # First, test the set of emails for each Friend ID is the same.
    eq_or_diff(
        [
            $self->_legacy_schema->resultset('Friend')->search_rs(
                { email_address => { '!=' => undef } },
                {
                    columns => [ 'friend_id', 'email_address' ],
                    join    => 'ContactInfo'
                }
            )->all
        ],
        [

        ],
        'Friend email addresses match'
    );

    # Then, test the email for each Person in the WebApp
}

__PACKAGE__->meta->make_immutable;

1;
