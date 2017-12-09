package FOEGCL::Membership::ETL::Friend;

# ABSTRACT: Migrate friend and related data from Legacy system to WebApp

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::ETL::Friend::Addresses                ();
use FOEGCL::Membership::ETL::Friend::ContactDetails           ();
use FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations ();
use FOEGCL::Membership::ETL::Friend::Participation            ();
use FOEGCL::Membership::ETL::Friend::People                   ();

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

sub etl ( $self ) {
    my @people = FOEGCL::Membership::ETL::Friend::People->new->etl(
        $self->legacy_friend );

    FOEGCL::Membership::ETL::Friend::Addresses->new->etl(
        $self->legacy_friend,
        @people
    );

    FOEGCL::Membership::ETL::Friend::ContactDetails->new->etl(
        $self->legacy_friend,
        @people
    );

    FOEGCL::Membership::ETL::Friend::Participation->new->etl(
        $self->legacy_friend,
        @people,
    );

    FOEGCL::Membership::ETL::Friend::AffiliationsAndDonations->new->etl(
        $self->legacy_friend,
        @people,
    );
}

__PACKAGE__->meta->make_immutable;

1;
