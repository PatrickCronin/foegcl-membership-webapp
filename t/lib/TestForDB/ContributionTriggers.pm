package TestForDB::ContributionTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use Const::Fast qw( const );
use FOEGCL::Membership::Const qw( $INDIVIDUAL_MEMBERSHIP );
use Test::Fatal qw( exception );

with qw(
    FOEGCL::Membership::Role::HasWebAppSchema
    TestRole::GeneratesFixtures
);

const my $CURRENT_YEAR => [ gmtime(time) ]->[5] + 1900;

# Updates that move a contribution to another affiliation are blocked. (If
# needed, users can delete and create.) Updates that disqualify a membership's
# contribution sum requirement are blocked.
sub test_contribution_updates ( $self, @ ) {
    my ( $a1, $a2 ) = map { $self->_create_individual_membership } ( 1 .. 2 );

    like(
        exception {
            $a1->contributions->first->update(
                { affiliation_id => $a2->id } );
        },
        qr/You cannot move a contribution from one affiliation to another[.]/,
        'cannot move a contribution to a different affiliation',
    );

    is(
        exception {
            $a1->contributions->first->update(
                { amount => $a1->contributions->first->amount * 2 } );
        },
        undef,
        'can update contribution amounts if it does not affect membership eligibility',
    );

    like(
        exception {
            $a1->contributions->first->update(
                { amount => $a1->contributions->first->amount / 3 } );
        },
        qr/This update is prohibited because it would make the affiliation's total contribution amount less than what's required for its current membership type[.]/,
        'cannot update contribution amounts if it would affect membership eligibility',
    );
}

# Deletes that disqualify a membership's contribution sum requirement are blocked.
sub test_contribution_deletes ( $self, @ ) {
    my $a1 = $self->_create_individual_membership;

    $a1->create_related(
        'contributions',
        { amount => $a1->contributions->first->amount }
    );

    is(
        exception { $a1->contributions->first->delete },
        undef,
        'can delete a contribution if it does not affect membership eligibility',
    );

    like(
        exception { $a1->contributions->first->delete },
        qr/This delete is prohibited because it would make the affiliation's total contribution amount less than what's required for its current membership type[.]/,
        'cannot delete a contribution if it would affect membership eligibility',
    );
}

sub _create_individual_membership ( $self, @ ) {
    my $affiliation = $self->_create_affiliation;

    my $mtp
        = $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $CURRENT_YEAR,
            membership_type => $INDIVIDUAL_MEMBERSHIP,
        }
    )->one_row;

    $affiliation->create_related(
        'contributions',
        {
            amount => $mtp->membership_amount,
        }
    );

    my $person = $self->_create_person;

    $affiliation->create_related(
        'affiliation_people',
        {
            person_id => $person->id,
        }
    );

    $affiliation->update( { membership_type => $INDIVIDUAL_MEMBERSHIP } );

    return $affiliation;
}

__PACKAGE__->meta->make_immutable;

1;
