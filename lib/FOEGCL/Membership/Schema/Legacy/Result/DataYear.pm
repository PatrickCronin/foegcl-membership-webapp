#<<<
use utf8;
package FOEGCL::Membership::Schema::Legacy::Result::DataYear;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::Legacy::Result::DataYear

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

=head1 TABLE: C<DataYears>

=cut

__PACKAGE__->table("DataYears");

=head1 ACCESSORS

=head2 DataYear

  accessor: 'data_year'
  data_type: 'smallint'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "DataYear",
  { accessor => "data_year", data_type => "smallint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</DataYear>

=back

=cut

__PACKAGE__->set_primary_key("DataYear");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-23 21:26:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+K0LXipEhnP99mNEVp4ynA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
