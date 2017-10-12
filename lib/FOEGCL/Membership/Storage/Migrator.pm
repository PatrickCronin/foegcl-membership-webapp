package FOEGCL::Membership::Storage::Migrator;

use Moose;
extends 'Database::Migrator::Pg';

use Const::Fast qw( const );

# Don't use the role here as we need the config available before creating
# object attributes
use FOEGCL::Membership::Config ();

const my %attr => (
    webapp_database => [ qw( database host username password port ) ],
    migrator => [ qw( migration_table migrations_dir schema_file ) ],
);

my $config = FOEGCL::Membership::Config->instance;

for my $section ( keys %attr ) {
    for my $key ( @{ $attr{$section} } ) {
        has "+$key" => ( default => $config->$section->{$key} );
    }
}

sub drop_database {
    my $self = shift;

    $self->_drop_database;
}

__PACKAGE__->meta->make_immutable;

1;