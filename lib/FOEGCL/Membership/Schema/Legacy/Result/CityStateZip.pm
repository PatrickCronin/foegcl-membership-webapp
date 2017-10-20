#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::CityStateZip;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::CityStateZip

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

=head1 TABLE: C<CityStateZip>

=cut

__PACKAGE__->table("CityStateZip");

=head1 ACCESSORS

=head2 City

  accessor: 'city'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 State

  accessor: 'state'
  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 PostalCode

  accessor: 'postal_code'
  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "City",
  { accessor => "city", data_type => "varchar", is_nullable => 1, size => 50 },
  "State",
  { accessor => "state", data_type => "varchar", is_nullable => 1, size => 2 },
  "PostalCode",
  {
    accessor => "postal_code",
    data_type => "varchar",
    is_nullable => 0,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</PostalCode>

=back

=cut

__PACKAGE__->set_primary_key("PostalCode");

=head1 RELATIONS

=head2 friends

Type: has_many

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::Friend>

=cut

__PACKAGE__->has_many(
  "friends",
  "FOEGCL::Membership::Schema::Legacy::Result::Friend",
  { "foreign.CityStateZip_ID" => "self.PostalCode" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-17 22:16:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AL1mG7FReYWgQQ6ZwpEnOg

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
