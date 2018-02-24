#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Membership;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Membership

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

=head1 TABLE: C<membership>

=cut

__PACKAGE__->table("membership");

=head1 ACCESSORS

=head2 membership_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'membership_membership_id_seq'

=head2 membership_year

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

=head2 membership_type

  data_type: 'enum'
  extra: {custom_type_name => "membership_type",list => ["individual_membership","household_membership"]}
  is_nullable: 1

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 0
  size: [11,0]

This value should follow a renewed membership. Otherwise, a new one should be assigned.

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
  "membership_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "membership_membership_id_seq",
  },
  "membership_year",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
  "membership_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "membership_type",
      list => ["individual_membership", "household_membership"],
    },
    is_nullable => 1,
  },
  "friend_id",
  { data_type => "numeric", is_nullable => 0, size => [11, 0] },
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

=item * L</membership_id>

=back

=cut

__PACKAGE__->set_primary_key("membership_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<membership__membership_year__friend_id>

=over 4

=item * L</membership_year>

=item * L</friend_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "membership__membership_year__friend_id",
  ["membership_year", "friend_id"],
);

=head1 RELATIONS

=head2 donations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "FOEGCL::Membership::Schema::WebApp::Result::Donation",
  { "foreign.membership_id" => "self.membership_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 membership_people

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipPerson>

=cut

__PACKAGE__->has_many(
  "membership_people",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipPerson",
  { "foreign.membership_id" => "self.membership_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 membership_year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipYear>

=cut

__PACKAGE__->belongs_to(
  "membership_year",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipYear",
  { membership_year => "membership_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-23 21:26:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:n21Q+sRtifgcSz4sPSDvhQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
