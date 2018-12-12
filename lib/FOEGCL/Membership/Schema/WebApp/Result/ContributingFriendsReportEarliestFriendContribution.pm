#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportEarliestFriendContribution;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::ContributingFriendsReportEarliestFriendContribution

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

=head1 TABLE: C<contributing_friends_report_earliest_friend_contributions>

=cut

__PACKAGE__->table("contributing_friends_report_earliest_friend_contributions");
__PACKAGE__->result_source_instance->view_definition(" SELECT affiliation.friend_id,\n    min(affiliation.year) AS first_contribution_year\n   FROM (affiliation\n     JOIN contribution USING (affiliation_id))\n  GROUP BY affiliation.friend_id");

=head1 ACCESSORS

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

=head2 first_contribution_year

  data_type: 'smallint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
  "first_contribution_year",
  { data_type => "smallint", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-12-11 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7+/q33PkS4ka2Uc+CG+AQw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
