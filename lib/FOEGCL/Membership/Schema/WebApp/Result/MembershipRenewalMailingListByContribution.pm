#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::MembershipRenewalMailingListByContribution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::MembershipRenewalMailingListByContribution - This is just for ETL testing.

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
__PACKAGE__->table_class("DBIx::Class::ResultSource::View");

=head1 TABLE: C<membership_renewal_mailing_list_by_contribution>

=cut

__PACKAGE__->table("membership_renewal_mailing_list_by_contribution");
__PACKAGE__->result_source_instance->view_definition(" SELECT format_names_by_family(array_agg(person.person_id)) AS recipients,\n    person_address_for_mailing.street_line_1,\n    person_address_for_mailing.street_line_2,\n    person_address_for_mailing.city,\n    person_address_for_mailing.state_abbr,\n    person_address_for_mailing.zip,\n    person_address_for_mailing.plus_four\n   FROM (((person\n     JOIN person_address_for_mailing USING (person_id))\n     JOIN ( SELECT affiliation_person.person_id\n           FROM ((affiliation_person\n             JOIN affiliation USING (affiliation_id))\n             JOIN contribution USING (affiliation_id))\n          WHERE ((affiliation.year)::double precision >= (date_part('year'::text, ('now'::text)::date) - (2)::double precision))) contributors_in_the_recent_past USING (person_id))\n     LEFT JOIN ( SELECT affiliation_person.person_id,\n            1 AS has_current_membership\n           FROM (affiliation_person\n             JOIN membership USING (affiliation_id))\n          WHERE ((membership.year)::double precision = date_part('year'::text, ('now'::text)::date))) current_memberships USING (person_id))\n  WHERE ((person.opted_out = false) AND (current_memberships.has_current_membership IS NULL))\n  GROUP BY person_address_for_mailing.street_line_1, person_address_for_mailing.street_line_2, person_address_for_mailing.city, person_address_for_mailing.state_abbr, person_address_for_mailing.zip, person_address_for_mailing.plus_four");

=head1 ACCESSORS

=head2 recipients

  data_type: 'text'
  is_nullable: 1

=head2 street_line_1

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 street_line_2

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 state_abbr

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 zip

  data_type: 'char'
  is_nullable: 1
  size: 5

=head2 plus_four

  data_type: 'char'
  is_nullable: 1
  size: 4

=cut

__PACKAGE__->add_columns(
  "recipients",
  { data_type => "text", is_nullable => 1 },
  "street_line_1",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "street_line_2",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "state_abbr",
  { data_type => "char", is_nullable => 1, size => 2 },
  "zip",
  { data_type => "char", is_nullable => 1, size => 5 },
  "plus_four",
  { data_type => "char", is_nullable => 1, size => 4 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-12 22:05:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oZiznD4qkBUHm7rNmvtIXw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
