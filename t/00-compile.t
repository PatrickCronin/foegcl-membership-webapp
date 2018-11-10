#!perl

use FOEGCL::Membership::perlbase;

use Test::Compile;

my $test = Test::Compile->new();
$test->all_files_ok();
$test->done_testing();
