package FOEGCL::Membership::Storage::LegacySchemaDumper;

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::LegacyDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::LegacyDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    my @tables_and_views = qw(
        ActiveRecentlyDonatingMembershipEmailAddresses2018
        AllFriendsContactInfo-PrimaryOnly
        AllFriendsContactInfo-SpouseOnly
        CityStateZip
        Configuration
        ContactInfo
        ContactType
        DataYears
        DonatingMembershipAnnualSummaryComplete
        Donations
        Friends
        Roles
        RolesTypes
    );
    my $tables_and_views_alternation
        = join( '|', map { quotemeta($_) } @tables_and_views );
    my $tables_and_views_re
        = qr/(?:\A|\.)(?:$tables_and_views_alternation)\z/i;

    return {
        constraint       => $tables_and_views_re,
        col_accessor_map => {
            DonatingMembershipAnnualSummaryComplete => {    # name
                New => 'new_memberships'                    # column mapping
            }
        },
    };
}

__PACKAGE__->meta->make_immutable;

1;
