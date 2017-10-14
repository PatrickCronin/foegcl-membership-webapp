use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::ContactType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::ContactType

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

=head1 TABLE: C<ContactType>

=cut

__PACKAGE__->table("ContactType");

=head1 ACCESSORS

=head2 ID

  accessor: 'id'
  data_type: 'integer'
  is_nullable: 0

=head2 ContactType

  accessor: 'contact_type'
  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "ID",
  { accessor => "id", data_type => "integer", is_nullable => 0 },
  "ContactType",
  {
    accessor => "contact_type",
    data_type => "varchar",
    is_nullable => 0,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ID>

=back

=cut

__PACKAGE__->set_primary_key("ID");

=head1 RELATIONS

=head2 contact_infos

Type: has_many

Related object: L<FOEGCL::Membership::Schema::Legacy::Result::ContactInfo>

=cut

__PACKAGE__->has_many(
  "contact_infos",
  "FOEGCL::Membership::Schema::Legacy::Result::ContactInfo",
  { "foreign.ContactTypeID" => "self.ID" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-10-13 23:30:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/uX2vfwlWVPmGXDpfcwaCQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
