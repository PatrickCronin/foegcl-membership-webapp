use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::Donation

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

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

  data_type: 'enum'
  extra: {custom_type_name => "donation_type_enum",list => ["membership_fee","donation"]}
  is_nullable: 0

=head2 amount

  data_type: 'money'
  is_nullable: 0

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
    data_type => "enum",
    extra => {
      custom_type_name => "donation_type_enum",
      list => ["membership_fee", "donation"],
    },
    is_nullable => 0,
  },
  "amount",
  { data_type => "money", is_nullable => 0 },
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

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::Affiliation>

=cut

__PACKAGE__->belongs_to(
  "affiliation",
  "FOEGCL::Membership::WebApp::Schema::Result::Affiliation",
  { affiliation_id => "affiliation_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 affiliation_year

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "affiliation_year",
  "FOEGCL::Membership::WebApp::Schema::Result::AffiliationYear",
  { year => "affiliation_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HkvUME7wVKlQwuimOzLupQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
