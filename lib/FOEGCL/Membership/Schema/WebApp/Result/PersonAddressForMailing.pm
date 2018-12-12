#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::PersonAddressForMailing;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::PersonAddressForMailing

=head1 DESCRIPTION

A person with no mailing address can be mailed at their physical address

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
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<person_address_for_mailing>

=cut

__PACKAGE__->table("person_address_for_mailing");
__PACKAGE__->result_source_instance->view_definition(" SELECT mailing_address.person_id,\n    mailing_address.street_line_1,\n    mailing_address.street_line_2,\n    city_state_zip.city,\n    city_state_zip.state_abbr,\n    city_state_zip.zip,\n    mailing_address.plus_four\n   FROM (mailing_address\n     JOIN city_state_zip USING (csz_id))\nUNION ALL\n SELECT p.person_id,\n    p.street_line_1,\n    p.street_line_2,\n    city_state_zip.city,\n    city_state_zip.state_abbr,\n    city_state_zip.zip,\n    p.plus_four\n   FROM ((physical_address p\n     JOIN city_state_zip USING (csz_id))\n     LEFT JOIN mailing_address USING (person_id))\n  WHERE (mailing_address.street_line_1 IS NULL)");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_nullable: 1

=head2 street_line_1

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 street_line_2

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 state_abbr

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 zip

  data_type: 'char'
  is_nullable: 1
  size: 5

=head2 plus_four

  data_type: 'char'
  is_nullable: 1
  size: 4

=cut

__PACKAGE__->add_columns(
  "person_id",
  { data_type => "integer", is_nullable => 1 },
  "street_line_1",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "street_line_2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "state_abbr",
  { data_type => "char", is_nullable => 1, size => 2 },
  "zip",
  { data_type => "char", is_nullable => 1, size => 5 },
  "plus_four",
  { data_type => "char", is_nullable => 1, size => 4 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:19:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V4LwtibXKedF2SgoIw6X/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
