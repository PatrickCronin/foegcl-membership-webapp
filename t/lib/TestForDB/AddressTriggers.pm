package TestForDB::AddressTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Fatal 'exception';

with qw(
    FOEGCL::Membership::Role::HasWebAppSchema
    TestRole::GeneratesFixtures
);

sub test_special_library_voting_district ( $self, @ ) {
    my $affiliation      = $self->_create_basic_affiliation;
    my $physical_address = $self->_new_physical_address_for_person(
        $affiliation->affiliation_people->first->person );
    $physical_address
        ->discard_changes;    # Get the library flag as set by the trigger

    is(
        $physical_address->in_library_special_voting_district,
        'unchecked',
        'on physical address creation, the library special voting district field is unchecked',
    );

    $physical_address->update(
        {
            in_library_special_voting_district => 'in',
        }
    );

    is(
        $physical_address->in_library_special_voting_district,
        'in',
        'physical address updates specifying the library special voting district flag will set it'
    );

    $physical_address->update(
        {
            street_line_1 => '3 Main Street',
        }
    );
    $physical_address
        ->discard_changes;    # Get the library flag as set by the trigger

    is(
        $physical_address->in_library_special_voting_district,
        'unchecked',
        'physical address updates not specifying the library special voting district flag will clear it'
    );
}

sub test_single_member_affiliation_person_address_inserts ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;

    is(
        exception {
            $self->_new_mailing_address_for_person(
                $affiliation->affiliation_people->first->person )
        },
        undef,
        q{a single-member affiliation's person can change their mailing address without problem},
    );

    is(
        exception {
            $self->_new_physical_address_for_person(
                $affiliation->affiliation_people->first->person )
        },
        undef,
        q{a single-member affiliation's person can change their physical address without problem},
    );
}

sub test_multi_member_affiliation_person_address_inserts ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;
    $self->_new_person_for_affiliation($affiliation);

    # Current Year
    like(
        exception {
            $self->_new_physical_address_for_person(
                $affiliation->affiliation_people->first->person )
        },
        qr/multiple physical addresses/,
        q{person's physical address cannot be changed when other members' remain},
    );

    like(
        exception {
            $self->_new_mailing_address_for_person(
                $affiliation->affiliation_people->first->person )
        },
        qr/multiple mailing addresses/,
        q{person's mailing address cannot be changed when other members' remain},
    );

    is(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    $self->_new_physical_address_for_person( $_->person )
                        for $affiliation->affiliation_people;
                    $self->_restore_constraints;
                }
                )
        },
        undef,
        q{an affiliation's physical addresses can be changed as long as all members' addresses are updated together}
    );

    is(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    $self->_new_mailing_address_for_person( $_->person )
                        for $affiliation->affiliation_people;
                    $self->_restore_constraints;
                }
                )
        },
        undef,
        q{an affiliation's mailing addresses can be changed as long as all members' addresses are updated together}
    );

    # Now, test a past year
    $self->_schema->storage->txn_do(
        sub {
            my $previous_year = $affiliation->year->year - 1;
            $self->_defer_constraints;
            $affiliation->update( { year => $previous_year } );
            $affiliation->contributions->update(
                { received => "${previous_year}-01-01" } );
            $self->_restore_constraints;
        }
    );

    is(
        exception {
            $affiliation->affiliation_people->first->person->physical_address
                ->delete;
        },
        undef,
        'members of past-year multi-member affiliations may have differing physical addresses',
    );

    is(
        exception {
            $affiliation->affiliation_people->first->person->mailing_address
                ->delete;
        },
        undef,
        'members of past-year multi-member affiliations may have differing mailing addresses',
    );
}

__PACKAGE__->meta->make_immutable;

1;
