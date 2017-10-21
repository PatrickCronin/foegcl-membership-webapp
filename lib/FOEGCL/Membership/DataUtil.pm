package FOEGCL::Membership::DataUtil;

# ABSTRACT: Reusable utilty methods

use FOEGCL::Membership::perlbase;

use Sub::Exporter -setup => { exports => [qw( is_pobox trim )] };

sub trim (@values) {
    my @trimmed = map { defined $_ ? s/\A \s+ | \s+ \z//rgx : undef } @values;
    return wantarray ? @trimmed : $trimmed[0];
}

sub is_pobox ($line) {
    state $maybe_whitespace = qr/\s*/;

    return 0 if !defined $line;

    return $line =~ m/
        \A
        P (?: \.? | ost ) $maybe_whitespace
        O (?: \.? | ffice ) $maybe_whitespace
        Box
    /ix;
}

1;
