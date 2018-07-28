#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::Membership;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::Membership

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
__PACKAGE__->result_source_instance->view_definition(" SELECT affiliation.affiliation_id,\n    affiliation.year,\n    affiliation.membership_type,\n    affiliation.friend_id,\n    affiliation.created_at,\n    affiliation.updated_at\n   FROM affiliation\n  WHERE (affiliation.membership_type IS NOT NULL)");

=head1 ACCESSORS

=head2 affiliation_id

  data_type: 'integer'
  is_nullable: 1

=head2 year

  data_type: 'smallint'
  is_nullable: 1

=head2 membership_type

  data_type: 'enum'
  extra: {custom_type_name => "membership_type",list => ["individual_membership","household_membership","senior_student_individual_membership","senior_household_membership"]}
  is_nullable: 1

=head2 friend_id

  data_type: 'numeric'
  is_nullable: 1
  size: [11,0]

=head2 created_at

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 updated_at

  data_type: 'timestamp with time zone'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "affiliation_id",
  { data_type => "integer", is_nullable => 1 },
  "year",
  { data_type => "smallint", is_nullable => 1 },
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
    is_nullable => 1,
  },
  "friend_id",
  { data_type => "numeric", is_nullable => 1, size => [11, 0] },
  "created_at",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "updated_at",
  { data_type => "timestamp with time zone", is_nullable => 1 },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2018-08-06 13:55:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BApi6dJT1hjVaGgnRFYtPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
