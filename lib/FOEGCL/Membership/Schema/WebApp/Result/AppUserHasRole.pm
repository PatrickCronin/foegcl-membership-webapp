#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::AppUserHasRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::AppUserHasRole

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

=head1 TABLE: C<app_user_has_role>

=cut

__PACKAGE__->table("app_user_has_role");

=head1 ACCESSORS

=head2 username

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 128

=head2 role_id

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
  "username",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 128 },
  "role_id",
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

=item * L</username>

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("username", "role_id");

=head1 RELATIONS

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

=head2 username

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AppUser>

=cut

__PACKAGE__->belongs_to(
  "username",
  "FOEGCL::Membership::Schema::WebApp::Result::AppUser",
  { username => "username" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-11-16 22:30:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cvb0ngF26coN7N/5AkGJtg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
