package FOEGCL::Membership::ETL::Friend::Participation;

# ABSTRACT: Extract, transform and load a Friend's participation interests and history

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef );

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

has people => (
    is       => 'ro',
    isa      => 'ArrayRef [FOEGCL::Membership::Schema::WebApp::Result::Person]',
    required => 1,
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub etl ($self) {

    # TODO: $self->_etl_friend_historical_roles($legacy_friend, @people);

    my $legacy_roles_rs = $self->legacy_friend->roles;
    my $webapp_interests_rs =
      $self->_schema->resultset('ParticipationInterest');
    my $webapp_roles_rs = $self->_schema->resultset('ParticipationRole');
    while ( my $legacy_role = $legacy_roles_rs->next ) {
        next if $legacy_role->role_type->historical;
        foreach my $person ( $self->people->@* ) {
            $webapp_interests_rs->create(
                {
                    person_id             => $person->id,
                    participation_role_id => $webapp_roles_rs->find(
                        { role_name => trim( $legacy_role->role_type->role ) },
                        { key       => 'participation_role_name_is_unique' },
                    )->participation_role_id,
                }
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
