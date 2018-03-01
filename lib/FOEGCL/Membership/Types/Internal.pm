package FOEGCL::Membership::Types::Internal;

use FOEGCL::Membership::perlbase;

use MooseX::Types -declare => [
    qw(
        AffiliationYear
        )
];

use MooseX::Types::Moose qw( Int );
use Moose::Util::TypeConstraints qw( subtype as where message );

subtype AffiliationYear,
    as 'Int',
    where { $_ >= 1980 && $_ <= 2030 },
    message { 'Affiliation years must be between 1980 and 2030' };

no Moose::Util::TypeConstraints;

1;
