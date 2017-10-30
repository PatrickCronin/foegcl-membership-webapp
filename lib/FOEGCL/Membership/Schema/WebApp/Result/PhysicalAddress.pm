#<<<
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

=head1 ADDITIONAL CLASSES USED

=over 4

=item * L<FOEGCL::Membership::perlbase>

=back

=cut

use FOEGCL::Membership::perlbase;

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "InflateColumn::Serializer",
  "TimeStamp",
);

=head1 TABLE: C<physical_address>

=cut

__PACKAGE__->table("physical_address");

=head1 ACCESSORS

=head2 person_id

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

=head2 in_library_special_voting_district

  data_type: 'enum'
  default_value: 'unchecked'
  extra: {custom_type_name => "library_special_voting_district_status",list => ["in","out","unchecked","checked-but-unknown"]}
  is_nullable: 1

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
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "street_line_1",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "street_line_2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "csz_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "plus_four",
  { data_type => "char", default_value => \"null", is_nullable => 1, size => 4 },
  "in_library_special_voting_district",
  {
    data_type => "enum",
    default_value => "unchecked",
    extra => {
      custom_type_name => "library_special_voting_district_status",
      list => ["in", "out", "unchecked", "checked-but-unknown"],
    },
    is_nullable => 1,
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

=item * L</person_id>

=back

=cut

__PACKAGE__->set_primary_key("person_id");

=head1 RELATIONS

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

=head2 person

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "FOEGCL::Membership::Schema::WebApp::Result::Person",
  { person_id => "person_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-10-29 23:09:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rvbVIV0hlt4i0TZfGleSiQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
