use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::Role

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

=head1 TABLE: C<Roles>

=cut

__PACKAGE__->table("Roles");

=head1 ACCESSORS

=head2 RoleRecordID

  accessor: 'role_record_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 FriendID

  accessor: 'friend_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 RoleTypeID

  accessor: 'role_type_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "RoleRecordID",
  {
    accessor          => "role_record_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "FriendID",
  {
    accessor       => "friend_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "RoleTypeID",
  {
    accessor       => "role_type_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 1,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<FriendRoleUx>

=over 4

=item * L</FriendID>

=item * L</RoleTypeID>

=back

=cut

__PACKAGE__->add_unique_constraint("FriendRoleUx", ["FriendID", "RoleTypeID"]);

=head1 RELATIONS

=head2 friend

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::Friend>

=cut

__PACKAGE__->belongs_to(
  "friend",
  "FOEGCL::Membership::Schema::Legacy::Result::Friend",
  { FriendID => "FriendID" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 role_type

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::RolesType>

=cut

__PACKAGE__->belongs_to(
  "role_type",
  "FOEGCL::Membership::Schema::Legacy::Result::RolesType",
  { RoleId => "RoleTypeID" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-07 23:34:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0clKvxKtKhbIKCpRl6dAzw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
