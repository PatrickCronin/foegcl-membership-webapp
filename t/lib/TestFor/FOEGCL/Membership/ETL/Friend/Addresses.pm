package TestFor::FOEGCL::Membership::ETL::Friend::Addresses;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::ETL::Friend::Addresses;
use Test::Differences qw( eq_or_diff );
use Test::Fatal qw( exception );

has _etl_friend_addresses => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::ETL::Friend::Addresses',
    default => sub { FOEGCL::Membership::ETL::Friend::Addresses->new },
);

sub test_good_addresses_from ( $self, @ ) {
    my @tests = (
        {
            in  => [ 1, '1 Main St.' ],
            out => {
                'mailing_addresses'  => [],
                'physical_addresses' => [
                    {
                        street_line_1 => '1 Main St.',
                        csz_id        => 1,
                    },
                ],
            },
        },
        {
            in  => [ 2, 'PO Box 2' ],
            out => {
                'mailing_addresses' => [
                    {
                        street_line_1 => 'PO Box 2',
                        csz_id        => 2,
                    },
                ],
                'physical_addresses' => [],
            },
        },
        {
            in  => [ 3, '3 Main Street', 'P. O. Box 3' ],
            out => {
                'mailing_addresses' => [
                    {
                        street_line_1 => 'P. O. Box 3',
                        csz_id        => 3,
                    },
                ],
                'physical_addresses' => [
                    {
                        street_line_1 => '3 Main Street',
                        csz_id        => 3
                    }
                ],
            },
        },
        {
            in  => [ 4, 'PO Box 4', 'PO Box 4a' ],
            out => {
                'mailing_addresses' => [
                    {
                        street_line_1 => 'PO Box 4',
                        csz_id        => 4,
                    },
                    {
                        street_line_1 => 'PO Box 4a',
                        csz_id        => 4,
                    },
                ],
                'physical_addresses' => [],
            },
        },
        {
            in  => [ 5, '5 Main St.', 'Apt 2' ],
            out => {
                'mailing_addresses'  => [],
                'physical_addresses' => [
                    {
                        street_line_1 => '5 Main St.',
                        street_line_2 => 'Apt 2',
                        csz_id        => 5,
                    }
                ],
            },
        },
    );

    for my $test (@tests) {
        eq_or_diff(
            {
                ## no critic (Subroutines::ProtectPrivateSubs)
                FOEGCL::Membership::ETL::Friend::Addresses::_addresses_from(
                    $test->{in}->@*
                )
            },
            $test->{out},
            'generates expected address'
        );
    }

}

sub test_bad_addresses_from ( $self, @ ) {
    like(
        exception {
            ## no critic (Subroutines::ProtectPrivateSubs)
            FOEGCL::Membership::ETL::Friend::Addresses::_addresses_from(
                1,
                '1 Main St.', 'Apt 1', 'Upstairs'
            );
        },
        qr/cannot handle addresses with 3 street lines/,
        'chokes on addresses with too many street lines'
    );
}

sub test_is_pobox ( $self, @ ) {
    my @poboxes = (
        'P. O. Box 1',
        'P.O.Box 2',
        'POBox 3',
        'PO Box 4',
        'PO. Box 5',
        'P  O  Box 6',
        'Post Office Box 7',
        'P.Office Box 8',
        'Post O. Box 9',
    );

    foreach my $pobox (@poboxes) {
        ok(
            ## no critic (Subroutines::ProtectPrivateSubs)
            FOEGCL::Membership::ETL::Friend::Addresses::_is_pobox($pobox),
            "$pobox is a PO Box"
        );
    }

    my @not_poboxes = (
        '1 Main Street',
        'PleoBox 1'
    );

    foreach my $not_pobox (@not_poboxes) {
        ok(
            ## no critic (Subroutines::ProtectPrivateSubs)
            !FOEGCL::Membership::ETL::Friend::Addresses::_is_pobox(
                $not_pobox),
            "$not_pobox is not a PO Box"
        );
    }

}

sub test_single_street_line_to_multiple_lines ( $self, @ ) {
    eq_or_diff(
        [
            ## no critic (Subroutines::ProtectPrivateSubs)
            FOEGCL::Membership::ETL::Friend::Addresses::_single_street_line_to_multiple_lines(
                ' 1 Main Street '
            )
        ],
        ['1 Main Street'],
        'single line addresses are trimmed'
    );

    foreach my $line_ending ( "\r", "\n", "\r\n" ) {
        eq_or_diff(
            [
                ## no critic (Subroutines::ProtectPrivateSubs)
                FOEGCL::Membership::ETL::Friend::Addresses::_single_street_line_to_multiple_lines(
                    " 1 Main Street   $line_ending  Apt B  "
                )
            ],
            [ '1 Main Street', 'Apt B', ],
            'multi-line addresses formed with line endings `'
                . (
                join q{, }, map { 'Chr ' . ord $_ } split //, $line_ending
                )
                . '` separated and trimmed'
        );
    }
}

__PACKAGE__->meta->make_immutable;

1;
