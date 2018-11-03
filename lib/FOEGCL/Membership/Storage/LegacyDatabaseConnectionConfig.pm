package FOEGCL::Membership::Storage::LegacyDatabaseConnectionConfig;

# ABSTRACT: Contains all config necessary to connect to a copy of the Legacy DB

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Types 'NonEmptySimpleStr';

has dsn => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    default => sub ($self) {
        sprintf(
            'dbi:ADO:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s',
            $self->_config->legacy_database_config->{filepath}
        );
    },
);

with qw(
    FOEGCL::Membership::Role::ConfiguresDatabaseConnection
    FOEGCL::Membership::Role::HasConfig
    FOEGCL::Membership::Role::Singleton
);

sub username { undef }
sub password { undef }

sub dbi_attributes {
    +{
        quote_char => [qw([ ])],
        name_sep   => q{.},
    };
}

sub extra_attributes { +{} }

sub schema_class_name { 'FOEGCL::Membership::Schema::Legacy' }

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
