#!perl

use FOEGCL::Membership::perlbase;

use lib 't/lib';    # Find the TestHelper dir
use TestHelper::TestRunner ();

TestHelper::TestRunner->new_with_options->run;
