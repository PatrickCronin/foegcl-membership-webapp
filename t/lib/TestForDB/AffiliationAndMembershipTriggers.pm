package TestForDB::AffiliationAndMembershipTriggers;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Const
    qw( $HOUSEHOLD_MEMBERSHIP $INDIVIDUAL_MEMBERSHIP );
use Test::Fatal 'exception';

with qw(
    FOEGCL::Membership::Role::UsesWebAppDatabase
    TestRole::GeneratesFixtures
);

sub test_affiliation_inserts ( $self, @ ) {
    my $create_affiliation = sub { $self->_new_affiliation };
    my $create_person_for_affiliation
        = sub { $self->_new_person_for_affiliation(shift) };
    my $create_contribution_for_affiliation
        = sub { $self->_new_contribution( affiliation_id => shift->id ) };

    {
        my $required_steps = sub {
            my $affiliation = $create_affiliation->();
            $create_person_for_affiliation->($affiliation);
            $create_contribution_for_affiliation->($affiliation);
        };

        is(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        $required_steps->();
                    }
                )
            },
            undef,
            'affiliations can be created when constraints are deferred'
        );

        like(
            exception { $required_steps->() },
            qr/without any people/,
            'affiliations cannot be created without deferred constraints'
        );
    }

    like(
        exception { $self->_schema->storage->txn_do($create_affiliation) },
        qr/without any people/,
        'affiliations cannot be created without any people'
    );

    like(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    $create_person_for_affiliation->(
                        $create_affiliation->() );
                    $self->_restore_constraints;
                }
            );
        },
        qr/without any contributions/,
        'affiliations cannot be created without any contributions'
    );
}

sub test_affiliation_updates ( $self, @ ) {
    my $affiliation = $self->_create_basic_affiliation;

    like(
        exception {
            $affiliation->update( { year => $affiliation->year - 1 } );
        },
        qr/recieved date in a different year/,
        'cannot update an affiliiation year without contribution dates received',
    );
    $affiliation->discard_changes
        ;    # The trigger blocked this operation, but DBIC didn't know...

    is(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    my $previous_year = $affiliation->year - 1;
                    $self->_defer_constraints;
                    $affiliation->contributions->update(
                        { received => "${previous_year}-01-01" } );
                    $affiliation->update( { year => $previous_year } );
                    $self->_restore_constraints;
                }
            )
        },
        undef,
        'can update an affiliation year when contribution dates received are also updated',
    );

    # Attempt to upgrade an affiliation without enough contributions to an
    # individual membership
    like(
        exception {
            $affiliation->update(
                { membership_type => $INDIVIDUAL_MEMBERSHIP } )
        },
        qr/enough contributions/,
        'cannot promote an affiliation when the contributions are not enough'
    );

    $self->_new_contribution(
        affiliation_id => $affiliation->id,
        amount =>
            $self->_membership_type_parameter($INDIVIDUAL_MEMBERSHIP)
            ->membership_amount
            - $affiliation->contributions->get_column('amount')->sum,
        received => $affiliation->year . '-01-01',
    );

    # Attempt to upgrade an affiliation with too many people to an
    # individual membership
    $self->_new_person_for_affiliation($affiliation);

    like(
        exception {
            $affiliation->update(
                { membership_type => $INDIVIDUAL_MEMBERSHIP } )
        },
        qr/with more people/,
        'cannot promote an affiliation when the people are too many'
    );

    $affiliation->affiliation_people->first->delete;

    is(
        exception {
            $affiliation->update(
                { membership_type => $INDIVIDUAL_MEMBERSHIP } )
        },
        undef,
        'can promote an affiliation when the contributions are enough and the people are not too many'
    );
}

sub test_membership_inserts ( $self, @ ) {
    my $mtp = $self->_membership_type_parameter($HOUSEHOLD_MEMBERSHIP);
    my $create_membership = sub {
        $self->_new_affiliation( membership_type => $mtp->membership_type );
    };
    my $create_people_for_membership
        = sub ( $membership, $num_people = $mtp->membership_max_people ) {
        $self->_new_person_for_affiliation($membership) for 1 .. $num_people;
        };
    my $create_contribution_for_membership
        = sub ( $membership, $amount = $mtp->membership_amount ) {
        $self->_new_contribution(
            affiliation_id => $membership->id,
            amount         => $amount
        );
        };

    {
        my $required_steps = sub {
            my $membership = $create_membership->();
            $create_people_for_membership->($membership);
            $create_contribution_for_membership->($membership);
        };

        is(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        $required_steps->();
                    }
                )
            },
            undef,
            'memberships can be created when constraints are deferred'
        );

        like(
            exception { $required_steps->() },
            qr/without any people/,
            'memberships cannot be created without deferred constraints'
        );
    }

    like(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    my $membership = $create_membership->();
                    $create_people_for_membership->(
                        $membership,
                        $mtp->membership_max_people + 1
                    );
                    $create_contribution_for_membership->($membership);
                    $self->_restore_constraints;
                }
            )
        },
        qr/with more people/,
        'memberships cannot be created with too many people'
    );

    like(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    my $membership = $create_membership->();
                    $create_people_for_membership->($membership);
                    $create_contribution_for_membership->(
                        $membership,
                        $mtp->membership_amount - 1
                    );
                    $self->_restore_constraints;
                }
            )
        },
        qr/without enough contributions/,
        'memberships cannot be created without sufficient contributions'
    );

    {
        my $required_steps = sub {
            my $membership = $create_membership->();
            $create_people_for_membership->($membership);
            $create_contribution_for_membership->($membership);
            $membership;
        };

        like(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        my $membership = $required_steps->();
                        $self->_new_physical_address_for_person(
                            $membership->affiliation_people->first->person,
                        );
                        $self->_restore_constraints;
                    }
                )
            },
            qr/multiple physical addresses/,
            'memberships of the current year cannot be created when the members have different physical addresses'
        );

        like(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        my $membership = $required_steps->();
                        $self->_new_mailing_address_for_person(
                            $membership->affiliation_people->first->person,
                        );
                        $self->_restore_constraints;
                    }
                )
            },
            qr/multiple mailing addresses/,
            'memberships of the current year cannot be created when the members have different mailing addresses'
        );

        is(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        my $membership    = $required_steps->();
                        my $previous_year = $membership->year - 1;
                        $membership->update( { year => $previous_year } );
                        $membership->contributions->update(
                            {
                                received => "${previous_year}-01-01",
                            }
                        );
                        $self->_new_physical_address_for_person(
                            $membership->affiliation_people->first->person,
                        );
                        $self->_restore_constraints;
                    }
                )
            },
            undef,
            'memberships of previous years can be created when the members have different physical addresses'
        );

        is(
            exception {
                $self->_schema->storage->txn_do(
                    sub {
                        $self->_defer_constraints;
                        my $membership    = $required_steps->();
                        my $previous_year = $membership->year - 1;
                        $membership->update( { year => $previous_year } );
                        $membership->contributions->update(
                            {
                                received => "${previous_year}-01-01",
                            }
                        );
                        $self->_new_mailing_address_for_person(
                            $membership->affiliation_people->first->person,
                        );
                        $self->_restore_constraints;
                    }
                )
            },
            undef,
            'memberships of previous years can be created when the members have different mailing addresses'
        );
    }
}

sub test_membership_updates ( $self, @ ) {
    my $membership = $self->_create_individual_membership;

    like(
        exception {
            $membership->update(
                { membership_type => $HOUSEHOLD_MEMBERSHIP } );
        },
        qr/without enough contributions/,
        'cannot promote a membership when sufficient contributions are not present'
    );

    is(
        exception {
            $self->_schema->storage->txn_do(
                sub {
                    $self->_defer_constraints;
                    $self->_new_person_for_affiliation($membership);
                    my $mtp = $self->_membership_type_parameter(
                        $HOUSEHOLD_MEMBERSHIP);
                    my $missing_amount
                        = $mtp->membership_amount
                        - $membership->contributions->get_column('amount')
                        ->sum;
                    $self->_new_contribution(
                        affiliation_id => $membership->id,
                        amount         => $missing_amount,
                    );
                    $membership->update(
                        { membership_type => $HOUSEHOLD_MEMBERSHIP } );
                    $self->_restore_constraints;
                }
            )
        },
        undef,
        'can promote an individual membership'
    );

    is(
        exception {
            $membership->update( { membership_type => undef } );
        },
        undef,
        'memberships can be downgraded to affiliations'
    );
}

__PACKAGE__->meta->make_immutable;

1;
