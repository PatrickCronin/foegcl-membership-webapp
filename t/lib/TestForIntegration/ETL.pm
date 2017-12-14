package TestForIntegration::ETL;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const
    qw( $HOUSEHOLD_MEMERSHIP $INDIVIDUAL_MEMBERSHIP );
use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::ETL                                   ();
use FOEGCL::Membership::ETL::Friend::Addresses                ();
use FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations ();
use List::Util qw( min );
use List::MoreUtils qw( apply );
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::TestsDB',
);

sub test_startup ( $self, @ ) {
    if ( !$ENV{TEST_ETL} ) {
        $self->test_skip('TEST_ETL environment variable not set');
        return;
    }

    if ( !$ENV{TEST_PRIMARY_DB} ) {
        FOEGCL::Membership::ETL->new->run;
    }
}

sub test_setup ( $self, @ ) {

    my $test_method = $self->test_report->current_method;
    $self->test_skip('not now') if $test_method->name ne 'test_blast_email_list';
}

sub test_csz ( $self, @ ) {
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
                    city  => trim( $_->{City} ),
                    state => trim( $_->{State} ),
                    zip   => trim( $_->{PostalCode} ),
                    }
            } $self->_legacy_schema->resultset('CityStateZip')->hri->all
        ],
        'City, State and Zip transferred successfully'
    );
}

sub test_annual_donations ( $self, @ ) {
    my @migrated_annual_donations
        = $self->_schema->resultset('Donation')->search_rs(
        {},
        {
            select => [ { sum => 'amount' } ],
            as     => ['donation_sum'],
            join   => 'affiliation',
            '+select' => ['affiliation.affiliation_year'],
            '+as'     => ['affiliation_year'],
            group_by  => ['affiliation_year'],
        },
        )->hri->all;

    my %migrated = map { $_->{affiliation_year} => 0 + $_->{donation_sum} }
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
            '+select' =>
                [ 'affiliation.friend_id', 'affiliation.affiliation_year' ],
            '+as'    => [ 'FriendID',  'Year' ],
            group_by => [ 'friend_id', 'affiliation_year', ],
            order_by => [ 'friend_id', 'affiliation_year', ],
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

# For each person in the legacy database, make sure they're in the WebApp
# database
sub test_friend_to_people_details ( $self, @ ) {
    my $legacy_friend_rs = $self->_legacy_schema->resultset('Friend');
    while ( my $legacy_friend = $legacy_friend_rs->next ) {
        my @legacy_people;

        push @legacy_people, {
            friend_id  => $legacy_friend->friend_id,
            first_name => trim( $legacy_friend->first_name ),
            last_name  => trim( $legacy_friend->last_name ),
        };

        if (   $legacy_friend->spouse_first_name
            || $legacy_friend->spouse_last_name ) {
            push @legacy_people, {
                friend_id  => $legacy_friend->friend_id,
                first_name => trim( $legacy_friend->spouse_first_name ),
                last_name  => trim(
                           $legacy_friend->spouse_last_name
                        || $legacy_friend->last_name
                ),
            };
        }

        my $migrated_people_rs
            = $self->_schema->resultset('Person')->search_rs(
            { source_friend_id => $legacy_friend->friend_id },
            );

        is(
            $migrated_people_rs->count,
            scalar @legacy_people,
            'Expected number of people migrated',
        );

        foreach my $legacy_person (@legacy_people) {
            my $legacy_person_moniker = sprintf(
                '%s %s (in Friend %d)',
                $legacy_person->{first_name},
                $legacy_person->{last_name},
                $legacy_person->{friend_id}
            );

            subtest $legacy_person_moniker => sub {
                my $migrated_person_rs = $migrated_people_rs->search_rs(
                    {
                        first_name => $legacy_person->{first_name},
                        last_name  => $legacy_person->{last_name}
                    }
                );

                is(
                    $migrated_person_rs->count,
                    1,
                    "$legacy_person_moniker migrated"
                );

                _test_migrated_person(
                    $legacy_friend,
                    $migrated_person_rs->one_row
                );
                }
        }
    }
}

sub _test_migrated_person ( $legacy_friend, $migrated_person ) {
    _test_active( $legacy_friend, $migrated_person );
    _test_addresses( $legacy_friend, $migrated_person );
    _test_phones( $legacy_friend, $migrated_person );
    _test_emails( $legacy_friend, $migrated_person );
    _test_interests( $legacy_friend, $migrated_person );
}

sub _test_active ( $legacy_friend, $migrated_person ) {
    is(
        $migrated_person->opted_out,
        $legacy_friend->inactive,
        'person activity is the same'
    );
}

sub _test_addresses ( $legacy_friend, $migrated_person ) {
    my %address = (
        mailing_addresses  => [],
        physical_addresses => [],
    );

    ## no critic (Subroutines::ProtectPrivateSubs)
    my $csz = FOEGCL::Membership::ETL::Friend::Addresses->new
        ->_find_migrated_csz_for( $legacy_friend->city_state_zip );

    if ($csz) {
        %address
            = FOEGCL::Membership::ETL::Friend::Addresses::_addresses_from(
            $csz->id,
            FOEGCL::Membership::ETL::Friend::Addresses::_single_street_line_to_multiple_lines(
                $legacy_friend->address
            )
            );
    }
    ## use critic

    my $thin_address = sub ( $address ) {
        my %columns = $address->get_columns;
        return {
            %columns{
                grep { $address->$_ }
                    qw( street_line_1 street_line_2 csz_id )
            }
        };
    };

    eq_or_diff(
        [
            map { $thin_address->($_) }
                ( grep { defined $_ } $migrated_person->mailing_address )
        ],
        $address{mailing_addresses},
        'expected mailing addresses'
    );

    eq_or_diff(
        [
            map { $thin_address->($_) }
                ( grep { defined $_ } $migrated_person->physical_address )
        ],
        $address{physical_addresses},
        'expected physical addresses'
    );
}

sub _test_phones ( $legacy_friend, $migrated_person ) {
    my @migrated_phones = map {
        {
            phone        => $_->{phone_number},
            is_preferred => $_->{is_preferred},
        }
    } $migrated_person->person_phones->hri->all;

    my @legacy_phones = map {
        {
            phone => ( $_->{'Area Code'} // '518' ) . $_->{'Phone Number'}
                =~ s/\D//r,
            is_preferred => $_->{Preferred},
        }
        } $legacy_friend->contact_infos->search_rs(
        { 'Phone Number' => { '!=' => undef } } )->hri->all;

    eq_or_diff(
        [ sort { $a->{phone} cmp $b->{phone} } @migrated_phones ],
        [ sort { $a->{phone} cmp $b->{phone} } @legacy_phones ],
        'phone numbers are the same'
    );
}

sub _test_emails ( $legacy_friend, $migrated_person ) {
    my @migrated_emails = map {
        {
            email        => $_->{email_address},
            is_preferred => $_->{is_preferred},
        }
    } $migrated_person->person_emails->hri->all;

    my @legacy_emails = map {
        {
            email        => $_->{'Email_Address'},
            is_preferred => $_->{Preferred},
        }
        } $legacy_friend->contact_infos->search_rs(
        { 'Email_Address' => { '!=' => undef } } )->hri->all;

    eq_or_diff(
        [ sort { $a->{email} cmp $b->{email} } @migrated_emails ],
        [ sort { $a->{email} cmp $b->{email} } @legacy_emails ],
        'emails are the same'
    );
}

sub _test_interests ( $legacy_friend, $migrated_person ) {
    my @migrated_roles
        = map { $_->{role_name} }
        $migrated_person->participation_interests->search_related(
        'participation_role',
        {},
        { columns => ['role_name'] },
        )->hri->all;

    my @legacy_roles
        = map { trim( $_->{Role} ) } $legacy_friend->roles->search_related(
        'role_type',
        { Historical => 0 },
        { columns    => ['Role'] },
        )->hri->all;

    eq_or_diff(
        [ sort @migrated_roles ],
        [ sort @legacy_roles ],
        'interests are the same'
    );
}

sub test_affiliations ( $self, @ ) {

    # An affiliation should exist for each friend with a donation in a given
    # year.
    my @migrated_affiliations
        = $self->_schema->resultset('Affiliation')->search_rs(
        {},
        {
            select   => [qw( friend_id affiliation_year )],
            as       => [qw( friend_id year )],
            order_by => [qw(friend_id affiliation_year)]
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
        = FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new;

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
            my $expected_membership_donation_type
                = $membership_helper->_membership_donation_type_for(
                year         => $year,
                num_people   => $legacy_friend->num_people,
                donation_sum => $annual_donations{$year}
                );

            if ( $annual_donations{$year} > 0 ) {
                $expected_annual_membership_type{$year}
                    = $expected_membership_donation_type
                    ? $expected_membership_donation_type->donation_type
                    : undef;

                $annual_max_people{$year}
                    = $expected_membership_donation_type
                    ? $expected_membership_donation_type
                    ->membership_max_people
                    : 2;  # Affiliations without memberships are unrestrained,
                          # and 2 is the max number of poeple that can come
                          # from a friend.
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
    my %actual_annual_membership_type = map {
              $_->get_column('affiliation_year') => $_->membership
            ? $_->membership->donation_type
            : undef
        } $self->_schema->resultset('Affiliation')->search_rs(
        { friend_id => $legacy_friend->friend_id },
        { prefetch  => 'membership' },
        )->all;

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
                'affiliation_year',
                { count => 'affiliation_people.person_id' }
            ],
            as       => [ 'year', 'num_people' ],
            join     => 'affiliation_people',
            group_by => ['affiliation_year'],
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

sub test_blast_email_list ( $self, @ ) {
    my @migrated_blast_emails =
        sort
        map { $_->{email_address} }
        $self->_schema->resultset('BlastEmailList')->hri->all;

    my @legacy_blast_emails =
        sort
        map { $_->{Email_Address} }
        $self->_legacy_schema
            ->resultset('ActiveRecentlyDonatingMembershipEmailAddress')
            ->hri->all;

    eq_or_diff(
        \@migrated_blast_emails,
        \@legacy_blast_emails,
        'blast email lists are the same.'
    );
}

__PACKAGE__->meta->make_immutable;

1;
