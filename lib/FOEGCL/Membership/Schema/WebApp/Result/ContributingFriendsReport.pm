#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReport;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReport

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

=head1 TABLE: C<contributing_friends_report>

=cut

__PACKAGE__->table("contributing_friends_report");
__PACKAGE__->result_source_instance->view_definition(" SELECT affiliation_year.year AS \"Year\",\n    annual_all_friend_contribution_agg.number_of_contributing_friends AS \"Contributing Friends\",\n    annual_renewals_agg.number_of_renewees AS \"Renewees\",\n    annual_refreshees_agg.number_of_refreshees AS \"Refreshees\",\n    first_timers_agg.number_of_first_timers AS \"First Timers\",\n    annual_all_friend_contribution_agg.contribution_total AS \"Total Contributed\",\n    annual_all_friend_contribution_agg.membership_portion AS \"Membership Portion\",\n    annual_all_friend_contribution_agg.donation_portion AS \"Donation Portion\",\n    annual_all_friend_contribution_agg.number_of_contributions AS \"Number of Contributions\"\n   FROM ((((affiliation_year\n     LEFT JOIN ( SELECT contributing_friends_report_annual_friend_contribution_agg.year,\n            count(*) AS number_of_contributing_friends,\n            COALESCE(sum(contributing_friends_report_annual_friend_contribution_agg.total_contributed), (0)::numeric) AS contribution_total,\n            COALESCE(sum(contributing_friends_report_annual_friend_contribution_agg.membership_portion_of_contributions), (0)::numeric) AS membership_portion,\n            COALESCE(sum(contributing_friends_report_annual_friend_contribution_agg.donation_portion_of_contributions), (0)::numeric) AS donation_portion,\n            COALESCE(sum(contributing_friends_report_annual_friend_contribution_agg.number_of_contributions), (0)::numeric) AS number_of_contributions\n           FROM contributing_friends_report_annual_friend_contribution_agg\n          GROUP BY contributing_friends_report_annual_friend_contribution_agg.year) annual_all_friend_contribution_agg USING (year))\n     LEFT JOIN ( SELECT contributing_friends_report_renewees.year,\n            count(contributing_friends_report_renewees.renewee_friend_id) AS number_of_renewees\n           FROM contributing_friends_report_renewees\n          GROUP BY contributing_friends_report_renewees.year) annual_renewals_agg USING (year))\n     LEFT JOIN ( SELECT contributing_friends_report_refreshees.year,\n            count(contributing_friends_report_refreshees.refreshee_friend_id) AS number_of_refreshees\n           FROM contributing_friends_report_refreshees\n          GROUP BY contributing_friends_report_refreshees.year) annual_refreshees_agg USING (year))\n     LEFT JOIN ( SELECT contributing_friends_report_earliest_friend_contributions.first_contribution_year AS year,\n            count(contributing_friends_report_earliest_friend_contributions.friend_id) AS number_of_first_timers\n           FROM contributing_friends_report_earliest_friend_contributions\n          GROUP BY contributing_friends_report_earliest_friend_contributions.first_contribution_year) first_timers_agg USING (year))\n  WHERE ((affiliation_year.year)::double precision <= date_part('year'::text, ('now'::text)::date))\n  ORDER BY affiliation_year.year");

=head1 ACCESSORS

=head2 Year

  accessor: 'year'
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

=head2 Membership Portion

  accessor: 'membership_portion'
  data_type: 'numeric'
  is_nullable: 1

=head2 Donation Portion

  accessor: 'donation_portion'
  data_type: 'numeric'
  is_nullable: 1

=head2 Number of Contributions

  accessor: 'number_of_contributions'
  data_type: 'numeric'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "Year",
  { accessor => "year", data_type => "smallint", is_nullable => 1 },
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
  "Membership Portion",
  {
    accessor    => "membership_portion",
    data_type   => "numeric",
    is_nullable => 1,
  },
  "Donation Portion",
  {
    accessor    => "donation_portion",
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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IB0+1+8oz6A81B8g8+NbVg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
