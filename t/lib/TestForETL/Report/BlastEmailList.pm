package TestForETL::Report::BlastEmailList;

use FOEGCL::Membership::Test::Class::Moose;

use Test::Differences qw(eq_or_diff);

with(
    'FOEGCL::Membership::Role::HasLegacySchema',
    'FOEGCL::Membership::Role::HasWebAppSchema',
    'TestRole::TestsETL',
);

sub test_blast_email_list ( $self, @ ) {
    my @migrated_blast_emails = sort
        map { $_->{email_address} }
        $self->_schema->resultset('ReportBlastEmailList')->hri->all;

    my @legacy_blast_emails = sort
        map { $_->{Email_Address} }
        $self->_legacy_schema->resultset(
        'ActiveRecentlyDonatingMembershipEmailAddress')->hri->all;

    eq_or_diff(
        \@migrated_blast_emails,
        \@legacy_blast_emails,
        'blast email lists are the same.'
    );
}

__PACKAGE__->meta->make_immutable;

1;
