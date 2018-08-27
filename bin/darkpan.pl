#!perl
# ABSTRACT: Update the DarkPAN from the cpanfile and the CPAN
# PODNAME: update-darkpan.pl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::DarkPAN;

FOEGCL::Membership::DarkPAN->new_with_options->run;