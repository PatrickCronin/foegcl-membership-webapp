package TestFor::FOEGCL::Membership::Report::Membership;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Differences 'eq_or_diff';

with qw(
    FOEGCL::Membership::Role::UsesWebAppDatabase
    TestRole::GeneratesFixtures
);

# Create a person, a person with an affiliaiton, a person with an affiliation
# that's not enough for a membership, and a person with a membership, and
# make sure the report includes the expected person, and the person's details
# are correct.

sub test_person_inclusion_and_details ( $self, @ ) {
    is_deeply(
        [ map { $_->id } $self->_schema->resultset('Person')->all ],
        [],
        'no people',
    );

    $self->_new_person;
    $self->_create_basic_affiliation;
    my $membership = $self->_create_individual_membership;

    my ($person) = $membership->search_related(
        'affiliation_people',
        undef,
        { prefetch => 'person', }
    )->one_row->person;
    $person->update(
        {
            first_name => 'Sam',
            last_name  => 'Samples',
        }
    );
    $self->_new_mailing_address_for_person($person);
    $self->_new_physical_address_for_person($person);
    $self->_new_phone_number_for_person(
        $person,
        phone_number => '5184770000'
    );
    $self->_new_phone_number_for_person(
        $person,
        phone_number => '5184770001',
        is_preferred => 1,
    );
    $self->_new_email_address_for_person($person);
    $self->_new_email_address_for_person(
        $person,
        email_address => 'preferred@eg.com',
        is_preferred  => 1,
    );

    eq_or_diff(
        [
            $self->_schema->resultset('ReportCurrentMembershipList')
                ->hri->all
        ],
        [
            {
                friend_id      => 1001,
                first_name     => 'Sam',
                last_name      => 'Samples',
                name           => 'Samples, Sam',
                street_lines   => '2 Main St',
                city_state_zip => 'East Greenbush, NY 12061',
                emails         => "preferred\@eg.com\ntest\@fixture.com",
                phones         => "(518) 477-0001\n(518) 477-0000",
            }
        ],
        'expected people and details'
    );
}

__PACKAGE__->meta->make_immutable;

1;
