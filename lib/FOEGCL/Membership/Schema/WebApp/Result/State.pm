#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::State;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::State

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

=head1 TABLE: C<state>

=cut

__PACKAGE__->table("state");

=head1 ACCESSORS

=head2 state_abbr

  data_type: 'char'
  is_nullable: 0
  size: 2

=head2 state_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

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
  "state_abbr",
  { data_type => "char", is_nullable => 0, size => 2 },
  "state_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
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

=item * L</state_abbr>

=back

=cut

__PACKAGE__->set_primary_key("state_abbr");

=head1 UNIQUE CONSTRAINTS

=head2 C<state_name_is_unique>

=over 4

=item * L</state_name>

=back

=cut

__PACKAGE__->add_unique_constraint("state_name_is_unique", ["state_name"]);

=head1 RELATIONS

=head2 city_state_zips

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::CityStateZip>

=cut

__PACKAGE__->has_many(
  "city_state_zips",
  "FOEGCL::Membership::Schema::WebApp::Result::CityStateZip",
  { "foreign.state_abbr" => "self.state_abbr" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-17 22:17:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uH/0Hmp89bn8ajU4ezi9ug

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
