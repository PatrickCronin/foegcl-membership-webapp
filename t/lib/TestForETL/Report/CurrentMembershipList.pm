package TestForETL::Report::CurrentMembershipList;

use FOEGCL::Membership::Test::Class::Moose;

use Const::Fast 'const';
use FOEGCL::Membership::Const qw(
    $SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP
    $SENIOR_HOUSEHOLD_MEMBERSHIP
);
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::UsesLegacyDatabase',
    'FOEGCL::Membership::Role::UsesWebAppDatabase',
);

const my $CURRENT_YEAR => (localtime)[5] + 1900;

# Test that each expected person in the Legacy report is found in the WebApp
# report
sub test_members ( $self, @ ) {
    my @actual_members
        = map { [ $_->@{qw( friend_id first_name last_name )} ] }
        $self->_schema->resultset('CurrentMembershipList')->search_rs(
        undef,
        {
            columns  => [qw( friend_id first_name last_name )],
            order_by => [qw( friend_id last_name first_name )],
        }
    )->hri->all;

    # Get the membership amounts to know which legacy people to ignore
    my $mtp
        = $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $CURRENT_YEAR,
            membership_type => {
                -in => [
                    $SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP,
                    $SENIOR_HOUSEHOLD_MEMBERSHIP
                ]
            }
        },
        {
            columns => [qw( membership_type membership_amount )],
        }
    )->hri;

    my %min_amount;
    while ( my $type = $mtp->next ) {
        $min_amount{ $type->{membership_type} } = $type->{membership_amount};
    }

    # Take the primary member if the friend donation sum is equal to or
    # greater than the senior individual contribution amount for the year.
    # Note this pulls from Friend instead of
    # AllFriendsContactInfo-PrimaryOnly. This is a poor substitute, but for
    # some reason, queries built with Pivot Tables in Access are not
    # accessible from DBD::ADO's ->tables method, and are thus not created by
    # DBIx::Class::Schema::Loader.
    my @expected_primaries
        = $self->_legacy_schema->resultset('Friend')->search_rs(
        { 'donations.Year' => $CURRENT_YEAR },
        {
            columns  => [qw( FriendID FirstName LastName )],
            join     => 'donations',
            group_by => [qw( me.FriendID FirstName LastName )],
            having   => \[
                'SUM([donations].[Donation]) >= ?',
                $min_amount{$SENIOR_STUDENT_INDIVIDUAL_MEMBERSHIP} * 1
            ],
        }
    )->hri->all;

    # Take the spouse member if the friend donation sum is equal to or greater
    # than the the senior household contribution amount for the year.
    # Note this pulls from Friend instead of
    # AllFriendsContactInfo-SpouseOnly.
    my @expected_spouses
        = $self->_legacy_schema->resultset('Friend')->search_rs(
        {
            'donations.Year'  => $CURRENT_YEAR,
            'SpouseFirstName' => { '<>' => q{} },
            'SpouseLastName'  => { '<>' => q{} },
        },
        {
            'select' => [qw( FriendID SpouseFirstName SpouseLastName )],
            'as'     => [qw( FriendID FirstName LastName )],
            join     => 'donations',
            group_by => [qw( me.FriendID SpouseFirstName SpouseLastName )],
            having   => \[
                'SUM([donations].[Donation]) >= ?',
                $min_amount{$SENIOR_HOUSEHOLD_MEMBERSHIP} * 1
            ],
        }
    )->hri->all;

    my @expected_members
        = map { [ $_->@{qw( FriendID FirstName LastName )} ] }
        sort {
               $a->{FriendID} <=> $b->{FriendID}
            || $a->{LastName} cmp $b->{LastName}
            || $a->{FirstName} cmp $b->{FirstName}
        } ( @expected_primaries, @expected_spouses );

    eq_or_diff(
        \@actual_members,
        \@expected_members,
        'membership people as expected'
    );
}

__PACKAGE__->meta->make_immutable;

1;
