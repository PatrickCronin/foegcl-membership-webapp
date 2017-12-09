#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Membership;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Membership - Affiliations with a qualifying membership donation

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

=head1 TABLE: C<membership>

=cut

__PACKAGE__->table("membership");
__PACKAGE__->result_source_instance->view_definition(" SELECT donation.affiliation_id,\n    affiliation.affiliation_year,\n    donation.donation_type,\n    membership_donation_type.membership_max_people\n   FROM ((donation\n     JOIN affiliation USING (affiliation_id))\n     JOIN membership_donation_type USING (affiliation_year, donation_type))");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_nullable: 1

=head2 affiliation_year

  data_type: 'smallint'
  is_nullable: 1

=head2 donation_type

  data_type: 'enum'
  extra: {custom_type_name => "donation_type",list => ["individual_membership","household_membership","honorary_membership","general_donation"]}
  is_nullable: 1

=head2 membership_max_people

  data_type: 'smallint'
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
        "honorary_membership",
        "general_donation",
      ],
    },
    is_nullable => 1,
  },
  "membership_max_people",
  { data_type => "smallint", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-10-29 23:09:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RSxpu/C8BL9QoU17vXtgTw

=head2 affiliation

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Affiliation>

=cut

__PACKAGE__->belongs_to(
  'affiliation',
  'FOEGCL::Membership::Schema::WebApp::Result::Affiliation',
  { affiliation_id => 'affiliation_id' },
  { is_deferrable => 0, on_delete => 'CASCADE', on_update => 'CASCADE' },
);

1;
