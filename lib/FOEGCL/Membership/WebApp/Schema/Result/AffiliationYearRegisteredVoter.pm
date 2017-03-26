use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::AffiliationYearRegisteredVoter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::AffiliationYearRegisteredVoter

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

=head1 TABLE: C<affiliation_year_registered_voter>

=cut

__PACKAGE__->table("affiliation_year_registered_voter");

=head1 ACCESSORS

=head2 affiliation_year

  data_type: 'numeric'
  is_foreign_key: 1
  is_nullable: 0
  size: [4,0]

=head2 person_id

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
  "affiliation_year",
  {
    data_type => "numeric",
    is_foreign_key => 1,
    is_nullable => 0,
    size => [4, 0],
  },
  "person_id",
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

=item * L</affiliation_year>

=item * L</person_id>

=back

=cut

__PACKAGE__->set_primary_key("affiliation_year", "person_id");

=head1 RELATIONS

=head2 affiliation_year

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "affiliation_year",
  "FOEGCL::Membership::WebApp::Schema::Result::AffiliationYear",
  { year => "affiliation_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 person

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "FOEGCL::Membership::WebApp::Schema::Result::Person",
  { person_id => "person_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4qUluxO+JVfQK/JRE+olcw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
