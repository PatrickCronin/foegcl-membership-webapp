package FOEGCL::Membership::DataUtil;
# ABSTRACT: Reusable utilty methods

use Sub::Exporter -setup => {
    exports => [ qw( is_pobox trim ) ]
};

sub trim {
    my @values = @_;
    
    my @trimmed_values = map { 
        defined $_ ? s/\A \s+ | \s+ \z//rgx : undef
    } @values;
    
    return @trimmed_values if wantarray;
    return $trimmed_values[0];
}

sub is_pobox {
    my $line = shift;
    
    my $maybe_whitespace = qr/\s*/;
    return $line =~ m/
        \A
        P (?: \.? | ost ) $maybe_whitespace
        O (?: \.? | ffice ) $maybe_whitespace
        Box
    /ix;
}

1;