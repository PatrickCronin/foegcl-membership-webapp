## no critic (NamingConventions::Capitalization)
package FOEGCL::Membership::perlbase;
## use critic (NamingConventions::Capitalization)

use strict;
use warnings;

use Import::Into;

use autodie 2.25 ();
use experimental ();
use feature          ();
use indirect         ();
use mro              ();
use multidimensional ();

# This adds the UTF-8 layer on STDIN, STDOUT, STDERR for _everyone_
use open qw( :encoding(UTF-8) :std );
use utf8 ();

sub import {
    my $caller_level = 1;

    strict->import::into($caller_level);
    warnings->import::into($caller_level);

    my @experiments = qw(
      lexical_subs
      postderef
      signatures
    );
    experimental->import::into( $caller_level, @experiments );

    my ($version) = $^V =~ /^v(5\.\d+)/;
    feature->import::into( $caller_level, ':' . $version );
    ## no critic (Subroutines::ProhibitCallsToUnexportedSubs)
    mro::set_mro( scalar caller(), 'c3' );
    ## use critic
    utf8->import::into($caller_level);

    indirect->unimport::out_of( $caller_level, ':fatal' );
    multidimensional->unimport::out_of($caller_level);
    'open'->import::into( $caller_level, ':encoding(UTF-8)' );
    autodie->import::into( $caller_level, ':all' );
}

1;
