package FOEGCL::Membership::Role::HasSchema;
# ABSTRACT: Provides the WebApp schema to Moose objects

use Moose::Role;

use FOEGCL::Membership::Schema::WebApp ();

has _schema => (
    is => 'ro',
    isa => 'FOEGCL::Membership::Schema::WebApp',
    lazy => 1,
    builder => '_build_schema',
);

with 'FOEGCL::Membership::Role::HasConfig';

sub _build_schema {
    my $self = shift;

    my $dsn = sprintf(
        'dbi:Pg:dbname=%s;host=%s',
        $self->_config->webapp_database->{database_name},
        $self->_config->webapp_database->{host}
    );

    return FOEGCL::Membership::Schema::WebApp->connect(
        $dsn,
        $self->_config->webapp_database->{username},
        $self->_config->webapp_database->{password}
    );
}

1;
