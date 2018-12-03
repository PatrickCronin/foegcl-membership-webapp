## no critic (Moose::RequireMakeImmutable)

package FOEGCL::Membership::Moose::Mojo;

# ABSTRACT: FOEGCL::Membership::Moose for classes based on Mojo::Base

use FOEGCL::Membership::perlbase;

use Moose::Exporter;
use Moose                                               ();
use MooseX::NonMoose                                    ();
use MooseX::SemiAffordanceAccessor                      ();
use MooseX::TraitFor::Meta::Class::BetterAnonClassNames ();
use experimental 'signatures';
use namespace::autoclean ();

my ($import) = Moose::Exporter->setup_import_methods(
    install => [qw( unimport init_meta )],
    also    => [qw(Moose MooseX::NonMoose MooseX::SemiAffordanceAccessor)],
    class_metaroles => {
        class => ['MooseX::TraitFor::Meta::Class::BetterAnonClassNames'],
    },
);

sub import ( $class, @ ) {
    my $for_class = caller();

    $import->( undef, { into => $for_class } );
    $class->import_extras(2);

    $for_class->meta->add_method(
        FOREIGNBUILDARGS => sub ( $, @args ) {
            state $moose_attr = {
                map { ( $_ => 1 ) }
                grep { defined $_ }
                map  { $_->init_arg } $for_class->meta->get_all_attributes
            };

            my $attrs = @args > 1 ? {@args} : $args[0];

            return { $attrs->%{ grep { !$moose_attr->{$_} } keys %$attrs } };
        }
    );

    return;
}

sub import_extras ( $, $level ) {
    FOEGCL::Membership::perlbase->import::into($level);
    namespace::autoclean->import::into($level);

    return;
}

1;
