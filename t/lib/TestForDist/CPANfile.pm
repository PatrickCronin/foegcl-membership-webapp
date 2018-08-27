package TestForDist::CPANfile;

use FOEGCL::Membership::Test::Class::Moose;

use Test::CPANfile 'cpanfile_has_all_used_modules';

sub test_cpanfile_is_complete ( $self, @ ) {
    cpanfile_has_all_used_modules(
        perl_version => '5.26',
    );
}

__PACKAGE__->meta->make_immutable;

1;