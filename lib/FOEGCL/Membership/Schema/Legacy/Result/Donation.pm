use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::Donation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::Donation - Year has a validation rule that needs to be updated yearly.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<Donations>

=cut

__PACKAGE__->table("Donations");

=head1 ACCESSORS

=head2 DonationRecordID

  accessor: 'donation_record_id'
  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 FriendID

  accessor: 'friend_id'
  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 Donation

  accessor: 'donation'
  data_type: 'money'
  is_nullable: 1
  original: {data_type => "currency"}

=head2 Year

  accessor: 'year'
  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "DonationRecordID",
  {
    accessor          => "donation_record_id",
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "FriendID",
  {
    accessor       => "friend_id",
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "Donation",
  {
    accessor    => "donation",
    data_type   => "money",
    is_nullable => 1,
    original    => { data_type => "currency" },
  },
  "Year",
  { accessor => "year", data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</DonationRecordID>

=back

=cut

__PACKAGE__->set_primary_key("DonationRecordID");

=head1 RELATIONS

=head2 friend

Type: belongs_to

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::Friend>

=cut

__PACKAGE__->belongs_to(
  "friend",
  "FOEGCL::Membership::Schema::Legacy::Result::Friend",
  { FriendID => "FriendID" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-07 23:34:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EEOg8LGEt/73RxRJLadMaw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
