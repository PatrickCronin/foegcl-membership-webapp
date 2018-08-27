package FOEGCL::Membership::Moose::Role;

# ABSTRACT: Moose::Role with distribution-specific defaults

use FOEGCL::Membership::perlbase;

use Import::Into;
use Moose::Exporter;
use Moose::Role                    ();
use MooseX::SemiAffordanceAccessor ();
use namespace::autoclean           ();

my ($import) = Moose::Exporter->setup_import_methods(
    install => [ 'unimport', 'init_meta' ],
    also    => ['Moose::Role'],
);

sub import {
    my $for_role = caller();

    $import->( undef, { into => $for_role } );
    MooseX::SemiAffordanceAccessor->import( { into => $for_role } );

    my $caller_level = 1;
    FOEGCL::Membership::perlbase->import::into($caller_level);
    namespace::autoclean->import::into($caller_level);
}

1;
