package FOEGCL::Membership::Config::WebAppDatabase;

use FOEGCL::Membership::Moose;

use Const::Fast qw( const );
use FOEGCL::Membership::Types qw( HashRef NonEmptySimpleStr PortNumber );

has database => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    builder => '_build_database',
);

has host => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    lazy    => 1,
    builder => '_build_host',
);

has port => (
    is      => 'ro',
    isa     => PortNumber,
    lazy    => 1,
    builder => '_build_port',
);

has _db_config => (
    is      => 'ro',
    isa     => HashRef,
    lazy    => 1,
    builder => '_build_db_config',
);

with qw(
    FOEGCL::Membership::Role::ConfiguresDatabase
    FOEGCL::Membership::Role::HasConfig
);

const my $WEBAPP_DB_CONFIG_KEY => 'WebApp Database';

# Note that the complete database name in Postgres should be 63 characters or
# less.
sub _build_database ( $self, @ ) {
    return $self->_db_config->{database};
}

sub _build_db_config ( $self, @ ) {
    return $self->_config->{$WEBAPP_DB_CONFIG_KEY};
}

sub _build_host ( $self, @ ) {
    return $self->_db_config->{host} // '127.0.0.1';
}

sub _build_port ( $self, @ ) {
    return $self->_db_config->{port} // 5432;
}

sub _build_dsn ( $self, @ ) {
    return
        sprintf( 'dbi:Pg:dbname=%s;host=%s', $self->database, $self->host );
}

sub _build_username ( $self, @ ) {
    return $self->_db_config->{username};
}

sub _build_password ( $self, @ ) {
    return $self->_db_config->{password};
}

sub _build_dbi_attributes ( $self, @ ) {
    return {
        AutoCommit => 1,
        RaiseError => 1,
        PrintError => 1,
        PrintWarn  => 1,
    };
}

sub _build_schema_class_name ( $self, @ ) {
    return 'FOEGCL::Membership::Schema::WebApp';
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;
