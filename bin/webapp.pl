#!/usr/bin/env perl

use FOEGCL::Membership::perlbase;

use FindBin ();
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Mojolicious::Commands ();

# Start command line interface for application
Mojolicious::Commands->start_app('FOEGCL::Membership');
