package TestFor::FOEGCL::Membership::Util::Password;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::Util::Password ();
use List::Util 'sum';
use Time::HiRes ();

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub test_response_times ( $self, @ ) {
    my $crypt = FOEGCL::Membership::Util::Password->new;

    my $fixture_password = 'abcdefghijklmnopqrstuvwxyz';
    my $fixture_user     = $self->_schema->resultset('AppUser')->create(
        {
            username      => 'existing_user',
            password_hash => $crypt->hash_password($fixture_password),
            first_name    => 'Fixture',
            last_name     => 'User',
        },
    );

    my @scenarios = (
        {
            username => 'existing_user',
            password => 'wrong_password',
            expected => 0,
        },
        {
            username => 'existing_user',
            password => '2short',
            expected => 0,
        },
        {
            username => 'existing_user',
            password =>
                substr( $fixture_password, 0, length($fixture_password) - 1 ),
            expected => 0,
        },
        {
            username => 'existing_user',
            password => $fixture_password,
            expected => 1,
        },
        {
            username => 'not_a_user',
            password => 'a',
            expected => 0,
        },
        {
            username => 'not_a_user',
            password => $fixture_password,
            expected => 0,
        },
    );

    my @durations;
    foreach my $s (@scenarios) {
        my $start  = Time::HiRes::time();
        my $result = $crypt->check_password( $s->{username}, $s->{password} );
        my $stop   = Time::HiRes::time();
        push @durations, $stop - $start;

        is( $result, $s->{expected}, 'got expected result' );
    }

    my $allowable_tolerance = 0.05;
    my $mean                = sum(@durations) / @durations;
    my $allowable_min       = $mean * ( 1 - $allowable_tolerance );
    my $allowable_max       = $mean * ( 1 + $allowable_tolerance );
    my @out_of_tolerance
        = grep { $_ < $allowable_min || $_ > $allowable_max } @durations;
    is_deeply(
        \@out_of_tolerance,
        [],
        "password validation is resistant to time-based cryptanalysis attacks (x̄: $mean)"
    );
}

__PACKAGE__->meta->make_immutable;

1;
