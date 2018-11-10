#!perl

use FOEGCL::Membership::perlbase;

use Test::Compile;

my $test = Test::Compile->new();

$test->all_files_ok(qw(bin lib storage));

# TODO: Find way to include the t/ directory!

$test->done_testing();
