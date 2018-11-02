package FOEGCL::Membership::Storage::WebAppSchemaDumper;

# ABSTRACT: Dumps the WebApp DBIC schema classes

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::WebAppDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::WebAppDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    return {
        db_schema => 'public',
        ## no critic (RegularExpressions::ProhibitComplexRegexes)
        exclude => qr/
            \A
            (?:
                report_blast_email_list_by_contribution
                | report_blast_email_list_by_interest
                | report_blast_email_list_by_participation
                | report_contributing_friends_annual_friend_contribution_agg
                | report_contributing_friends_earliest_friend_contributions
                | report_contributing_friends_renewees
                | report_contributing_friends_refreshees
            )
            \z
        /x,
        ## use critic
        rel_name_map => {
            Affiliation => {
                year => 'affiliation_year',
            },
            CityStateZip => {
                state_abbr => 'state',    # CityStateZip.state => State
            },
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
