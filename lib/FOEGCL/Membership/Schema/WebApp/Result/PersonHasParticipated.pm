use utf8;

package FOEGCL::Membership::Schema::WebApp::Result::PersonHasParticipated;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::PersonHasParticipated

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

__PACKAGE__->load_components( "InflateColumn::DateTime",
    "InflateColumn::Serializer" );

=head1 TABLE: C<person_has_participated>

=cut

__PACKAGE__->table("person_has_participated");

=head1 ACCESSORS

=head2 membership_year

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  size: [4,0]

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 participation_role_id

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
    "membership_year",
    {
        data_type      => "numeric",
        is_foreign_key => 1,
        is_nullable    => 0,
        size           => [ 4, 0 ],
    },
    "person_id",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    "participation_role_id",
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

=item * L</membership_year>

=item * L</person_id>

=item * L</participation_role_id>

=back

=cut

__PACKAGE__->set_primary_key( "membership_year", "person_id",
    "participation_role_id" );

=head1 RELATIONS

=head2 membership_year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipYear>

=cut

__PACKAGE__->belongs_to(
    "membership_year",
    "FOEGCL::Membership::Schema::WebApp::Result::MembershipYear",
    { year          => "membership_year" },
    { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 participation_role

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole>

=cut

__PACKAGE__->belongs_to(
    "participation_role",
    "FOEGCL::Membership::Schema::WebApp::Result::ParticipationRole",
    { participation_role_id => "participation_role_id" },
    { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 person

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Person>

=cut

__PACKAGE__->belongs_to(
    "person",
    "FOEGCL::Membership::Schema::WebApp::Result::Person",
    { person_id     => "person_id" },
    { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-07 23:32:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JXlOE3RTX66B9Jki+6YuCw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
