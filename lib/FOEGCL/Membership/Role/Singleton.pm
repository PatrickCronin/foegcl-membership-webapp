package FOEGCL::Membership::Role::Singleton;

# ABSTRACT: Make an instance a singleton instance

use FOEGCL::Membership::Moose::Role;

my %singleton;

sub instance ( $class, @args ) {
    die q{Can't get an instance from an instance!} if ref $class;

    return $singleton{$class} //= $class->new(@args);
}

around 'new' => sub ( $orig, $self, @args ) {
    die q{Can't get a new instance of }
        . ( ref $self )
        . q{ -- instance already exists! Use `instance` instead of `new`.}
        if $singleton{ ref $self };

    return $self->$orig(@args);
};

1;
