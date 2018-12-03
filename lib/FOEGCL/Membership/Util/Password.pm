package FOEGCL::Membership::Util::Password;

use FOEGCL::Membership::Moose;

use Const::Fast 'const';
use Crypt::SaltedHash ();
use Try::Tiny qw( catch try );

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

const my $SALT_LENGTH          => 32;
const my $PASSWORD_CHECK_DELAY => 2;

# All password checks take a fixed number of seconds to discourage brute-force
# attacks and complicate time-based cryptanalysis attacks.
sub check_password ( $self, $provided_username, $provided_password ) {
    my $is_a_match = 0;
    my $finished   = 0;
    my $delayed    = "delayed\n";
    try {
        local $SIG{ALRM} = sub { die $delayed; };
        alarm $PASSWORD_CHECK_DELAY;

        my $user
            = $self->_schema->resultset('AppUser')->find($provided_username);
        $is_a_match = 1
            if $user
            && _new_crypt()->validate(
            $user->password_hash,
            $provided_password,
            $SALT_LENGTH
            );
        undef $user;
        $finished = 1;
        sleep $PASSWORD_CHECK_DELAY + 1;
    }
    catch {
        die $_ if $_ ne $delayed;
    };

    # TODO: Log if we didn't finish the password check!

    return $is_a_match;
}

sub hash_password ( $self, $password ) {
    _new_crypt()->add($password)->generate;
}

sub _new_crypt () {
    Crypt::SaltedHash->new(
        algorithm => 'SHA-512',
        salt_len  => $SALT_LENGTH,
    );
}

__PACKAGE__->meta->make_immutable;

1;
