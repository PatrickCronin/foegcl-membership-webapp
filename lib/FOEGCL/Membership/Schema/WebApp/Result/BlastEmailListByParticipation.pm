#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::BlastEmailListByParticipation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::BlastEmailListByParticipation

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

=head1 TABLE: C<blast_email_list_by_participation>

=cut

__PACKAGE__->table("blast_email_list_by_participation");
__PACKAGE__->result_source_instance->view_definition(" SELECT DISTINCT person_email.email_address\n   FROM ((participation_record\n     JOIN person USING (person_id))\n     JOIN person_email USING (person_id))\n  WHERE (((participation_record.year)::double precision = ANY (ARRAY[(date_part('year'::text, ('now'::text)::date) - (1)::double precision), date_part('year'::text, ('now'::text)::date)])) AND (person.opted_out = false))");

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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B1xm5AU+EN6kZg4AkkBGDg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
