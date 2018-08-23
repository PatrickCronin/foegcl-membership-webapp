package TestRole::GeneratesFixtures;

use FOEGCL::Membership::Moose::Role;

use Const::Fast 'const';

use FOEGCL::Membership::Const qw(
    $HOUSEHOLD_MEMBERSHIP
    $INDIVIDUAL_MEMBERSHIP
);

requires '_schema';

const my $CURRENT_YEAR => [ gmtime(time) ]->[5] + 1900;

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _new_affiliation ( $self, %args ) {
    ## use critic
    state $friend_id = 1000;

    $self->_schema->resultset('Affiliation')->create(
        {
            year      => $CURRENT_YEAR,
            friend_id => $friend_id++,
            %args,
        }
    );
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _new_person ( $self, %args ) {
    ## use critic
    $self->_schema->resultset('Person')->create(
        {
            first_name => 'First',
            last_name  => 'Last',
            %args,
        }
    );
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _new_person_for_affiliation ( $self, $affiliation ) {
    ## use critic
    my $person = $self->_new_person;
    $affiliation->create_related(
        'affiliation_people',
        { person_id => $person->id },
    );

    return $person;
}

sub _new_contribution ( $self, %args ) {
    $self->_schema->resultset('Contribution')->create(
        {
            amount => 1,
            %args,
        }
    );
}

sub _create_basic_affiliation ( $self ) {
    my $affiliation;
    $self->_schema->storage->txn_do(
        sub {
            $self->_defer_constraints;
            $affiliation = $self->_new_affiliation;
            $self->_new_person_for_affiliation($affiliation);
            $self->_new_contribution( affiliation_id => $affiliation->id );
        }
    );

    return $affiliation;
}

sub _default_csz ( $self, %args ) {
    $self->_schema->resultset('CityStateZip')->find_or_create(
        {
            city       => 'East Greenbush',
            state_abbr => 'NY',
            zip        => '12061',
            %args,
        },
        { key => 'city_state_zip_is_unique' }
    );
}

sub _new_mailing_address_for_person ( $self, $person, %args ) {
    $person->create_related(
        'mailing_address',
        {
            street_line_1 => 'PO Box 4',
            csz_id        => $self->_default_csz->id,
            %args,
        }
    );
}

sub _new_physical_address_for_person ( $self, $person, %args ) {
    $person->create_related(
        'physical_address',
        {
            street_line_1 => '2 Main St',
            csz_id        => $self->_default_csz->id,
            %args,
        }
    );
}

sub _membership_type_parameter ( $self, $membership_type ) {
    $self->_schema->resultset('MembershipTypeParameter')->search_rs(
        {
            year            => $CURRENT_YEAR,
            membership_type => $membership_type,
        }
    )->one_row;
}

sub _create_individual_membership ( $self ) {
    $self->_create_membership($INDIVIDUAL_MEMBERSHIP);
}

sub _create_household_membership ( $self ) {
    $self->_create_membership($HOUSEHOLD_MEMBERSHIP);
}

sub _create_membership ( $self, $membership_type ) {
    my $mtp = $self->_membership_type_parameter($membership_type);

    my $membership;
    $self->_schema->storage->txn_do(
        sub {
            $self->_defer_constraints;
            $membership = $self->_new_affiliation;
            $self->_new_person_for_affiliation($membership)
                for 1 .. $mtp->membership_max_people;
            $self->_new_contribution(
                affiliation_id => $membership->id,
                amount         => $mtp->membership_amount,
            );
        }
    );

    $membership->update( { membership_type => $membership_type } );

    return $membership;
}

1;
