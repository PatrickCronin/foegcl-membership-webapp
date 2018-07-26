package FOEGCL::Membership::Role::VersionedSingleton;

use FOEGCL::Membership::Moose::Role;

use Const::Fast 'const';

const my $VERSIONS_KEY         => 'versions';
const my $CURRENT_VERSION_KEY  => 'current';
const my $DEFAULT_VERSION_NAME => 'default';

my %versioned_singleton;

around 'new' => sub ( $orig, $class, @args ) {
    die 'new is a class operation' if ref $class;

    die
        qq{Can't create a new instance of $class -- the default instance already exists! Use `instance` instead of `new`.}
        if $versioned_singleton{$class}
        && $versioned_singleton{$class}{$VERSIONS_KEY}{$DEFAULT_VERSION_NAME};

    my $default_instance = $class->$orig(@args);
    $class->add_version( $DEFAULT_VERSION_NAME, $default_instance );
    $class->set_current($DEFAULT_VERSION_NAME);

    return $default_instance;
};

sub instance ( $class, @args ) {
    die 'instance is a class operation' if ref $class;

    # Return the current version, building it if necessary
    return $class->new(@args)
        if !$versioned_singleton{$class}
        || !$versioned_singleton{$class}{$CURRENT_VERSION_KEY};

    return $versioned_singleton{$class}{$VERSIONS_KEY}
        { $versioned_singleton{$class}{$CURRENT_VERSION_KEY} };
}

sub version ( $class, $name ) {
    die 'version is a class operation' if ref $class;

    die "$class does not have a $name version"
        if !$versioned_singleton{$class}
        || !$versioned_singleton{$class}{$VERSIONS_KEY}{$name};

    return $versioned_singleton{$class}{$VERSIONS_KEY}{$name};
}

sub add_version ( $class, $name, $instance ) {
    die 'add_version is a class operation' if ref $class;

    die "$class already has a $name version"
        if $versioned_singleton{$class}
        && $versioned_singleton{$class}{$VERSIONS_KEY}{$name};

    $versioned_singleton{$class}{$VERSIONS_KEY}{$name} = $instance;
}

sub version_exists ( $class, $name ) {
    die 'version_exists is a class operation' if ref $class;

    return 1
        if $versioned_singleton{$class}
        && $versioned_singleton{$class}{$VERSIONS_KEY}{$name};

    return 0;
}

sub set_current ( $class, $name ) {
    die 'set_current is a class operation' if ref $class;

    use DDP;
    die "$class does not have a $name version"
        . np $versioned_singleton{$class}{$VERSIONS_KEY}
        if !$versioned_singleton{$class}
        || !$versioned_singleton{$class}{$VERSIONS_KEY}{$name};

    $versioned_singleton{$class}{$CURRENT_VERSION_KEY} = $name;
}

1;
