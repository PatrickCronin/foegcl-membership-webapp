#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportAnnualFriendContributionAgg;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportAnnualFriendContributionAgg

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

=head1 TABLE: C<contributing_friends_report_annual_friend_contribution_agg>

=cut

__PACKAGE__->table("contributing_friends_report_annual_friend_contribution_agg");
__PACKAGE__->result_source_instance->view_definition(" SELECT affiliation.year,\n    affiliation.friend_id,\n    COALESCE(sum(contribution.amount), (0)::numeric) AS total_contributed,\n    COALESCE(membership_type_parameters.membership_amount, (0)::numeric) AS membership_portion_of_contributions,\n    (COALESCE(sum(contribution.amount), (0)::numeric) - COALESCE(membership_type_parameters.membership_amount, (0)::numeric)) AS donation_portion_of_contributions,\n    count(contribution.amount) AS number_of_contributions\n   FROM ((contribution\n     JOIN affiliation USING (affiliation_id))\n     LEFT JOIN membership_type_parameters USING (year, membership_type))\n  GROUP BY affiliation.year, affiliation.friend_id, membership_type_parameters.membership_amount");

=head1 ACCESSORS

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

=head2 total_contributed

  data_type: 'numeric'
  is_nullable: 1

=head2 membership_portion_of_contributions

  data_type: 'numeric'
  is_nullable: 1

=head2 donation_portion_of_contributions

  data_type: 'numeric'
  is_nullable: 1

=head2 number_of_contributions

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "year",
  { data_type => "smallint", is_nullable => 1 },
  "friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
  "total_contributed",
  { data_type => "numeric", is_nullable => 1 },
  "membership_portion_of_contributions",
  { data_type => "numeric", is_nullable => 1 },
  "donation_portion_of_contributions",
  { data_type => "numeric", is_nullable => 1 },
  "number_of_contributions",
  { data_type => "bigint", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mGDbJyfnKLJfUTPAzIhWng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
