#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Affiliation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Affiliation

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

=head1 TABLE: C<affiliation>

=cut

__PACKAGE__->table("affiliation");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'affiliation_affiliation_id_seq'

=head2 year

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

=head2 membership_type

  data_type: 'enum'
  extra: {custom_type_name => "membership_type",list => ["individual_membership","household_membership"]}
  is_foreign_key: 1
  is_nullable: 1

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 0
  size: [11,0]

This value should follow a renewed affiliation. Otherwise, a new one should be assigned.

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
  "affiliation_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "affiliation_affiliation_id_seq",
  },
  "year",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
  "membership_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "membership_type",
      list => ["individual_membership", "household_membership"],
    },
    is_foreign_key => 1,
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

=item * L</affiliation_id>

=back

=cut

__PACKAGE__->set_primary_key("affiliation_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<affiliation__year__friend_id>

=over 4

=item * L</year>

=item * L</friend_id>

=back

=cut

__PACKAGE__->add_unique_constraint("affiliation__year__friend_id", ["year", "friend_id"]);

=head1 RELATIONS

=head2 affiliation_people

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationPerson>

=cut

__PACKAGE__->has_many(
  "affiliation_people",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationPerson",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 donations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Donation>

=cut

__PACKAGE__->has_many(
  "donations",
  "FOEGCL::Membership::Schema::WebApp::Result::Donation",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 membership_type_parameter

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter>

=cut

__PACKAGE__->belongs_to(
  "membership_type_parameter",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter",
  { membership_type => "membership_type", year => "year" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "CASCADE",
  },
);

=head2 year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "year",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear",
  { affiliation_year => "year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-24 23:46:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ntTlzSHdzTlkvb4uYxc+Dw

sub people ( $self ) {
    return $self->result_source->schema->resultset('Person')->search_rs(
        { 'affiliation_people.affiliation_id' => $self->id },
        { join => 'affiliation_people' }
    );
}

1;
