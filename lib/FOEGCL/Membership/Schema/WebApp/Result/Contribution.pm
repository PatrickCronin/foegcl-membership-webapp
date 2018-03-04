#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Contribution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Contribution

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

=head1 TABLE: C<contribution>

=cut

__PACKAGE__->table("contribution");

=head1 ACCESSORS

=head2 contribution_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'contribution_contribution_id_seq'

=head2 affiliation_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 amount

  data_type: 'numeric'
  is_nullable: 0
  size: [11,2]

=head2 notes

  data_type: 'varchar'
  is_nullable: 1
  size: 128

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
  "contribution_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "contribution_contribution_id_seq",
  },
  "affiliation_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "amount",
  { data_type => "numeric", is_nullable => 0, size => [11, 2] },
  "notes",
  { data_type => "varchar", is_nullable => 1, size => 128 },
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

=item * L</contribution_id>

=back

=cut

__PACKAGE__->set_primary_key("contribution_id");

=head1 RELATIONS

=head2 affiliation

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Affiliation>

=cut

__PACKAGE__->belongs_to(
  "affiliation",
  "FOEGCL::Membership::Schema::WebApp::Result::Affiliation",
  { affiliation_id => "affiliation_id" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-03-03 21:15:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l9S1UggXGanLhnvmy0gVxQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
