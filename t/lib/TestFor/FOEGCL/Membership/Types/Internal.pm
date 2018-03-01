package TestFor::FOEGCL::Membership::Types::Internal;

use FOEGCL::Membership::Test::Class::Moose;

use Data::Printer {
    multiline => 0,
    class     => {
        expand  => 0,
        parents => 0,
    },
};
use FOEGCL::Membership::Types qw(
    AffiliationYear
);

sub test_affiliation_year ( $self, @ ) {
    my $good = [ 1980, 1999, 2000, 2001, 2018, 2030 ];
    my $bad = [ undef, 1979, 2031, q{} ];
    _check_type_values( AffiliationYear, $good, $bad );
}

sub _check_type_values ( $type, $expected_good, $expected_bad ) {
    foreach my $val ( $expected_good->@* ) {
        ok(
            $type->check($val),
            np($val) . ' is a ' . $type->name
        );
    }

    foreach my $val ( $expected_bad->@* ) {
        ok(
            !$type->check($val),
            np($val) . ' is not a ' . $type->name
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;
