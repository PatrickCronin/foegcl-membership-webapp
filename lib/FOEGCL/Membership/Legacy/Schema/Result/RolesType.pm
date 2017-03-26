use utf8;
package FOEGCL::Membership::Legacy::Schema::Result::RolesType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Legacy::Schema::Result::RolesType - Historical tracks a volunteer who has completed a task. 

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

=head1 TABLE: C<RolesTypes>

=cut

__PACKAGE__->table("RolesTypes");

=head1 ACCESSORS

=head2 RoleId

  accessor: 'role_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 Role

  accessor: 'role'
  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 Historical

  accessor: 'historical'
  data_type: 'bit'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "RoleId",
  {
    accessor          => "role_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "Role",
  { accessor => "role", data_type => "varchar", is_nullable => 0, size => 50 },
  "Historical",
  { accessor => "historical", data_type => "bit", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</RoleId>

=back

=cut

__PACKAGE__->set_primary_key("RoleId");

=head1 RELATIONS

=head2 roles

Type: has_many

Related object: L<FOEGCL::Membership::Legacy::Schema::Result::Role>

=cut

__PACKAGE__->has_many(
  "roles",
  "FOEGCL::Membership::Legacy::Schema::Result::Role",
  { "foreign.RoleTypeID" => "self.RoleId" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rrKGT5wCVsgl9hJr5y7i1A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
