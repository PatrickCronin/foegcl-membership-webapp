package FOEGCL::Membership::ETL::Friend::Addresses;

# ABSTRACT: Extract, transform and load a Friend's address(es)

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef );

has legacy_friend => (
    is       => 'ro',
    isa      => 'FOEGCL::Membership::Schema::Legacy::Result::Friend',
    required => 1,
);

has people => (
    is  => 'ro',
    isa => 'ArrayRef [FOEGCL::Membership::Schema::WebApp::Result::Person]',
    required => 1,
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

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

    my @street_lines = grep { $_ ne q{} }
        map { trim($_) }
        split /(?:\r\n|\r|\n)+/, $self->legacy_friend->address;

    die sprintf(
        'This class cannot handle addresses with more than 2 street lines. Problem with %s',
        $self->legacy_friend->friend_id
    ) if @street_lines > 2;

    foreach my $line ( 1 .. 2 ) {
        $field{"street_line_$line"} = $street_lines[ $line - 1 ];
    }

    my @addresses = $self->_process_address(%field);

    foreach my $address (@addresses) {
        my $relationship
            = is_pobox( $address->{street_line_1} )
            ? 'mailing_address'
            : 'physical_address';
        foreach my $person ( $self->people->@* ) {
            $person->create_related( $relationship, $address );
        }
    }
}

sub _process_address ( $self, %field ) {
    my @addresses;
    if (
        ( is_pobox( $field{'street_line_1'} ) && $field{'street_line_2'} )
        || ( is_pobox( $field{'street_line_2'} )
            && $field{'street_line_1'} )
        ) {
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
sub _is_pobox ($line) {
    state $maybe_whitespace = qr/\s*/;

    return 0 if !defined $line;

    return $line =~ m/
        \A
        P (?: \.? | ost ) $maybe_whitespace
        O (?: \.? | ffice ) $maybe_whitespace
        Box
    /ix;
}

__PACKAGE__->meta->make_immutable;

1;
