package FOEGCL::Membership::Storage::LegacySchemaDumper;

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::LegacyDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::LegacyDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    return {
        constraint => qr/
            \A
            (?:
                ActiveRecentlyDonatingMembershipEmailAddresses
                | CityStateZip
                | Configuration
                | ContactInfo
                | ContactType
                | DataYears
                | DonatingMembershipAnnualSummaryComplete
                | Donations
                | Friends
                | Roles
                | RolesTypes
            )
            \z
        /x,
        col_accessor_map => {
            DonatingMembershipAnnualSummaryComplete => { # name
                New => 'new_memberships' # column mapping
            }
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
