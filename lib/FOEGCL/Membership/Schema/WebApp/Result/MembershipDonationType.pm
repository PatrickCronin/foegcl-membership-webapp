use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::MembershipDonationType

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::InflateColumn::Serializer>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Serializer");

=head1 TABLE: C<membership_donation_type>

=cut

__PACKAGE__->table("membership_donation_type");

=head1 ACCESSORS

=head2 membership_year

  data_type: 'smallint'
  is_foreign_key: 1
  is_nullable: 0

=head2 donation_type

  data_type: 'enum'
  extra: {custom_type_name => "donation_type",list => ["individual_membership","household_membership","honorary_membership","general_donation"]}
  is_nullable: 0

=head2 membership_max_people

  data_type: 'smallint'
  is_nullable: 0

=head2 membership_amount

  data_type: 'numeric'
  is_nullable: 0
  size: [11,2]

=cut

__PACKAGE__->add_columns(
  "membership_year",
  { data_type => "smallint", is_foreign_key => 1, is_nullable => 0 },
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
    is_nullable => 0,
  },
  "membership_max_people",
  { data_type => "smallint", is_nullable => 0 },
  "membership_amount",
  { data_type => "numeric", is_nullable => 0, size => [11, 2] },
);

=head1 PRIMARY KEY

=over 4

=item * L</membership_year>

=item * L</donation_type>

=back

=cut

__PACKAGE__->set_primary_key("membership_year", "donation_type");

=head1 RELATIONS

=head2 membership_year

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::WebApp::Result::MembershipYear>

=cut

__PACKAGE__->belongs_to(
  "membership_year",
  "FOEGCL::Membership::Schema::WebApp::Result::MembershipYear",
  { membership_year => "membership_year" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-08 20:11:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hl8rSQtxQ424mcLM1lrmQA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
