package FOEGCL::Membership::ETL::Friend::Addresses;

# ABSTRACT: Extract, transform and load a Friend's address(es)

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use FOEGCL::Membership::Types qw( ArrayRef );
use List::MoreUtils qw( part );

with 'FOEGCL::Membership::Role::HasWebAppSchema';

sub run ( $self, $legacy_friend, @people ) {
    return if !defined $legacy_friend->city_state_zip;

    my $new_csz
        = $self->_find_migrated_csz_for( $legacy_friend->city_state_zip );

    my %address = _addresses_from(
        $new_csz->id,
        _single_street_line_to_multiple_lines( $legacy_friend->address )
    );

    foreach my $person (@people) {
        foreach my $mailing_address ( $address{mailing_addresses}->@* ) {
            $person->create_related( 'mailing_address', $mailing_address );
        }
        foreach my $physical_address ( $address{physical_addresses}->@* ) {
            $person->create_related( 'physical_address', $physical_address );
        }
    }
}

sub _find_migrated_csz_for ( $self, $csz ) {
    return undef if !defined $csz;

    return $self->_schema->resultset('CityStateZip')->find(
        {
            city       => trim( $csz->city ),
            state_abbr => trim( $csz->state ),
            zip        => trim( $csz->postal_code ),
        },
        { key => 'city_state_zip_is_unique' }
    );
}

sub _single_street_line_to_multiple_lines ( $address ) {
    my @street_lines = grep { $_ ne q{} }
        map { trim($_) }
        split /(?:\r\n|\r|\n)+/, $address;

    return @street_lines;
}

# Returns one or more addresses from a set of street lines and a CSZ id
sub _addresses_from ( $csz_id, @street_lines ) {
    die sprintf(
        'This class cannot handle addresses with %d street lines',
        scalar @street_lines
    ) if @street_lines > 2;

    # A helper method currying over csz_id
    my $_address_from = sub {
        my @address_lines = @_;
        return {
            csz_id => $csz_id,
            (
                map { 'street_line_' . $_ => $address_lines[ $_ - 1 ] }
                    ( 1 .. @address_lines )
            )
        };
    };

    my @partitioned_lines = part { _is_pobox($_) ? 0 : 1 } @street_lines;

    # Any PO Box lines are their own mailing address
    my @mailing_addresses;
    if ( defined $partitioned_lines[0] ) {
        push @mailing_addresses, $_address_from->($_)
            for $partitioned_lines[0]->@*;
    }

    # All physical lines together become one physical address
    my @physical_addresses;
    if ( defined $partitioned_lines[1] ) {
        push @physical_addresses,
            $_address_from->( $partitioned_lines[1]->@* );
    }

    return (
        mailing_addresses  => \@mailing_addresses,
        physical_addresses => \@physical_addresses
    );
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
