#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Member;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Member

=head1 DESCRIPTION

People belonging to affiliations with qualifiying memberhsip donations

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

=head1 TABLE: C<member>

=cut

__PACKAGE__->table("member");
__PACKAGE__->result_source_instance->view_definition(" SELECT membership.affiliation_id,\n    membership.affiliation_year,\n    membership.donation_type,\n    affiliation_person.person_id\n   FROM (membership\n     JOIN affiliation_person USING (affiliation_id))");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_nullable: 1

=head2 affiliation_year

  data_type: 'smallint'
  is_nullable: 1

=head2 donation_type

  data_type: 'enum'
  extra: {custom_type_name => "donation_type",list => ["individual_membership","household_membership","general_donation"]}
  is_nullable: 1

=head2 person_id

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "affiliation_id",
  { data_type => "integer", is_nullable => 1 },
  "affiliation_year",
  { data_type => "smallint", is_nullable => 1 },
  "donation_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "donation_type",
      list => [
        "individual_membership",
        "household_membership",
        "general_donation",
      ],
    },
    is_nullable => 1,
  },
  "person_id",
  { data_type => "integer", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-03 18:58:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eoAfUBnvTYhx+E2DJtBV/A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
