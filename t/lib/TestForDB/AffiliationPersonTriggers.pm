package TestForDB::AffiliationPersonTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Fatal 'exception';

with qw(
    FOEGCL::Membership::Role::UsesWebAppDatabase
    TestRole::GeneratesFixtures
);

sub test_affiliation_person_inserts ( $self, @ ) {
    is(
        exception {
            $self->_new_person_for_affiliation(
                $self->_create_basic_affiliation );
        },
        undef,
        'can add a person to an affiliation'
    );

    my $membership = $self->_create_household_membership;
    like(
        exception {
            $self->_new_person_for_affiliation($membership);
            $self->_new_person_for_affiliation($membership);
        },
        qr/with more people/,
        'cannot add a person to a full membership'
    );
}

sub test_affiliation_person_deletes ( $self, @ ) {
    like(
        exception {
            $self->_create_basic_affiliation->affiliation_people->delete;
        },
        qr/without any people/,
        'Removing all people from an affiliation raises an exception'
    );

    is(
        exception {
            $self->_create_household_membership->affiliation_people->first
                ->delete;
        },
        undef,
        'can remove a person from a full household membership'
    );
}

__PACKAGE__->meta->make_immutable;

1;
