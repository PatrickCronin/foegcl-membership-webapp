package TestFor::FOEGCL::Membership::DataUtil;

use FOEGCL::Membership::Test::Class::Moose;

use FOEGCL::Membership::DataUtil qw( trim );

sub test_trim ( $self, @ ) {
    is( trim( '   hello'), 'hello', 'trim trims at string beginning' );
    is( trim( 'hello   '), 'hello', 'trim trims at string end' );
    is( trim( '  hello  '), 'hello', 'trim trims at both string beginning and end' );
    is( trim( ' a b c ' ), 'a b c', 'trim does not trim within a string' );
    is( trim( undef ), undef, 'trim of undef is undef' );
}


__PACKAGE__->meta->make_immutable;

1;