#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::MembershipTypeParameter

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

=head1 TABLE: C<membership_type_parameters>

=cut

__PACKAGE__->table("membership_type_parameters");

=head1 ACCESSORS

=head2 year

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

=head2 membership_type

  data_type: 'enum'
  extra: {custom_type_name => "membership_type",list => ["individual_membership","household_membership","senior_student_individual_membership","senior_household_membership"]}
  is_nullable: 0

=head2 membership_max_people

  data_type: 'smallint'
  default_value: 1
  is_nullable: 1

=head2 membership_amount

  data_type: 'numeric'
  is_nullable: 0
  size: [11,2]

=cut

__PACKAGE__->add_columns(
  "year",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
  "membership_type",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "membership_type",
      list => [
        "individual_membership",
        "household_membership",
        "senior_student_individual_membership",
        "senior_household_membership",
      ],
    },
    is_nullable => 0,
  },
  "membership_max_people",
  { data_type => "smallint", default_value => 1, is_nullable => 1 },
  "membership_amount",
  { data_type => "numeric", is_nullable => 0, size => [11, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</year>

=item * L</membership_type>

=back

=cut

__PACKAGE__->set_primary_key("year", "membership_type");

=head1 RELATIONS

=head2 affiliations

Type: has_many

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::Affiliation>

=cut

__PACKAGE__->has_many(
  "affiliations",
  "FOEGCL::Membership::Schema::WebApp::Result::Affiliation",
  {
    "foreign.membership_type" => "self.membership_type",
    "foreign.year" => "self.year",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear>

=cut

__PACKAGE__->belongs_to(
  "year",
  "FOEGCL::Membership::Schema::WebApp::Result::AffiliationYear",
  { year => "year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-06 13:55:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L+n8i1pD28PRw+vkMTxGmw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
