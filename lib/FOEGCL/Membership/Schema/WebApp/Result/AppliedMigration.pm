#<<<
use utf8;
package FOEGCL::Membership::Schema::WebApp::Result::AppliedMigration;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

FOEGCL::Membership::Schema::WebApp::Result::AppliedMigration

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

=head1 TABLE: C<applied_migration>

=cut

__PACKAGE__->table("applied_migration");

=head1 ACCESSORS

=head2 migration

  data_type: 'text'
  is_nullable: 0

=head2 applied

  data_type: 'timestamp with time zone'
  default_value: current_timestamp
  is_nullable: 1
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "migration",
  { data_type => "text", is_nullable => 0 },
  "applied",
  {
    data_type     => "timestamp with time zone",
    default_value => \"current_timestamp",
    is_nullable   => 1,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</migration>

=back

=cut

__PACKAGE__->set_primary_key("migration");
#>>>

# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-02-24 23:46:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rhHk2mJ1gLI8gg0icQJ9Zg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
