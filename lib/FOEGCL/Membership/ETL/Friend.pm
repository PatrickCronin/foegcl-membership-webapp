package FOEGCL::Membership::ETL::Friend;

# ABSTRACT: Migrate friend and related data from Legacy system to WebApp

use FOEGCL::Membership::Moose;

use Carp qw(croak);
use FOEGCL::Membership::ETL::Friend::Addresses               ();
use FOEGCL::Membership::ETL::Friend::ContactDetails          ();
use FOEGCL::Membership::ETL::Friend::MembershipsAndDonations ();
use FOEGCL::Membership::ETL::Friend::Participation           ();
use FOEGCL::Membership::ETL::Friend::People                  ();

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

with qw(
  FOEGCL::Membership::Role::HasLegacySchema
  FOEGCL::Membership::Role::HasSchema
);

sub etl ( $self, $legacy_friend ) {
    my @people =
      FOEGCL::Membership::ETL::Friend::People->new(
        legacy_friend => $self->legacy_friend, )->etl;

    FOEGCL::Membership::ETL::Friend::Addresses->new(
        legacy_friend => $self->legacy_friend,
        people        => \@people,
    )->etl;

    FOEGCL::Membership::ETL::Friend::ContactDetails->new(
        legacy_friend => $self->legacy_friend,
        people        => \@people,
    )->etl;

    FOEGCL::Membership::ETL::Friend::Participation->new(
        legacy_friend => $self->legacy_friend,
        people        => \@people,
    )->etl;

    FOEGCL::Membership::ETL::Friend::MembershipsAndDonations->new(
        legacy_friend => $self->legacy_friend,
        people        => \@people,
    )->etl;
}

__PACKAGE__->meta->make_immutable;

1;
