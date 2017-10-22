package FOEGCL::Membership::Config::LegacyDatabase;

use FOEGCL::Membership::Moose;

with qw(
    FOEGCL::Membership::Role::ConfiguresDatabase
    FOEGCL::Membership::Role::HasConfig
);

sub _build_dsn ( $self, @ ) {
    return sprintf(
        'dbi:ADO:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s',
        $self->_config->{'Legacy Database'}->{filepath}
    );
}

sub _build_dbi_attributes ( $self, @ ) {
    return {
        quote_char => [qw([ ])],
        name_sep   => q{.},

        # TraceLevel => 5
    };
}

sub _build_schema_class_name ( $self, @ ) {
    return 'FOEGCL::Membership::Schema::Legacy';
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
