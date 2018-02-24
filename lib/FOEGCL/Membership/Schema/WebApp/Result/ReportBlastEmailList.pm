#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ReportBlastEmailList;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ReportBlastEmailList

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

=head1 TABLE: C<report_blast_email_list>

=cut

__PACKAGE__->table("report_blast_email_list");
__PACKAGE__->result_source_instance->view_definition(" SELECT DISTINCT person_email.email_address\n   FROM (person\n     JOIN person_email USING (person_id))\n  WHERE ((person.person_id IN ( SELECT membership_person.person_id\n           FROM (membership_person\n             JOIN membership USING (membership_id))\n          WHERE ((membership.membership_year)::double precision = ANY (ARRAY[(date_part('year'::text, ('now'::text)::date) - (1)::double precision), date_part('year'::text, ('now'::text)::date)]))\n        UNION ALL\n         SELECT participation_interest.person_id\n           FROM participation_interest\n        UNION ALL\n         SELECT participation_record.person_id\n           FROM participation_record\n          WHERE ((participation_record.membership_year)::double precision = ANY (ARRAY[(date_part('year'::text, ('now'::text)::date) - (1)::double precision), date_part('year'::text, ('now'::text)::date)])))) AND (person.opted_out = false))");

=head1 ACCESSORS

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-23 21:26:16
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xGo6qK+vN3mJ1CekQ9GpEg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
