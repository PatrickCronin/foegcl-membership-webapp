package TestForETL::Report::BlastEmailList;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::UsesLegacyDatabase',
    'FOEGCL::Membership::Role::UsesWebAppDatabase',
);

sub test_blast_email_list ( $self, @ ) {
    my @migrated_blast_emails
        = sort $self->_dbh->selectcol_arrayref(<<'SQL')->@*;
            SELECT email_address
            FROM report_blast_email_list_by_contribution
SQL

    my @legacy_blast_emails
        = sort map { $_->{Email_Address} }
        $self->_legacy_schema->resultset(
        'ActiveRecentlyDonatingMembershipEmailAddresses2018')->hri->all;

    eq_or_diff(
        \@migrated_blast_emails,
        \@legacy_blast_emails,
        'blast email lists by contribution are identical'
    );
}

__PACKAGE__->meta->make_immutable;

1;
