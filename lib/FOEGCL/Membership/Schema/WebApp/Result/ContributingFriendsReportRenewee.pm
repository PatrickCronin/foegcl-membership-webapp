#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportRenewee;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportRenewee

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

=head1 TABLE: C<contributing_friends_report_renewees>

=cut

__PACKAGE__->table("contributing_friends_report_renewees");
__PACKAGE__->result_source_instance->view_definition(" SELECT base_year.year,\n    base_year.friend_id AS renewee_friend_id\n   FROM (contributing_friends_report_annual_friend_contribution_agg base_year\n     JOIN contributing_friends_report_annual_friend_contribution_agg last_year ON (((base_year.friend_id = last_year.friend_id) AND ((base_year.year - 1) = last_year.year))))");

=head1 ACCESSORS

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=head2 renewee_friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

=cut

__PACKAGE__->add_columns(
  "year",
  { data_type => "smallint", is_nullable => 1 },
  "renewee_friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/3AKk5V/z9x7vmQcpfRvng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
