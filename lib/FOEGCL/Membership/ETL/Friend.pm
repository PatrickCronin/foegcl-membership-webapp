package FOEGCL::Membership::ETL::Friend;

# ABSTRACT: Migrate friend and related data from Legacy system to WebApp

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::ETL::Friend::Addresses                    ();
use FOEGCL::Membership::ETL::Friend::ContactDetails               ();
use FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions ();
use FOEGCL::Membership::ETL::Friend::Participation                ();
use FOEGCL::Membership::ETL::Friend::People                       ();

has _person_etl => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::ETL::Friend::People',
    lazy    => 1,
    default => sub { FOEGCL::Membership::ETL::Friend::People->new },
);

has _addresses_etl => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::ETL::Friend::Addresses',
    lazy    => 1,
    default => sub { FOEGCL::Membership::ETL::Friend::Addresses->new },
);

has _contact_details_etl => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::ETL::Friend::ContactDetails',
    lazy    => 1,
    default => sub { FOEGCL::Membership::ETL::Friend::ContactDetails->new },
);

has _participation_etl => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::ETL::Friend::Participation',
    lazy    => 1,
    default => sub { FOEGCL::Membership::ETL::Friend::Participation->new },
);

has _affiliations_and_contributions_etl => (
    is   => 'ro',
    isa  => 'FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions',
    lazy => 1,
    default => sub {
        FOEGCL::Membership::ETL::Friend::AffiliationsAndContributions->new;
    },
);

sub run ( $self, $legacy_friend ) {
    my @people = $self->_person_etl->run($legacy_friend);
    $self->_addresses_etl->run( $legacy_friend, @people );
    $self->_contact_details_etl->run( $legacy_friend, @people );
    $self->_participation_etl->run( $legacy_friend, @people );
    $self->_affiliations_and_contributions_etl->run(
        $legacy_friend,
        @people
    );
}

__PACKAGE__->meta->make_immutable;

1;
