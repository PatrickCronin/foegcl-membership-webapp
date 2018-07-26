package FOEGCL::Membership::Config::LegacyDatabase;

use FOEGCL::Membership::Moose;

use Const::Fast 'const';

with qw(
    FOEGCL::Membership::Role::ConfiguresDatabase
    FOEGCL::Membership::Role::HasConfig
);

const my $LEGACY_DB_CONFIG_KEY => 'Legacy Database';

sub _build_dsn ( $self, @ ) {
    return sprintf(
        'dbi:ADO:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s',
        $self->_config->{$LEGACY_DB_CONFIG_KEY}{filepath}
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
