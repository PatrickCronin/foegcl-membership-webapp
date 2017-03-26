use utf8;
package FOEGCL::Membership::Legacy::Schema::Result::ContactInfo;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Legacy::Schema::Result::ContactInfo

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

=head1 TABLE: C<ContactInfo>

=cut

__PACKAGE__->table("ContactInfo");

=head1 ACCESSORS

=head2 ContactID

  accessor: 'contact_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 FriendID

  accessor: 'friend_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 Email_Address

  accessor: 'email_address'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 Area Code

  accessor: 'area_code'
  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 Phone Number

  accessor: 'phone_number'
  data_type: 'varchar'
  is_nullable: 1
  size: 8

=head2 Preferred

  accessor: 'preferred'
  data_type: 'bit'
  is_nullable: 0

=head2 ContactTypeID

  accessor: 'contact_type_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ContactID",
  {
    accessor          => "contact_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "FriendID",
  {
    accessor       => "friend_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Email_Address",
  {
    accessor => "email_address",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
  "Area Code",
  {
    accessor => "area_code",
    data_type => "varchar",
    is_nullable => 1,
    size => 3,
  },
  "Phone Number",
  {
    accessor => "phone_number",
    data_type => "varchar",
    is_nullable => 1,
    size => 8,
  },
  "Preferred",
  { accessor => "preferred", data_type => "bit", is_nullable => 0 },
  "ContactTypeID",
  {
    accessor       => "contact_type_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ContactID>

=back

=cut

__PACKAGE__->set_primary_key("ContactID");

=head1 RELATIONS

=head2 contact_type

Type: belongs_to

Related object: L<FOEGCL::Membership::Legacy::Schema::Result::ContactType>

=cut

__PACKAGE__->belongs_to(
  "contact_type",
  "FOEGCL::Membership::Legacy::Schema::Result::ContactType",
  { ID => "ContactTypeID" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 friend

Type: belongs_to

Related object: L<FOEGCL::Membership::Legacy::Schema::Result::Friend>

=cut

__PACKAGE__->belongs_to(
  "friend",
  "FOEGCL::Membership::Legacy::Schema::Result::Friend",
  { FriendID => "FriendID" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d4fywo7hbK2ikvu28KkMPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
