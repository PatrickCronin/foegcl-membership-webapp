package FOEGCL::Membership::DataUtil;

# ABSTRACT: Reusable utilty methods

use FOEGCL::Membership::perlbase;

use Sub::Exporter -setup => { exports => [qw( is_pobox trim )] };

sub trim (@values) {
    return map { defined $_ ? s/\A \s+ | \s+ \z//rgx : undef } @values;
}

sub is_pobox ($line) {
    my $maybe_whitespace = qr/\s*/;
    return $line =~ m/
        \A
        P (?: \.? | ost ) $maybe_whitespace
        O (?: \.? | ffice ) $maybe_whitespace
        Box
    /ix;
}

1;
