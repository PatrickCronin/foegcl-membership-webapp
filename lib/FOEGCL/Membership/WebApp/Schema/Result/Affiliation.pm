use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::Affiliation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::Affiliation

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

=head1 TABLE: C<affiliation>

=cut

__PACKAGE__->table("affiliation");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'affiliation_affiliation_id_seq'

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
  "affiliation_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "affiliation_affiliation_id_seq",
  },
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

=item * L</affiliation_id>

=back

=cut

__PACKAGE__->set_primary_key("affiliation_id");

=head1 RELATIONS

=head2 donations

Type: has_many

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "FOEGCL::Membership::WebApp::Schema::Result::Donation",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 people

Type: has_many

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::Person>

=cut

__PACKAGE__->has_many(
  "people",
  "FOEGCL::Membership::WebApp::Schema::Result::Person",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 postal_address

Type: might_have

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::PostalAddress>

=cut

__PACKAGE__->might_have(
  "postal_address",
  "FOEGCL::Membership::WebApp::Schema::Result::PostalAddress",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 residential_address

Type: might_have

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::ResidentialAddress>

=cut

__PACKAGE__->might_have(
  "residential_address",
  "FOEGCL::Membership::WebApp::Schema::Result::ResidentialAddress",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JumjaCRcHH7UWFJ2xubfcw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
