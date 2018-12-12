#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::CurrentMembershipList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::CurrentMembershipList

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

=head1 TABLE: C<current_membership_list>

=cut

__PACKAGE__->table("current_membership_list");
__PACKAGE__->result_source_instance->view_definition(" SELECT membership.friend_id,\n    person.first_name,\n    person.last_name,\n    (((person.last_name)::text || ', '::text) || (person.first_name)::text) AS name,\n    ((COALESCE(physical_address.street_line_1))::text || COALESCE(('\n'::text || (physical_address.street_line_2)::text), ''::text)) AS street_lines,\n    ((((((city_state_zip.city)::text || ', '::text) || (city_state_zip.state_abbr)::text) || ' '::text) || (city_state_zip.zip)::text) || COALESCE(('-'::text || (physical_address.plus_four)::text), ''::text)) AS city_state_zip,\n    aggregated_email.emails,\n    aggregated_phone.phones\n   FROM ((((((person\n     JOIN affiliation_person USING (person_id))\n     JOIN membership USING (affiliation_id))\n     LEFT JOIN physical_address USING (person_id))\n     LEFT JOIN city_state_zip USING (csz_id))\n     LEFT JOIN ( SELECT person_email.person_id,\n            string_agg((person_email.email_address)::text, '\n'::text ORDER BY person_email.is_preferred DESC, (person_email.email_address)::text) AS emails\n           FROM person_email\n          GROUP BY person_email.person_id) aggregated_email USING (person_id))\n     LEFT JOIN ( SELECT person_phone.person_id,\n            string_agg((format_phone_number(person_phone.phone_number))::text, '\n'::text ORDER BY person_phone.is_preferred DESC, (format_phone_number(person_phone.phone_number))::text) AS phones\n           FROM person_phone\n          GROUP BY person_phone.person_id) aggregated_phone USING (person_id))\n  WHERE ((membership.year)::double precision = date_part('year'::text, ('now'::text)::date))\n  ORDER BY person.last_name, person.first_name");

=head1 ACCESSORS

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 street_lines

  data_type: 'text'
  is_nullable: 1

=head2 city_state_zip

  data_type: 'text'
  is_nullable: 1

=head2 emails

  data_type: 'text'
  is_nullable: 1

=head2 phones

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "name",
  { data_type => "text", is_nullable => 1 },
  "street_lines",
  { data_type => "text", is_nullable => 1 },
  "city_state_zip",
  { data_type => "text", is_nullable => 1 },
  "emails",
  { data_type => "text", is_nullable => 1 },
  "phones",
  { data_type => "text", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l6426f1NQe05dx4RIoxnPA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
