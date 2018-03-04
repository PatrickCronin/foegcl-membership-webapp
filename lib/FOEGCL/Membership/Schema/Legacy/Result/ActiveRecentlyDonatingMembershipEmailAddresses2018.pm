#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::ActiveRecentlyDonatingMembershipEmailAddresses2018;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::ActiveRecentlyDonatingMembershipEmailAddresses2018

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

=head1 TABLE: C<ActiveRecentlyDonatingMembershipEmailAddresses2018>

=cut

__PACKAGE__->table("ActiveRecentlyDonatingMembershipEmailAddresses2018");

=head1 ACCESSORS

=head2 Email_Address

  accessor: 'email_address'
  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "Email_Address",
  {
    accessor => "email_address",
    data_type => "varchar",
    is_nullable => 1,
    size => 255,
  },
);
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-03-02 23:37:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7Q3oAOuTNMRrQhtSf0JBsw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
