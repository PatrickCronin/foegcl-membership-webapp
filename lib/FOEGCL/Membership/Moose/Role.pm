package FOEGCL::Membership::Moose::Role;

# ABSTRACT: Moose::Role with distribution-specific defaults

use FOEGCL::Membership::perlbase;

use Moose::Exporter;
use Moose::Role                    ();
use MooseX::SemiAffordanceAccessor ();
use namespace::autoclean           ();

my ( undef, undef, $init_meta ) = Moose::Exporter->setup_import_methods(
    install => [qw( import unimport init_meta )],
    also    => [
        qw(
            Moose::Role
            MooseX::SemiAffordanceAccessor
            ),
    ],
);

sub init_meta {
    namespace::autoclean->import::into(2);
    FOEGCL::Membership::perlbase->import::into(2);

    goto \&$init_meta
        if !!$init_meta;
    return;
}

1;
