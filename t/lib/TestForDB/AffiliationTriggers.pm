package TestForDB::AffiliationTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const qw( $INDIVIDUAL_MEMBERSHIP );
use Test::Fatal qw( exception );

with qw(
    FOEGCL::Membership::Role::HasWebAppSchema
    TestRole::GeneratesFixtures
);

sub test_affiliation_inserts ( $self, @ ) {
    is(
        exception { $self->_create_affiliation },
        undef,
        'affiliations can be created without a membership type'
    );

    like(
        exception {
            $self->_create_affiliation(
                membership_type => $INDIVIDUAL_MEMBERSHIP )
        },
        qr/The affiliation cannot be created because the total contribution sum is not sufficient to support its membership type[.]/,
        'affiliations without contributions cannot be created',
    );
}

sub test_affiliation_updates ( $self, @ ) {
    my $affiliation;
    is(
        exception { $affiliation = $self->_create_affiliation },
        undef,
        'affiliation can be created in the current year'
    );

    my $membership_type;
    is(
        exception {
            $membership_type
                = $self->_schema->resultset('MembershipTypeParameter')
                ->search_rs(
                {
                    year            => $affiliation->year->year,
                    membership_type => $INDIVIDUAL_MEMBERSHIP
                }
                )->one_row
        },
        undef,
        'individual membership type can be retrieved for the current year'
    );

    like(
        exception {
            $affiliation->update(
                { membership_type => $INDIVIDUAL_MEMBERSHIP } )
        },
        qr/This change is prohibited because the total contribution sum is not sufficient to support the affiliation's new membership type[.]/,
        'affiliations cannot be updated to a membership type when contributions are insufficient',
    );

    is(
        exception {
            $affiliation->create_related(
                'contributions',
                { amount => $membership_type->membership_amount }
                )
        },
        undef,
        'A contribution can be added to an affiliation',
    );

    is(
        exception {
            $affiliation->update(
                { membership_type => $membership_type->membership_type } )
        },
        undef,
        'affiliations can be updated to a membership type when contributions are sufficient',
    );

    my @names = (
        { first_name => 'Testing 1', last_name => 'Person' },
        { first_name => 'Testing 2', last_name => 'Person' },
    );
    my @people;
    for my $name (@names) {
        is(
            exception {
                push @people, $self->_schema->resultset('Person')->create(
                    {
                        first_name       => $name->{first_name},
                        last_name        => $name->{last_name},
                        source_friend_id => 99,
                    }
                    )
            },
            undef,
            "person $name->{first_name} $name->{last_name} can be created"
        );
    }

    is(
        exception {
            $people[0]->create_related(
                'affiliation_people',
                { affiliation_id => $affiliation->id }
                )
        },
        undef,
        '1 person can be linked to an individual membership affiliation'
    );

    like(
        exception {
            $people[1]->create_related(
                'affiliation_people',
                { affiliation_id => $affiliation->id }
                )
        },
        qr/This affiliation cannot accommodate another person because it has reached its maximum person limit[.]/,
        '2 people cannot be linked to an individual membership affiliation'
    );
}

__PACKAGE__->meta->make_immutable;

1;
