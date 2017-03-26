use utf8;
package FOEGCL::Membership::WebApp::Schema::Result::PersonPhone;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::WebApp::Schema::Result::PersonPhone

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

=head1 TABLE: C<person_phone>

=cut

__PACKAGE__->table("person_phone");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 phone_number

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 is_preferred

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
  "person_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "phone_number",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "is_preferred",
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

=item * L</person_id>

=item * L</phone_number>

=back

=cut

__PACKAGE__->set_primary_key("person_id", "phone_number");

=head1 RELATIONS

=head2 person

Type: belongs_to

Related object: L<FOEGCL::Membership::WebApp::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "FOEGCL::Membership::WebApp::Schema::Result::Person",
  { person_id => "person_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uF8+TrijoWNZWXOQXVHILA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
