#!perl
# ABSTRACT: Run the ETL process from the Legacy DB to the WebApp DB
# PODNAME: etl.pl

use FOEGCL::Membership::perlbase;

use English qw(-no_match_vars);

use FOEGCL::Membership::ETL ();

die 'Cannot ETL if not running on Windows'
    if $OSNAME !~ m/MSWin32/;

FOEGCL::Membership::ETL->new_with_options->run;
