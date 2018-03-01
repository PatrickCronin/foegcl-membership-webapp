#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::AppRoleHasPrivilege;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::AppRoleHasPrivilege

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

=head1 TABLE: C<app_role_has_privilege>

=cut

__PACKAGE__->table("app_role_has_privilege");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 privilege_id

  data_type: 'integer'
  is_foreign_key: 1
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
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "privilege_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
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

=item * L</role_id>

=item * L</privilege_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id", "privilege_id");

=head1 RELATIONS

=head2 privilege

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AppPrivilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "FOEGCL::Membership::Schema::WebApp::Result::AppPrivilege",
  { privilege_id => "privilege_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 role

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AppRole>

=cut

__PACKAGE__->belongs_to(
  "role",
  "FOEGCL::Membership::Schema::WebApp::Result::AppRole",
  { role_id => "role_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-24 23:46:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YTfe3f2dQicz5qhle0x8TQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
