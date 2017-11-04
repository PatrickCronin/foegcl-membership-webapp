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

=head2 affiliation_year

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

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
  "affiliation_year",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
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

=head2 affiliation_year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "affiliation_year",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear",
  { affiliation_year => "affiliation_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
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
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-10-29 23:09:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MYE+IJOJ5Ob95g9GsKwG4A

sub membership_donation_type ( $self ) {
  return $self->affiliation_year->membership_donation_types->search_rs(
      {
        donation_type => {
          -in => $self->donations->get_column('donation_type')->as_query
        },
      },
    )->single;
}

1;
