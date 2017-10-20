package FOEGCL::Membership::Role::Singleton;

use FOEGCL::Membership::Moose::Role;

my %singletons;

sub instance ( $class, @args ) {

    # warn "Returned singleton instance for $class";
    die q{Can't get an instance from an instance!} if ref $class;

    return $singletons{$class} //= $class->new(@args);
}

around 'new' => sub ( $orig, $self, @args ) {
    die q{Can't get a new instance of }
      . ( ref $self )
      . q{ -- instance already exists! Use `instance` instead of `new`.}
      if $singletons{ ref $self };

    return $self->$orig(@args);
};

1;
