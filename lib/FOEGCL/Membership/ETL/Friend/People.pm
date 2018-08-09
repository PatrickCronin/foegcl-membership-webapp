package FOEGCL::Membership::ETL::Friend::People;

# ABSTRACT: Extract, transform and load a Friend's people

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub run ( $self, $legacy_friend ) {
    my @people;
    push @people,
        $self->_schema->resultset('Person')->create(
        {
            first_name       => trim( $legacy_friend->first_name ),
            last_name        => trim( $legacy_friend->last_name ),
            opted_out        => $legacy_friend->inactive,
            source_friend_id => $legacy_friend->friend_id,
        }
        );

    if ( $legacy_friend->spouse_first_name ) {
        my $spouse_first_name = $legacy_friend->spouse_first_name;
        my $spouse_last_name  = $legacy_friend->spouse_last_name
            || $legacy_friend->last_name;
        push @people,
            $self->_schema->resultset('Person')->create(
            {
                first_name       => trim($spouse_first_name),
                last_name        => trim($spouse_last_name),
                opted_out        => $legacy_friend->inactive,
                source_friend_id => $legacy_friend->friend_id,
            }
            );
    }

    return @people;
}

__PACKAGE__->meta->make_immutable;

1;
