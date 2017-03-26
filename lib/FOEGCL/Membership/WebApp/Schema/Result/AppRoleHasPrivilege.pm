use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::AppRoleHasPrivilege;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::AppRoleHasPrivilege

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

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::AppPrivilege>

=cut

__PACKAGE__->belongs_to(
  "privilege",
  "FOEGCL::Membership::WebApp::Schema::Result::AppPrivilege",
  { privilege_id => "privilege_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 role

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::AppRole>

=cut

__PACKAGE__->belongs_to(
  "role",
  "FOEGCL::Membership::WebApp::Schema::Result::AppRole",
  { role_id => "role_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VTP2CBgFaaPwSfhevxNr7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
