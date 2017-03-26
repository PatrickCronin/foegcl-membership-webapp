use utf8;
package FOEGCL::Membership::Legacy::Schema::Result::DataYear;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Legacy::Schema::Result::DataYear

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


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2017-03-25 22:55:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:30AD9a8MX4qyUWFOggV5Tw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
