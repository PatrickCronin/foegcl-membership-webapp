package FOEGCL::Membership::ETL::Friend::ContactDetails;

# ABSTRACT: Extract, transform and load a Friend's email and phone records

use FOEGCL::Membership::Moose;

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

has people => (
    is  => 'ro',
    isa => 'ArrayRef[ FOEGCL::Membership::Schema::WebApp::Result::Person ]',
    required => 1,
);

with 'FOEGCL::Membership::Role::HasSchema';

sub etl ($self) {
    $self->_etl_friend_emails;
    $self->_etl_friend_phones;
}

sub _etl_friend_emails ($self) {
    my $friend_email_rs = $self->legacy_friend->contact_infos->search(
        {
            email_address => { '!=' => undef }
        }
    );

    while ( my $friend_email = $friend_email_rs->next ) {
        foreach my $person ( $self->people->@* ) {
            $self->_schema->resultset('PersonEmail')->create(
                {
                    person_id     => $person->id,
                    email_address => $friend_email->email_address,
                    is_preferred  => $friend_email->preferred,
                }
            );
        }
    }
}

sub _etl_friend_phones ($self) {
    my $friend_phone_rs = $self->legacy_friend->contact_infos->search(
        {
            'Phone Number' => { '!=' => undef },
        }
    );

    while ( my $friend_phone = $friend_phone_rs->next ) {
        foreach my $person ( $self->people->@* ) {
            my $phone_number =
              ( $friend_phone->area_code // q{} ) . $friend_phone->phone_number;
            $phone_number =~ s/\D//g;

            $self->_schema->resultset('PersonPhone')->create(
                {
                    person_id    => $person->id,
                    phone_number => $phone_number,
                    is_preferred => $friend_phone->preferred,
                }
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
