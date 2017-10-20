#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::MembershipYear;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::MembershipYear

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

=head1 TABLE: C<membership_year>

=cut

__PACKAGE__->table("membership_year");

=head1 ACCESSORS

=head2 membership_year

  data_type: 'smallint'
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
  "membership_year",
  { data_type => "smallint", is_nullable => 0 },
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

=item * L</membership_year>

=back

=cut

__PACKAGE__->set_primary_key("membership_year");

=head1 RELATIONS

=head2 membership_donation_types

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType>

=cut

__PACKAGE__->has_many(
  "membership_donation_types",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType",
  { "foreign.membership_year" => "self.membership_year" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 membership_year_voter_registrations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipYearVoterRegistration>

=cut

__PACKAGE__->has_many(
  "membership_year_voter_registrations",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipYearVoterRegistration",
  { "foreign.membership_year" => "self.membership_year" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 memberships

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Membership>

=cut

__PACKAGE__->has_many(
  "memberships",
  "FOEGCL::Membership::Schema::WebApp::Result::Membership",
  { "foreign.membership_year" => "self.membership_year" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 participation_records

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::ParticipationRecord>

=cut

__PACKAGE__->has_many(
  "participation_records",
  "FOEGCL::Membership::Schema::WebApp::Result::ParticipationRecord",
  { "foreign.membership_year" => "self.membership_year" },
  { cascade_copy => 0, cascade_delete => 0 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-17 22:17:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+rU6CSLoXWAtIFqR83nXDw

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
