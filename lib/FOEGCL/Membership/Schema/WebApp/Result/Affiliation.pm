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

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<affiliation>

=cut

__PACKAGE__->table("affiliation");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'affiliation_affiliation_id_seq'

=head2 legacy_friend_id

  data_type: 'integer'
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
  "affiliation_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "affiliation_affiliation_id_seq",
  },
  "legacy_friend_id",
  { data_type => "integer", is_nullable => 0 },
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

=head2 mailing_address

Type: might_have

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MailingAddress>

=cut

__PACKAGE__->might_have(
  "mailing_address",
  "FOEGCL::Membership::Schema::WebApp::Result::MailingAddress",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 people

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Person>

=cut

__PACKAGE__->has_many(
  "people",
  "FOEGCL::Membership::Schema::WebApp::Result::Person",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 physical_address

Type: might_have

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress>

=cut

__PACKAGE__->might_have(
  "physical_address",
  "FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress",
  { "foreign.affiliation_id" => "self.affiliation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-04-23 12:33:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YF9VB15nbl/2w5mH1+gOkQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
