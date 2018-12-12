#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::EndOfYearDonationMailingList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::EndOfYearDonationMailingList

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

=head1 TABLE: C<end_of_year_donation_mailing_list>

=cut

__PACKAGE__->table("end_of_year_donation_mailing_list");
__PACKAGE__->result_source_instance->view_definition(" SELECT format_names_by_family(array_agg(recently_relevant_person.person_id)) AS names,\n    person_address_for_mailing.street_line_1,\n    person_address_for_mailing.street_line_2,\n    person_address_for_mailing.city,\n    person_address_for_mailing.state_abbr,\n    person_address_for_mailing.zip,\n    person_address_for_mailing.plus_four\n   FROM ((recently_relevant_person\n     JOIN person USING (person_id))\n     JOIN person_address_for_mailing USING (person_id))\n  WHERE (person.opted_out = false)\n  GROUP BY person_address_for_mailing.street_line_1, person_address_for_mailing.street_line_2, person_address_for_mailing.city, person_address_for_mailing.state_abbr, person_address_for_mailing.zip, person_address_for_mailing.plus_four");

=head1 ACCESSORS

=head2 names

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
  "names",
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-10 22:45:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mEjDR0zsITdvnzPQPsd3Cw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
