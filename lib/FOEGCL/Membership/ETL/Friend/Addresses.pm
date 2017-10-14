package FOEGCL::Membership::ETL::Friend::Addresses;

# ABSTRACT: Extract, transform and load a Friend's address(es)

use FOEGCL::Membership::Moose;

use warnings FATAL => 'all';
use FOEGCL::Membership::DataUtil qw( is_pobox trim );

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
    return if !defined $self->legacy_friend->city_state_zip;

    my %field = (
        csz_id => $self->_schema->resultset('CityStateZip')->find(
            {
                city => trim( $self->legacy_friend->city_state_zip->city ),
                state_abbr =>
                  trim( $self->legacy_friend->city_state_zip->state ),
                zip =>
                  trim( $self->legacy_friend->city_state_zip->postal_code ),
            },
            { key => 'city_state_zip_is_unique' }
        )->id,
    );

    my @street_lines = split /(?:\r\n|\r|\n)+/, $self->legacy_friend->address;
    die 'Address for Friend '
      . $self->legacy_friend->friend_id
      . ' has more than 2 street address lines!'
      if @street_lines > 2;

    foreach my $line ( 1 .. 2 ) {
        $field{"street_line_$line"} = trim( $street_lines[ $line - 1 ] );
    }
    die 'Address has no Street Line 1' if !$field{street_line_1};

    my @addresses = $self->_process_address(%field);

    foreach my $address (@addresses) {
        my $resultset =
          is_pobox( $address->{street_line_1} )
          ? 'MailingAddress'
          : 'PhysicalAddress';
        foreach my $person ( @{ $self->people } ) {
            ## no critic (ValuesAndExpressions::ProhibitCommaSeparatedStatements)
            $self->_schema->resultset($resultset)
              ->create( { $address->%*, person_id => $person->id } );
        }
    }

    die
      sprintf( 'Friend %d has no physical address!', $self->legacy_friend->id )
      if !$self->people->[0]->physical_address;
}

sub _process_address ( $self, %field ) {
    my @addresses;
    if (
        ( is_pobox( $field{'street_line_1'} ) && $field{'street_line_2'} )
        || ( is_pobox( $field{'street_line_2'} )
            && $field{'street_line_1'} )
      )
    {
        push @addresses,
          {
            street_line_1 => $field{street_line_1},
            csz_id        => $field{csz_id},
          },
          {
            street_line_1 => $field{street_line_2},
            csz_id        => $field{csz_id},
          };
    }
    else {
        push @addresses, { %field{ grep { $field{$_} } keys %field } };
    }

    return @addresses;
}

__PACKAGE__->meta->make_immutable;

1;
