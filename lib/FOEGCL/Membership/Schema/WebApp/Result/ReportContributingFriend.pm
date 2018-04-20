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
__PACKAGE__->result_source_instance->view_definition(" WITH annual_friend_contribution_agg AS (\n         SELECT affiliation.year,\n            affiliation.friend_id,\n            sum(contribution.amount) AS \"Total Contributed\",\n            count(contribution.amount) AS \"Number of Contributions\"\n           FROM (contribution\n             JOIN affiliation USING (affiliation_id))\n          GROUP BY affiliation.year, affiliation.friend_id\n        ), earliest_friend_contributions AS (\n         SELECT affiliation.friend_id,\n            min(affiliation.year) AS first_contribution_year\n           FROM (affiliation\n             JOIN contribution USING (affiliation_id))\n          GROUP BY affiliation.friend_id\n        )\n SELECT affiliation_year.year,\n    annual_all_friend_contribution_agg.\"Contributing Friends\",\n    annual_renewals_agg.\"Renewees\",\n    annual_returnees_agg.\"Refreshees\",\n    first_timers_agg.\"First Timers\",\n    annual_all_friend_contribution_agg.\"Total Contributed\",\n    annual_all_friend_contribution_agg.\"Number of Contributions\"\n   FROM ((((affiliation_year\n     LEFT JOIN ( SELECT annual_friend_contribution_agg.year,\n            count(*) AS \"Contributing Friends\",\n            sum(annual_friend_contribution_agg.\"Total Contributed\") AS \"Total Contributed\",\n            sum(annual_friend_contribution_agg.\"Number of Contributions\") AS \"Number of Contributions\"\n           FROM annual_friend_contribution_agg\n          GROUP BY annual_friend_contribution_agg.year) annual_all_friend_contribution_agg USING (year))\n     LEFT JOIN ( SELECT base_year.year,\n            count(base_year.friend_id) AS \"Renewees\"\n           FROM (annual_friend_contribution_agg base_year\n             JOIN annual_friend_contribution_agg last_year ON (((base_year.friend_id = last_year.friend_id) AND ((base_year.year - 1) = last_year.year))))\n          GROUP BY base_year.year) annual_renewals_agg USING (year))\n     LEFT JOIN ( SELECT base_year.year,\n            count(base_year.friend_id) AS \"Refreshees\"\n           FROM (annual_friend_contribution_agg base_year\n             JOIN earliest_friend_contributions ON (((base_year.friend_id = earliest_friend_contributions.friend_id) AND (base_year.year > earliest_friend_contributions.first_contribution_year))))\n          WHERE (NOT (EXISTS ( SELECT 1\n                   FROM annual_friend_contribution_agg last_year\n                  WHERE ((base_year.friend_id = last_year.friend_id) AND ((base_year.year - 1) = last_year.year)))))\n          GROUP BY base_year.year) annual_returnees_agg USING (year))\n     LEFT JOIN ( SELECT earliest_friend_contributions.first_contribution_year AS year,\n            count(earliest_friend_contributions.friend_id) AS \"First Timers\"\n           FROM earliest_friend_contributions\n          GROUP BY earliest_friend_contributions.first_contribution_year) first_timers_agg USING (year))\n  WHERE ((affiliation_year.year)::double precision <= date_part('year'::text, ('now'::text)::date))\n  ORDER BY affiliation_year.year");

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
  "Number of Contributions",
  {
    accessor    => "number_of_contributions",
    data_type   => "numeric",
    is_nullable => 1,
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-04-19 22:37:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sg69yrcgNjmeTArp5QRTtQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
