package FOEGCL::Membership::Storage::WebAppSchemaDumper;

# ABSTRACT: Dumps the WebApp DBIC schema classes

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig->new;
}

sub _build_loader_options ( $self, @ ) {
    +{
        db_schema => 'public',
        ## no critic (RegularExpressions::ProhibitComplexRegexes)
        exclude => qr/
            \A
            (?:
                blast_email_list_by_contribution
                | blast_email_list_by_interest
                | blast_email_list_by_participation
                | contributing_friends_report_annual_friend_contribution_agg
                | contributing_friends_report_earliest_friend_contributions
                | contributing_friends_report_renewees
                | contributing_friends_report_refreshees
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
