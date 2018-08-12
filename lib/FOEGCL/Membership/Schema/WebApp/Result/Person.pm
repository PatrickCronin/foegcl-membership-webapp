#<<<
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

=head2 source_friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

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
  "source_friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
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

=head2 affiliation_people

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationPerson>

=cut

__PACKAGE__->has_many(
  "affiliation_people",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationPerson",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 voter_registrations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::VoterRegistration>

=cut

__PACKAGE__->has_many(
  "voter_registrations",
  "FOEGCL::Membership::Schema::WebApp::Result::VoterRegistration",
  { "foreign.person_id" => "self.person_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-06 18:10:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LMHv/Y3SQO5t6kyimoO7uw

sub name_as_text ($self) {
    my @names = ( $self->first_name, $self->last_name );
    my $name = join q{ }, grep { $_ } @names;
    return $name;
}

sub emails ( $self ) {
    return map { $_->email_address }
        sort { $b->is_preferred <=> $a->is_preferred }
        $self->person_emails->all;
}

sub phones ($self) {
    return map { $_->as_text }
        sort { $b->is_preferred <=> $a->is_preferred }
        $self->person_phones->all;
}

1;
