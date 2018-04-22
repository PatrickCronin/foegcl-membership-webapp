package FOEGCL::Membership::Storage::WebAppSchemaDumper;

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::WebAppDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::WebAppDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    return {
        db_schema => 'public',
        exclude   => qr/
            \A
            (?:
                report_contributing_friends_annual_friend_contribution_agg
                | report_contributing_friends_earliest_friend_contributions
                | report_contributing_friends_renewees
                | report_contributing_friends_refreshees
            )
            \z
        /x,
        rel_name_map => {
            CityStateZip => {
                state_abbr => 'state',    # CityStateZip.state => State
            }
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
