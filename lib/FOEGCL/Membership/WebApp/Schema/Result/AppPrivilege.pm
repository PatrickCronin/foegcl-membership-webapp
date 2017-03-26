use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::AppPrivilege;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::AppPrivilege

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

=head1 TABLE: C<app_privilege>

=cut

__PACKAGE__->table("app_privilege");

=head1 ACCESSORS

=head2 privilege_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'app_privilege_privilege_id_seq'

=head2 privilege_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

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
  "privilege_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "app_privilege_privilege_id_seq",
  },
  "privilege_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
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

=item * L</privilege_id>

=back

=cut

__PACKAGE__->set_primary_key("privilege_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<app_privilege_privilege_name_key>

=over 4

=item * L</privilege_name>

=back

=cut

__PACKAGE__->add_unique_constraint("app_privilege_privilege_name_key", ["privilege_name"]);

=head1 RELATIONS

=head2 app_role_has_privileges

Type: has_many

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::AppRoleHasPrivilege>

=cut

__PACKAGE__->has_many(
  "app_role_has_privileges",
  "FOEGCL::Membership::WebApp::Schema::Result::AppRoleHasPrivilege",
  { "foreign.privilege_id" => "self.privilege_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6b0XgwUbwaVRVPpQVYNTYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
