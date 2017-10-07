use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::AffiliationYearMembershipLevel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::AffiliationYearMembershipLevel

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<affiliation_year_membership_level>

=cut

__PACKAGE__->table("affiliation_year_membership_level");

=head1 ACCESSORS

=head2 affiliation_year

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  size: [4,0]

=head2 membership_donation_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 amount

  data_type: 'numeric'
  is_nullable: 0
  size: [11,2]

=cut

__PACKAGE__->add_columns(
  "affiliation_year",
  {
    data_type => "numeric",
    is_foreign_key => 1,
    is_nullable => 0,
    size => [4, 0],
  },
  "membership_donation_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 32 },
  "amount",
  { data_type => "numeric", is_nullable => 0, size => [11, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</affiliation_year>

=item * L</membership_donation_type>

=back

=cut

__PACKAGE__->set_primary_key("affiliation_year", "membership_donation_type");

=head1 RELATIONS

=head2 affiliation_year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "affiliation_year",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear",
  { year => "affiliation_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 membership_donation_type

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::DonationType>

=cut

__PACKAGE__->belongs_to(
  "membership_donation_type",
  "FOEGCL::Membership::Schema::WebApp::Result::DonationType",
  { donation_type => "membership_donation_type" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B9pqAiEK2RvDPi54MgJo+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
