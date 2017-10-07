use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::DonationType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::DonationType

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

=head1 TABLE: C<donation_type>

=cut

__PACKAGE__->table("donation_type");

=head1 ACCESSORS

=head2 donation_type

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 is_for_membership

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "donation_type",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "is_for_membership",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</donation_type>

=back

=cut

__PACKAGE__->set_primary_key("donation_type");

=head1 RELATIONS

=head2 affiliation_year_membership_levels

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationYearMembershipLevel>

=cut

__PACKAGE__->has_many(
  "affiliation_year_membership_levels",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationYearMembershipLevel",
  { "foreign.membership_donation_type" => "self.donation_type" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 donations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "FOEGCL::Membership::Schema::WebApp::Result::Donation",
  { "foreign.donation_type" => "self.donation_type" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g4EATdcKGY4giA0Dh8FFLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
