use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress

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

=head1 TABLE: C<physical_address>

=cut

__PACKAGE__->table("physical_address");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 street_line_1

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 street_line_2

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 csz_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 plus_four

  data_type: 'char'
  default_value: null
  is_nullable: 1
  size: 4

=head2 definitely_in_library_special_voting_district

  data_type: 'boolean'
  default_value: false
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
  "affiliation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "street_line_1",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "street_line_2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "csz_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "plus_four",
  { data_type => "char", default_value => \"null", is_nullable => 1, size => 4 },
  "definitely_in_library_special_voting_district",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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

=head2 csz

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::CityStateZip>

=cut

__PACKAGE__->belongs_to(
  "csz",
  "FOEGCL::Membership::Schema::WebApp::Result::CityStateZip",
  { csz_id => "csz_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UKIUhybfrn5bV2EGe31NUw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
