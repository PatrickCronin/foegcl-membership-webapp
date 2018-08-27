## no critic (NamingConventions::Capitalization)
package FOEGCL::Membership::perlbase;
## use critic (NamingConventions::Capitalization)
# ABSTRACT: Distribution-specific language defaults

use strict;
use warnings;

use Import::Into;

use autodie 2.25 ();
use experimental ();
use feature          ();
use indirect         ();
use mro              ();
use multidimensional ();

use Devel::StackTrace ();
use Ref::Util qw( is_ref );

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

## no critic (RequireLocalizedPunctuationVars)
$SIG{__DIE__} = sub {
## use critic
    my $message = $_[0];

    # Scalar
    my $trace = Devel::StackTrace->new(
        skip_frames => 1,
        indent      => 1,
    )->as_string;

    if ( !ref $message ) {

        # If no carp-like message was appended, then no trace should be
        # appended.
        die $message if $message !~ m/^.* at .* line \d+\.$/;
        die $message . "\n" . $trace;
    }
};

1;
