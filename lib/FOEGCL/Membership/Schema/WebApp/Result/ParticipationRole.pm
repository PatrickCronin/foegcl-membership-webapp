use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<participation_role>

=cut

__PACKAGE__->table("participation_role");

=head1 ACCESSORS

=head2 participation_role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'participation_role_participation_role_id_seq'

=head2 parent_role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 role_name

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 is_hidden

  data_type: 'boolean'
  default_value: false
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
  "participation_role_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "participation_role_participation_role_id_seq",
  },
  "parent_role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "role_name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "is_hidden",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
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

=item * L</participation_role_id>

=back

=cut

__PACKAGE__->set_primary_key("participation_role_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<role_name_is_unique>

=over 4

=item * L</role_name>

=back

=cut

__PACKAGE__->add_unique_constraint("role_name_is_unique", ["role_name"]);

=head1 RELATIONS

=head2 parent_role

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole>

=cut

__PACKAGE__->belongs_to(
  "parent_role",
  "FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole",
  { participation_role_id => "parent_role_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 participation_roles

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole>

=cut

__PACKAGE__->has_many(
  "participation_roles",
  "FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole",
  { "foreign.parent_role_id" => "self.participation_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 people_has_participated

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PersonHasParticipated>

=cut

__PACKAGE__->has_many(
  "people_has_participated",
  "FOEGCL::Membership::Schema::WebApp::Result::PersonHasParticipated",
  { "foreign.participation_role_id" => "self.participation_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_interesteds_in_participating

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PersonInterestedInParticipating>

=cut

__PACKAGE__->has_many(
  "person_interesteds_in_participating",
  "FOEGCL::Membership::Schema::WebApp::Result::PersonInterestedInParticipating",
  { "foreign.participation_role_id" => "self.participation_role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aR4+BuwnvQ5OE49jG0wWHA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
