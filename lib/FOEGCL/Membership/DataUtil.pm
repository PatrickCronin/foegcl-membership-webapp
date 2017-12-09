package FOEGCL::Membership::DataUtil;

# ABSTRACT: Reusable utilty methods

use FOEGCL::Membership::perlbase;

use Sub::Exporter -setup => { exports => [qw( trim )] };

sub trim (@values) {
    my @trimmed = map { defined $_ ? s/\A \s+ | \s+ \z//rgx : undef } @values;
    return wantarray ? @trimmed : $trimmed[0];
}

1;
