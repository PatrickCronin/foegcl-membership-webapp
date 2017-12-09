package FOEGCL::Membership::Storage::WebAppSchemaDumper;

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::WebAppDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::WebAppDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    return { db_schema => 'public', };
}

around '_build_default_loader_options' => sub ( $orig, $self, @args ) {
    return {
        $self->$orig(@args)->%*,
        rel_name_map => {
            state_abbr => 'state',    # CityStateZip.state => State
        },
    };
};

__PACKAGE__->meta->make_immutable;

1;
