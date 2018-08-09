package FOEGCL::Membership::ETL::Friend::Participation;

# ABSTRACT: Extract, transform and load a Friend's participation interests and history

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef );

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub run ( $self, $legacy_friend, @people ) {
    my $friend_roles        = $legacy_friend->roles;
    my $participation_roles = $self->_schema->resultset('ParticipationRole');
    while ( my $friend_role = $friend_roles->next ) {
        next if $friend_role->role_type->historical;
        foreach my $person (@people) {
            $person->create_related(
                'participation_interests',
                {
                    participation_role_id => $participation_roles->find(
                        {
                            role_name => trim( $friend_role->role_type->role )
                        },
                        { key => 'participation_role_name_is_unique' },
                    )->participation_role_id
                }
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
