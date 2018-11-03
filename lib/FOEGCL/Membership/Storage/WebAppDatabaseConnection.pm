package FOEGCL::Membership::Storage::WebAppDatabaseConnection;

# ABSTRACT: Contains a schema and connection handle for a copy of the WebApp DB

use FOEGCL::Membership::Moose;

use Const::Fast 'const';
use FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig ();
use FOEGCL::Membership::Types
    qw( HashRef Maybe NonEmptySimpleStr PortNumber );
use Module::Runtime 'require_module';

has db_config => (
    is        => 'ro',
    does      => 'FOEGCL::Membership::Role::ConfiguresDatabaseConnection',
    lazy => 1,
    default => sub {
        FOEGCL::Membership::Storage::WebAppDatabaseConnectionConfig->new
    },
);

has schema => (
    init_arg => undef,
    is       => 'ro',
    isa      => 'DBIx::Class::Schema',
    lazy     => 1,
    builder  => '_build_schema',
    clearer  => '_clear_schema',
    predicate => '_has_schema',
);

has dbh => (
    init_arg => undef,
    is       => 'ro',
    isa      => 'DBI::db',
    lazy     => 1,
    builder  => '_build_dbh',
    clearer  => '_clear_dbh',
    predicate => '_has_dbh',
);

has migrator => (
    init_arg => undef,
    is => 'ro',
    isa => 'FOEGCL::Membership::Storage::WebAppSchemaMigrator',
    lazy => 1,
    builder => '_build_migrator',
    clearer => '_clear_migrator',
    predicate => '_has_migrator',
);

sub _build_schema ( $self, @ ) {
    my $class = $self->db_config->schema_class_name;
    require_module $class;

    return $class->connect( $self->db_config->connect_info->@* );
}

sub _build_dbh ( $self, @ ) {
    return $self->schema->storage->dbh;
}

sub _build_migrator ( $self, @ ) {
    FOEGCL::Membership::Storage::WebAppSchemaMigrator->new(
        db_config => $self->db_config,
        quiet     => 1,
        verbose   => 0,
    );
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub reset( $self ) {
    ## use critic
    $self->_clear_dbh if $self->_has_dbh;
    $self->_clear_schema if $self->_has_schema;
    $self->migrator->clear_connection if $self->_has_migrator;
}

# TODO: protect the constraint names!
## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub defer_constraints ( $self, @constraints ) {
    ## use critic
    push @constraints, qw(ALL) if !@constraints;
    my $constraint_string = join ', ', @constraints;
    $self->dbh->do("SET CONSTRAINTS $constraint_string DEFERRED");
}

# TODO: protect the constraint names!
## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub restore_constraints ( $self, @constraints ) {
    ## use critic
    push @constraints, qw(ALL) if !@constraints;
    my $constraint_string = join ', ', @constraints;
    $self->dbh->do("SET CONSTRAINTS $constraint_string IMMEDIATE");
}

__PACKAGE__->meta->make_immutable;

1;
