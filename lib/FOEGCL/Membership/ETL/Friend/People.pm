package FOEGCL::Membership::ETL::Friend::People;

# ABSTRACT: Extract, transform and load a Friend's people

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

with 'FOEGCL::Membership::Role::HasSchema';

sub etl ($self) {
    my @people;
    push @people,
      $self->_schema->resultset('Person')->create(
        {
            first_name => trim( $self->legacy_friend->first_name ),
            last_name  => trim( $self->legacy_friend->last_name ),
            opted_out  => $self->legacy_friend->inactive,
        }
      );

    if ( $self->legacy_friend->spouse_first_name ) {
        my $spouse_first_name = $self->legacy_friend->spouse_first_name;
        my $spouse_last_name  = $self->legacy_friend->spouse_last_name
          || $self->legacy_friend->last_name;
        push @people,
          $self->_schema->resultset('Person')->create(
            {
                first_name => trim($spouse_first_name),
                last_name  => trim($spouse_last_name),
                opted_out  => $self->legacy_friend->inactive,
            }
          );
    }

    return @people;
}

__PACKAGE__->meta->make_immutable;

1;
