package FOEGCL::Membership::Test::Class::Moose;

use Moose::Exporter;
use MooseX::SemiAffordanceAccessor ();
use MooseX::StrictConstructor      ();

use FOEGCL::Membership::perlbase;

use Import::Into;
use Test::Class::Moose                    ();
use Test::Class::Moose::AttributeRegistry ();
use Test::More;
use namespace::autoclean ();

sub import {
    my $for_class = caller();

    my $caller_level = 1;
    Test::Class::Moose->import::into($caller_level);

    MooseX::SemiAffordanceAccessor->import( { into => $for_class } );
    MooseX::StrictConstructor->import( { into => $for_class } );

    mmperl->import::into($caller_level);
    namespace::autoclean->import::into($caller_level);
}

1;
