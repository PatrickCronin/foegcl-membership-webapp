#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ReportContributingFriend;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ReportContributingFriend

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

=head1 TABLE: C<report_contributing_friends>

=cut

__PACKAGE__->table("report_contributing_friends");
__PACKAGE__->result_source_instance->view_definition(" SELECT affiliation_year.year,\n    annual_all_friend_contribution_agg.\"Contributing Friends\",\n    annual_renewals_agg.\"Renewees\",\n    annual_refreshees_agg.\"Refreshees\",\n    first_timers_agg.\"First Timers\",\n    annual_all_friend_contribution_agg.\"Total Contributed\",\n    annual_all_friend_contribution_agg.\"Of that, Membership\",\n    annual_all_friend_contribution_agg.\"Additional Donations\",\n    annual_all_friend_contribution_agg.\"Number of Contributions\"\n   FROM ((((affiliation_year\n     LEFT JOIN ( SELECT report_contributing_friends_annual_friend_contribution_agg.year,\n            count(*) AS \"Contributing Friends\",\n            COALESCE(sum(report_contributing_friends_annual_friend_contribution_agg.\"Total Contributed\"), (0)::numeric) AS \"Total Contributed\",\n            COALESCE(sum(report_contributing_friends_annual_friend_contribution_agg.\"Of that, Membership\"), (0)::numeric) AS \"Of that, Membership\",\n            COALESCE(sum(report_contributing_friends_annual_friend_contribution_agg.\"Additional Donations\"), (0)::numeric) AS \"Additional Donations\",\n            COALESCE(sum(report_contributing_friends_annual_friend_contribution_agg.\"Number of Contributions\"), (0)::numeric) AS \"Number of Contributions\"\n           FROM report_contributing_friends_annual_friend_contribution_agg\n          GROUP BY report_contributing_friends_annual_friend_contribution_agg.year) annual_all_friend_contribution_agg USING (year))\n     LEFT JOIN ( SELECT report_contributing_friends_renewees.year,\n            count(report_contributing_friends_renewees.renewee_friend_id) AS \"Renewees\"\n           FROM report_contributing_friends_renewees\n          GROUP BY report_contributing_friends_renewees.year) annual_renewals_agg USING (year))\n     LEFT JOIN ( SELECT report_contributing_friends_refreshees.year,\n            count(report_contributing_friends_refreshees.refreshee_friend_id) AS \"Refreshees\"\n           FROM report_contributing_friends_refreshees\n          GROUP BY report_contributing_friends_refreshees.year) annual_refreshees_agg USING (year))\n     LEFT JOIN ( SELECT report_contributing_friends_earliest_friend_contributions.first_contribution_year AS year,\n            count(report_contributing_friends_earliest_friend_contributions.friend_id) AS \"First Timers\"\n           FROM report_contributing_friends_earliest_friend_contributions\n          GROUP BY report_contributing_friends_earliest_friend_contributions.first_contribution_year) first_timers_agg USING (year))\n  WHERE ((affiliation_year.year)::double precision <= date_part('year'::text, ('now'::text)::date))\n  ORDER BY affiliation_year.year");

=head1 ACCESSORS

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=head2 Contributing Friends

  accessor: 'contributing_friends'
  data_type: 'bigint'
  is_nullable: 1

=head2 Renewees

  accessor: 'renewees'
  data_type: 'bigint'
  is_nullable: 1

=head2 Refreshees

  accessor: 'refreshees'
  data_type: 'bigint'
  is_nullable: 1

=head2 First Timers

  accessor: 'first_timers'
  data_type: 'bigint'
  is_nullable: 1

=head2 Total Contributed

  accessor: 'total_contributed'
  data_type: 'numeric'
  is_nullable: 1

=head2 Of that, Membership

  accessor: 'of_that_membership'
  data_type: 'numeric'
  is_nullable: 1

=head2 Additional Donations

  accessor: 'additional_donations'
  data_type: 'numeric'
  is_nullable: 1

=head2 Number of Contributions

  accessor: 'number_of_contributions'
  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "year",
  { data_type => "smallint", is_nullable => 1 },
  "Contributing Friends",
  {
    accessor    => "contributing_friends",
    data_type   => "bigint",
    is_nullable => 1,
  },
  "Renewees",
  { accessor => "renewees", data_type => "bigint", is_nullable => 1 },
  "Refreshees",
  { accessor => "refreshees", data_type => "bigint", is_nullable => 1 },
  "First Timers",
  { accessor => "first_timers", data_type => "bigint", is_nullable => 1 },
  "Total Contributed",
  {
    accessor    => "total_contributed",
    data_type   => "numeric",
    is_nullable => 1,
  },
  "Of that, Membership",
  {
    accessor    => "of_that_membership",
    data_type   => "numeric",
    is_nullable => 1,
  },
  "Additional Donations",
  {
    accessor    => "additional_donations",
    data_type   => "numeric",
    is_nullable => 1,
  },
  "Number of Contributions",
  {
    accessor    => "number_of_contributions",
    data_type   => "numeric",
    is_nullable => 1,
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-06 13:55:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VRXy5dAqq3wlKP/MxK39Dg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
