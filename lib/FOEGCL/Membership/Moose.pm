## no critic (Moose::RequireMakeImmutable)

package FOEGCL::Membership::Moose;

# ABSTRACT: Moose with distribution-specific defaults

use FOEGCL::Membership::perlbase;

use Moose::Exporter;
use Moose                                               ();
use MooseX::SemiAffordanceAccessor                      ();
use MooseX::StrictConstructor                           ();
use MooseX::TraitFor::Meta::Class::BetterAnonClassNames ();
use namespace::autoclean                                ();

use FOEGCL::Membership::perlbase;

my ( undef, undef, $init_meta ) = Moose::Exporter->setup_import_methods(
    install => [qw( import unimport init_meta )],
    also    => [
        qw(
            Moose
            MooseX::SemiAffordanceAccessor
            MooseX::StrictConstructor
            ),
    ],
    class_metaroles => {
        class => ['MooseX::TraitFor::Meta::Class::BetterAnonClassNames'],
    },
);

sub init_meta {
    namespace::autoclean->import::into(2);
    FOEGCL::Membership::perlbase->import::into(2);

    goto \&$init_meta
        if !!$init_meta;
    return;
}

1;
