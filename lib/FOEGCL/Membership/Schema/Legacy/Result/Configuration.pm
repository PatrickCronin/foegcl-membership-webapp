#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::Configuration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::Configuration

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

=head1 TABLE: C<Configuration>

=cut

__PACKAGE__->table("Configuration");

=head1 ACCESSORS

=head2 Setting

  accessor: 'setting'
  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 CurrentValue

  accessor: 'current_value'
  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "Setting",
  { accessor => "setting", data_type => "varchar", is_nullable => 0, size => 64 },
  "CurrentValue",
  {
    accessor => "current_value",
    data_type => "varchar",
    is_nullable => 0,
    size => 255,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</Setting>

=back

=cut

__PACKAGE__->set_primary_key("Setting");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-24 23:46:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XMzIivEEekLL36nyXuzMCA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
