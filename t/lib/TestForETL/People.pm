package TestForETL::People;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::ETL::Friend::Addresses ();
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasWebAppSchema',
);

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
            };
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

__PACKAGE__->meta->make_immutable;

1;
