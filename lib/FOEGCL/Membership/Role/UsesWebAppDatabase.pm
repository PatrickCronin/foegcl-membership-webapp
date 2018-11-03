package FOEGCL::Membership::Role::UsesWebAppDatabase;

# ABSTRACT: Provides the WebApp schema to Moose objects

use FOEGCL::Membership::Moose::Role;

use FOEGCL::Membership::Config::WebAppDatabase ();
use FOEGCL::Membership::Schema::WebApp         ();

sub _schema;
has _schema => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Schema::WebApp',
    lazy    => 1,
    builder => '_build_schema',
    clearer => '_clear_schema',
);

sub _dbh;
has _dbh => (
    is      => 'ro',
    isa     => 'DBI::db',
    lazy    => 1,
    builder => '_build_dbh',
    clearer => '_clear_dbh',
);

sub _build_schema ( $self, @ ) {
    return FOEGCL::Membership::Schema::WebApp->connect(
        FOEGCL::Membership::Config::WebAppDatabase->instance->connect_info );
}

sub _build_dbh ( $self, @ ) {
    return $self->_schema->storage->dbh;
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _reset_schema( $self ) {
    ## use critic
    $self->_clear_dbh;
    $self->_clear_schema;
}

# TODO: protect the constraint names!
## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _defer_constraints ( $self, @constraints ) {
    ## use critic
    push @constraints, qw(ALL) if !@constraints;
    my $constraint_string = join ', ', @constraints;
    $self->_dbh->do("SET CONSTRAINTS $constraint_string DEFERRED");
}

# TODO: protect the constraint names!
## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _restore_constraints ( $self, @constraints ) {
    ## use critic
    push @constraints, qw(ALL) if !@constraints;
    my $constraint_string = join ', ', @constraints;
    $self->_dbh->do("SET CONSTRAINTS $constraint_string IMMEDIATE");
}

1;
