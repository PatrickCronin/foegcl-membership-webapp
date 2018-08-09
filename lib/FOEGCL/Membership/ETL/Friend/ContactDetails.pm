package FOEGCL::Membership::ETL::Friend::ContactDetails;

# ABSTRACT: Extract, transform and load a Friend's email and phone records

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef );

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub run ( $self, $legacy_friend, @people ) {
    _etl_friend_emails( $legacy_friend, @people );
    _etl_friend_phones( $legacy_friend, @people );
}

sub _etl_friend_emails ( $legacy_friend, @people ) {
    my $friend_email_rs = $legacy_friend->contact_infos->search_rs(
        { email_address => { '!=' => undef } } );

    while ( my $friend_email = $friend_email_rs->next ) {
        foreach my $person (@people) {
            $person->create_related(
                'person_emails',
                {
                    email_address => trim( $friend_email->email_address ),
                    is_preferred  => $friend_email->preferred,
                }
            );
        }
    }
}

sub _etl_friend_phones ( $legacy_friend, @people ) {
    my $friend_phone_rs = $legacy_friend->contact_infos->search_rs(
        {
            'Phone Number' => { '!=' => undef },
        }
    );

    while ( my $friend_phone = $friend_phone_rs->next ) {
        foreach my $person (@people) {
            my $phone_number = ( trim( $friend_phone->area_code ) // q{} )
                . trim( $friend_phone->phone_number );
            $phone_number =~ s/\D//g;

            $person->create_related(
                'person_phones',
                {
                    phone_number => $phone_number,
                    is_preferred => $friend_phone->preferred,
                }
            );
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
