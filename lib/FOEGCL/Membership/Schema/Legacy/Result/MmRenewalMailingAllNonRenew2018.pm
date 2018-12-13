#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::MmRenewalMailingAllNonRenew2018;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::MmRenewalMailingAllNonRenew2018

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

=head1 TABLE: C<MM_RenewalMailing_All_NonRenew2018>

=cut

__PACKAGE__->table("MM_RenewalMailing_All_NonRenew2018");

=head1 ACCESSORS

=head2 FriendID

  accessor: 'friend_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 Name

  accessor: 'name'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 Address

  accessor: 'address'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 City

  accessor: 'city'
  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 State

  accessor: 'state'
  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 PostalCode

  accessor: 'postal_code'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "FriendID",
  {
    accessor          => "friend_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "Name",
  { accessor => "name", data_type => "varchar", is_nullable => 1, size => 255 },
  "Address",
  {
    accessor => "address",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
  "City",
  { accessor => "city", data_type => "varchar", is_nullable => 1, size => 50 },
  "State",
  { accessor => "state", data_type => "varchar", is_nullable => 1, size => 2 },
  "PostalCode",
  {
    accessor => "postal_code",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-12-12 18:39:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:VhQCHkQgOefShpNS7Cvx+A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
