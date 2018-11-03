package FOEGCL::Membership::Storage::WebAppDatabaseConnectionCache;

# ABSTRACT: Caching database connections

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Types qw(HashRef NonEmptySimpleStr);

has _current => (
    is => 'rw',
    isa => NonEmptySimpleStr,
    predicate => '_has_current',
);

has _cache => (
    is => 'ro',
    isa => HashRef['FOEGCL::Membership::Storage::WebAppDatabaseConnection'],
    traits => [ 'Hash' ],
    lazy => 1,
    default => sub { +{} },
    handles => {
        delete => 'delete',
        exists => 'exists',
        get => 'get',
        is_empty => 'is_empty',
        set => 'set',
    },
);

with 'FOEGCL::Membership::Role::Singleton';

sub set_current ($self, $key) {
    die 'No database connection specified to set current' if ! $key;
    die "Connection cache has no record of a connection to $key"
        if ! defined $key || ! exists $self->_cache->{ $key };

    $self->_set_current($key);
}

sub get_current ($self) {
    return if ! $self->_has_current;
    return $self->get($self->_current);
}

# TODO: WHAT ABOUT DELETING FROM THE CACHE WHEN THE THING DELETED IS CURRENT?

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;