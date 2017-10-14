use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Person

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

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'person_person_id_seq'

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 last_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 opted_out

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
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "person_person_id_seq",
  },
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "last_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "opted_out",
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

=back

=cut

__PACKAGE__->set_primary_key("person_id");

=head1 RELATIONS

=head2 mailing_address

Type: might_have

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MailingAddress>

=cut

__PACKAGE__->might_have(
  "mailing_address",
  "FOEGCL::Membership::Schema::WebApp::Result::MailingAddress",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 membership_year_voter_registrations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipYearVoterRegistration>

=cut

__PACKAGE__->has_many(
  "membership_year_voter_registrations",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipYearVoterRegistration",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participation_interests

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationInterest>

=cut

__PACKAGE__->has_many(
  "participation_interests",
  "FOEGCL::Membership::Schema::WebApp::Result::ParticipationInterest",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participation_records

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationRecord>

=cut

__PACKAGE__->has_many(
  "participation_records",
  "FOEGCL::Membership::Schema::WebApp::Result::ParticipationRecord",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_emails

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PersonEmail>

=cut

__PACKAGE__->has_many(
  "person_emails",
  "FOEGCL::Membership::Schema::WebApp::Result::PersonEmail",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_memberships

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PersonMembership>

=cut

__PACKAGE__->has_many(
  "person_memberships",
  "FOEGCL::Membership::Schema::WebApp::Result::PersonMembership",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_phones

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PersonPhone>

=cut

__PACKAGE__->has_many(
  "person_phones",
  "FOEGCL::Membership::Schema::WebApp::Result::PersonPhone",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 physical_address

Type: might_have

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress>

=cut

__PACKAGE__->might_have(
  "physical_address",
  "FOEGCL::Membership::Schema::WebApp::Result::PhysicalAddress",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-13 23:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lRfFFV6mKdHMiWlZgO5Tfg

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
