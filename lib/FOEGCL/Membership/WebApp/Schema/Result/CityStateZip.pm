use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::CityStateZip;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::CityStateZip

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

=head1 TABLE: C<city_state_zip>

=cut

__PACKAGE__->table("city_state_zip");

=head1 ACCESSORS

=head2 csz_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'city_state_zip_csz_id_seq'

=head2 zip

  data_type: 'numeric'
  is_nullable: 0
  size: [5,0]

=head2 city

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 state_abbr

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 2

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
  "csz_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "city_state_zip_csz_id_seq",
  },
  "zip",
  { data_type => "numeric", is_nullable => 0, size => [5, 0] },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "state_abbr",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 2 },
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

=item * L</csz_id>

=back

=cut

__PACKAGE__->set_primary_key("csz_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<city_state_zip_zip_city_state_abbr_key>

=over 4

=item * L</zip>

=item * L</city>

=item * L</state_abbr>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "city_state_zip_zip_city_state_abbr_key",
  ["zip", "city", "state_abbr"],
);

=head1 RELATIONS

=head2 postal_addresses

Type: has_many

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::PostalAddress>

=cut

__PACKAGE__->has_many(
  "postal_addresses",
  "FOEGCL::Membership::WebApp::Schema::Result::PostalAddress",
  { "foreign.csz_id" => "self.csz_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 residential_addresses

Type: has_many

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::ResidentialAddress>

=cut

__PACKAGE__->has_many(
  "residential_addresses",
  "FOEGCL::Membership::WebApp::Schema::Result::ResidentialAddress",
  { "foreign.csz_id" => "self.csz_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 state_abbr

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::State>

=cut

__PACKAGE__->belongs_to(
  "state_abbr",
  "FOEGCL::Membership::WebApp::Schema::Result::State",
  { state_abbr => "state_abbr" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SOLB5zVXZZMxGHEVg13ygw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
