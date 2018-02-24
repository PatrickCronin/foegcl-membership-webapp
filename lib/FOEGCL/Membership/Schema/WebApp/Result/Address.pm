#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Address

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

=head1 TABLE: C<address>

=cut

__PACKAGE__->table("address");
__PACKAGE__->result_source_instance->view_definition(" SELECT physical_address.person_id,\n    'physical'::text AS address_type,\n    physical_address.street_line_1,\n    physical_address.street_line_2,\n    physical_address.csz_id,\n    physical_address.plus_four\n   FROM physical_address\nUNION ALL\n SELECT mailing_address.person_id,\n    'mailing'::text AS address_type,\n    mailing_address.street_line_1,\n    mailing_address.street_line_2,\n    mailing_address.csz_id,\n    mailing_address.plus_four\n   FROM mailing_address");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_nullable: 1

=head2 address_type

  data_type: 'text'
  is_nullable: 1

=head2 street_line_1

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 street_line_2

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 csz_id

  data_type: 'integer'
  is_nullable: 1

=head2 plus_four

  data_type: 'char'
  is_nullable: 1
  size: 4

=cut

__PACKAGE__->add_columns(
  "person_id",
  { data_type => "integer", is_nullable => 1 },
  "address_type",
  { data_type => "text", is_nullable => 1 },
  "street_line_1",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "street_line_2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "csz_id",
  { data_type => "integer", is_nullable => 1 },
  "plus_four",
  { data_type => "char", is_nullable => 1, size => 4 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-23 21:26:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:10AGA0naJu9C0DRh5aBqKA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
