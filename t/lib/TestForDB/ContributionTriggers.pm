package TestForDB::ContributionTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use Const::Fast qw( const );
use FOEGCL::Membership::Const qw( $INDIVIDUAL_MEMBERSHIP );
use Test::Fatal qw( exception );

with qw(
    FOEGCL::Membership::Role::HasWebAppSchema
    TestRole::GeneratesFixtures
);

sub test_contribution_inserts ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;
    is(
        exception {
            $self->_new_contribution(
                affiliation_id => $self->_create_basic_affiliation->id,
                amount         => 200
                )
        },
        undef,
        'can add a contribution to an affiliation'
    );

    is(
        exception {
            $self->_new_contribution(
                affiliation_id => $affiliation->id,
                amount         => 10,
                received       => $affiliation->year . '-01-01',
                )
        },
        undef,
        q{contribution received date can be the same as the affiliations'},
    );

    like(
        exception {
            $self->_new_contribution(
                affiliation_id => $affiliation->id,
                amount         => 10,
                received       => ( $affiliation->year - 1 ) . '-01-01',
                )
        },
        qr/recieved date in a different year/,
        q{contribution received date cannot be different than the affiliations'},
    );
}

sub test_affiliation_contribution_updates ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;

    is(
        exception {
            $affiliation->contributions->first->update(
                { amount => $affiliation->contributions->first->amount / 2 } )
        },
        undef,
        'can update affiliation contribution amounts'
    );

    is(
        exception {
            $affiliation->contributions->first->update(
                { received => $affiliation->year . '-01-01' } ),
        },
        undef,
        q{contribution received date can be the same as the affiliations'},
    );

    like(
        exception {
            $affiliation->contributions->first->update(
                { received => ( $affiliation->year - 1 ) . '-01-01' } ),
        },
        qr/recieved date in a different year/,
        q{contribution received date cannot differ from the affiliations'},
    );
}

sub test_membership_contribution_updates ( $self, @ ) {
    my $membership = $self->_create_individual_membership;

    is(
        exception {
            $membership->contributions->first->update(
                { amount => $membership->contributions->first->amount * 2 } );
        },
        undef,
        'can update contribution amounts if it does not affect membership eligibility',
    );

    like(
        exception {
            $membership->contributions->first->update(
                { amount => $membership->contributions->first->amount / 3 } );
        },
        qr/without enough contributions/,
        'cannot update contribution amounts if it would affect membership eligibility',
    );
}

sub test_affiliation_contribution_deletes ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;

    like(
        exception { $affiliation->contributions->first->delete },
        qr/without any contributions/,
        q{cannot delete an affiliation's last contribution},
    );

    $affiliation->create_related(
        'contributions',
        { amount => $affiliation->contributions->first->amount }
    );

    is(
        exception { $affiliation->contributions->first->delete },
        undef,
        q{can delete a contribution if it is not the affiliation's last},
    );
}

# Deletes that disqualify a membership's contribution sum requirement are blocked.
sub test_membership_contribution_deletes ( $self, @ ) {
    my $membership = $self->_create_individual_membership;

    like(
        exception {
            my $amount
                = $membership->membership_type_parameter->membership_amount
                / 2;
            $membership->create_related(
                'contributions',
                { amount => $amount }
            );
            $membership->contributions->search_rs(
                { amount => { '!=' => $amount } } )->delete;
        },
        qr/without enough contributions/,
        'cannot remove a necessary contribution from a membership'
    );
}

__PACKAGE__->meta->make_immutable;

1;
