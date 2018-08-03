package TestRole::GeneratesFixtures;

use FOEGCL::Membership::Moose::Role;

use Const::Fast 'const';

requires '_schema';

const my $CURRENT_YEAR => [ gmtime(time) ]->[5] + 1900;

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _create_affiliation ( $self, %args ) {
    ## use critic
    state $friend_id = 1000;
    $self->_schema->resultset('Affiliation')->create(
        {
            year      => $CURRENT_YEAR,
            friend_id => $friend_id++,
            %args,
        }
    );
}

1;
