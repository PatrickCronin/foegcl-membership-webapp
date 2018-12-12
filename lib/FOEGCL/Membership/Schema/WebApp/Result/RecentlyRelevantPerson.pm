#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::RecentlyRelevantPerson;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::RecentlyRelevantPerson

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

=head1 TABLE: C<recently_relevant_person>

=cut

__PACKAGE__->table("recently_relevant_person");
__PACKAGE__->result_source_instance->view_definition(" SELECT person.person_id\n   FROM (((person\n     JOIN affiliation_person USING (person_id))\n     JOIN affiliation USING (affiliation_id))\n     JOIN contribution USING (affiliation_id))\n  WHERE ((affiliation.year)::double precision >= (date_part('year'::text, ('now'::text)::date) - (2)::double precision))\nUNION\n SELECT participation_interest.person_id\n   FROM participation_interest\nUNION\n SELECT participation_record.person_id\n   FROM participation_record\n  WHERE ((participation_record.year)::double precision >= (date_part('year'::text, ('now'::text)::date) - (2)::double precision))");

=head1 ACCESSORS

=head2 person_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns("person_id", { data_type => "integer", is_nullable => 1 });
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-10 22:45:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Pcpf6WQaXmNXW+gdS8GSHw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
