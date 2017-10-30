#!perl

# PODNAME: dump-legacy-schema.pl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::LegacySchemaDumper ();

FOEGCL::Membership::Storage::LegacySchemaDumper->new_with_options->run;
