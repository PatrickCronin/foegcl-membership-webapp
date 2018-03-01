#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::AppUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::AppUser

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

=head1 TABLE: C<app_user>

=cut

__PACKAGE__->table("app_user");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'app_user_user_id_seq'

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 password_hash

  data_type: 'bytea'
  is_nullable: 0

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 last_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 login_enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 1

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
  "user_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "app_user_user_id_seq",
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "password_hash",
  { data_type => "bytea", is_nullable => 0 },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "login_enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 1 },
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

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<username_is_unique>

=over 4

=item * L</username>

=back

=cut

__PACKAGE__->add_unique_constraint("username_is_unique", ["username"]);

=head1 RELATIONS

=head2 app_user_has_roles

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AppUserHasRole>

=cut

__PACKAGE__->has_many(
  "app_user_has_roles",
  "FOEGCL::Membership::Schema::WebApp::Result::AppUserHasRole",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-24 23:46:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eGN/rpsIr2Za5/ZUGO3qAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
