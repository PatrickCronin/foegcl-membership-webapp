package FOEGCL::Membership::Storage::Migrator;

# ABSTRACT: Create and/or update full copies of the database from the schema file

use FOEGCL::Membership::Moose;
extends 'Database::Migrator::Pg';

use Const::Fast qw( const );
use FOEGCL::Membership::Config::WebAppDatabase ();

# Don't use the role here as we need the config available before creating
# object attributes
use FOEGCL::Membership::Config ();

const my %ATTR => (
    migrator        => [qw( migration_table migrations_dir schema_file )],
);

my $config = FOEGCL::Membership::Config->instance;
# Create the attribute defaults for the WebApp database connect_info
my $connect_info =
  FOEGCL::Membership::Config::WebAppDatabase->instance->connect_info;
for my $attr (qw( database host username password port )) {
    has "+$attr" => ( default => $connect_info->$attr );
}

for my $section ( keys %ATTR ) {
    for my $key ( $ATTR{$section}->@* ) {
        has "+$key" => ( default => $config->$section->{$key} );
    }
}

sub drop_database ($self) {
    $self->_drop_database;
}

__PACKAGE__->meta->make_immutable;

1;
