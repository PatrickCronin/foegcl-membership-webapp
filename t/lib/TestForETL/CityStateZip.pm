package TestForETL::CityStateZip;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::DataUtil qw( trim );
use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasWebAppSchema',
);

sub test_csz ( $self, @ ) {
    eq_or_diff(
        [
            map {
                +{
                    city  => $_->{city},
                    state => $_->{state_abbr},
                    zip   => $_->{zip},
                    }
            } $self->_schema->resultset('CityStateZip')->hri->all
        ],
        [
            map {
                +{
                    city  => trim( $_->{City} ),
                    state => trim( $_->{State} ),
                    zip   => trim( $_->{PostalCode} ),
                    }
            } $self->_legacy_schema->resultset('CityStateZip')->hri->all
        ],
        'City, State and Zip transferred successfully'
    );
}

__PACKAGE__->meta->make_immutable;

1;
