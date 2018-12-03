#!perl
# ABSTRACT: Add a user to the WebApp database
# PODNAME: add-appuser.pl

use FOEGCL::Membership::perlbase;

package Add::AppUser {
    use FOEGCL::Membership::Moose;

    use FOEGCL::Membership::Types 'NonEmptySimpleStr';
    use FOEGCL::Membership::Storage::WebAppDatabaseConnection ();
    use FOEGCL::Membership::Util::Password                    ();
    use Try::Tiny qw(catch try);

    has [qw(username password first_name last_name)] => (
        is       => 'ro',
        isa      => NonEmptySimpleStr,
        required => 1,
    );

    with 'MooseX::Getopt::Dashes';

    sub run ($self) {
        my $cxn = FOEGCL::Membership::Storage::WebAppDatabaseConnection->new;
        try {
            $cxn->schema->resultset('AppUser')->create(
                {
                    username      => $self->username,
                    password_hash => FOEGCL::Membership::Util::Password->new
                        ->hash_password(
                        $self->password
                        ),
                    first_name => $self->first_name,
                    last_name  => $self->last_name,
                }
            );
            say 'Created user ' . $self->username;
        }
        catch {
            say "Failed to create user: $_";
        };
    }

    1;
}

Add::AppUser->new_with_options->run;

