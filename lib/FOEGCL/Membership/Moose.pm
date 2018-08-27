## no critic (Moose::RequireMakeImmutable)

package FOEGCL::Membership::Moose;

# ABSTRACT: Moose with distribution-specific defaults

use FOEGCL::Membership::perlbase;

use Import::Into;
use Moose ();
use Moose::Exporter;
use MooseX::SemiAffordanceAccessor ();
use MooseX::StrictConstructor      ();
use namespace::autoclean           ();

use FOEGCL::Membership::perlbase;

my ($import) = Moose::Exporter->setup_import_methods(
    install => [ 'unimport', 'init_meta' ],
    also    => ['Moose'],
);

sub import ( $class, @ ) {
    my $for_class = caller();

    $import->( undef, { into => $for_class } );
    $class->import_extras( $for_class, 2 );

    return;
}

sub import_extras ( $class, $for_class, $level ) {

    MooseX::SemiAffordanceAccessor->import( { into => $for_class } );
    MooseX::StrictConstructor->import( { into => $for_class } );

    # note that we need to use a level here rather than a classname
    # so that importing autodie works
    FOEGCL::Membership::perlbase->import::into($level);
    namespace::autoclean->import::into($level);

    return;
}

1;
