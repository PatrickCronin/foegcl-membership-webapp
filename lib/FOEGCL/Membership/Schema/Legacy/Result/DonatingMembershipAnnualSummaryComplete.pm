#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::DonatingMembershipAnnualSummaryComplete;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::DonatingMembershipAnnualSummaryComplete

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

=head1 TABLE: C<DonatingMembershipAnnualSummaryComplete>

=cut

__PACKAGE__->table("DonatingMembershipAnnualSummaryComplete");

=head1 ACCESSORS

=head2 DataYear

  accessor: 'data_year'
  data_type: 'smallint'
  is_nullable: 1

=head2 Memberships

  accessor: 'memberships'
  data_type: 'integer'
  is_nullable: 1

=head2 Renewed

  accessor: 'renewed'
  data_type: 'integer'
  is_nullable: 1

=head2 Refreshed

  accessor: 'refreshed'
  data_type: 'integer'
  is_nullable: 1

=head2 New

  accessor: 'new_memberships'
  data_type: 'integer'
  is_nullable: 1

=head2 Donation Sum

  accessor: 'donation_sum'
  data_type: 'money'
  is_nullable: 1
  original: {data_type => "currency"}

=head2 Donation Total

  accessor: 'donation_total'
  data_type: 'double precision'
  is_nullable: 1
  original: {data_type => "double"}

=cut

__PACKAGE__->add_columns(
  "DataYear",
  { accessor => "data_year", data_type => "smallint", is_nullable => 1 },
  "Memberships",
  { accessor => "memberships", data_type => "integer", is_nullable => 1 },
  "Renewed",
  { accessor => "renewed", data_type => "integer", is_nullable => 1 },
  "Refreshed",
  { accessor => "refreshed", data_type => "integer", is_nullable => 1 },
  "New",
  { accessor => "new_memberships", data_type => "integer", is_nullable => 1 },
  "Donation Sum",
  {
    accessor    => "donation_sum",
    data_type   => "money",
    is_nullable => 1,
    original    => { data_type => "currency" },
  },
  "Donation Total",
  {
    accessor    => "donation_total",
    data_type   => "double precision",
    is_nullable => 1,
    original    => { data_type => "double" },
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-23 21:26:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GFeqi5NxovRfLUPmExOaSQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
