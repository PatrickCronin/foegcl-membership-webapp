use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::Friend;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::Friend

=head1 DESCRIPTION

Central Table.  
-- Inactive is used only when a person has donated in the past. If they haven't donated, they can be delete. If marked inactive, clean up records in Roles or contactinfo tables.

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

=head1 TABLE: C<Friends>

=cut

__PACKAGE__->table("Friends");

=head1 ACCESSORS

=head2 FriendID

  accessor: 'friend_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 FirstName

  accessor: 'first_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 LastName

  accessor: 'last_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 SpouseFirstName

  accessor: 'spouse_first_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 SpouseLastName

  accessor: 'spouse_last_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 Address

  accessor: 'address'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 RegisteredVoter

  accessor: 'registered_voter'
  data_type: 'bit'
  is_nullable: 0

=head2 CityStateZip_ID

  accessor: 'city_state_zip_id'
  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 255

=head2 Inactive

  accessor: 'inactive'
  data_type: 'bit'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "FriendID",
  {
    accessor          => "friend_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "FirstName",
  {
    accessor => "first_name",
    data_type => "varchar",
    is_nullable => 1,
    size => 50,
  },
  "LastName",
  {
    accessor => "last_name",
    data_type => "varchar",
    is_nullable => 1,
    size => 50,
  },
  "SpouseFirstName",
  {
    accessor => "spouse_first_name",
    data_type => "varchar",
    is_nullable => 1,
    size => 50,
  },
  "SpouseLastName",
  {
    accessor => "spouse_last_name",
    data_type => "varchar",
    is_nullable => 1,
    size => 50,
  },
  "Address",
  {
    accessor => "address",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
  "RegisteredVoter",
  { accessor => "registered_voter", data_type => "bit", is_nullable => 0 },
  "CityStateZip_ID",
  {
    accessor => "city_state_zip_id",
    data_type => "varchar",
    is_foreign_key => 1,
    is_nullable => 1,
    size => 255,
  },
  "Inactive",
  { accessor => "inactive", data_type => "bit", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</FriendID>

=back

=cut

__PACKAGE__->set_primary_key("FriendID");

=head1 RELATIONS

=head2 city_state_zip

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::CityStateZip>

=cut

__PACKAGE__->belongs_to(
  "city_state_zip",
  "FOEGCL::Membership::Schema::Legacy::Result::CityStateZip",
  { PostalCode => "CityStateZip_ID" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 contact_infos

Type: has_many

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::ContactInfo>

=cut

__PACKAGE__->has_many(
  "contact_infos",
  "FOEGCL::Membership::Schema::Legacy::Result::ContactInfo",
  { "foreign.FriendID" => "self.FriendID" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 donations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "FOEGCL::Membership::Schema::Legacy::Result::Donation",
  { "foreign.FriendID" => "self.FriendID" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: has_many

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::Role>

=cut

__PACKAGE__->has_many(
  "roles",
  "FOEGCL::Membership::Schema::Legacy::Result::Role",
  { "foreign.FriendID" => "self.FriendID" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-07 23:34:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l9EnhDXcDP0dg7/cVRprRg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
