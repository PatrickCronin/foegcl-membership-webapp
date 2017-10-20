#!perl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::WebAppSchemaDumper ();

FOEGCL::Membership::Storage::WebAppSchemaDumper->new_with_options->run;
