use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Donation

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

=head1 TABLE: C<donation>

=cut

__PACKAGE__->table("donation");

=head1 ACCESSORS

=head2 donation_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'donation_donation_id_seq'

=head2 affiliation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 affiliation_year

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  size: [4,0]

=head2 donation_type

  data_type: 'varchar'
  default_value: 'general_contribution'
  is_foreign_key: 1
  is_nullable: 0
  size: 32

=head2 amount

  data_type: 'numeric'
  is_nullable: 0
  size: [11,2]

=head2 notes

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 created_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=head2 updated_at

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "donation_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "donation_donation_id_seq",
  },
  "affiliation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "affiliation_year",
  {
    data_type => "numeric",
    is_foreign_key => 1,
    is_nullable => 0,
    size => [4, 0],
  },
  "donation_type",
  {
    data_type => "varchar",
    default_value => "general_contribution",
    is_foreign_key => 1,
    is_nullable => 0,
    size => 32,
  },
  "amount",
  { data_type => "numeric", is_nullable => 0, size => [11, 2] },
  "notes",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "created_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
  "updated_at",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</donation_id>

=back

=cut

__PACKAGE__->set_primary_key("donation_id");

=head1 RELATIONS

=head2 affiliation

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Affiliation>

=cut

__PACKAGE__->belongs_to(
  "affiliation",
  "FOEGCL::Membership::Schema::WebApp::Result::Affiliation",
  { affiliation_id => "affiliation_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

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

=head2 donation_type

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::DonationType>

=cut

__PACKAGE__->belongs_to(
  "donation_type",
  "FOEGCL::Membership::Schema::WebApp::Result::DonationType",
  { donation_type => "donation_type" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7hIgDLFweqNhjKViUmab8w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
