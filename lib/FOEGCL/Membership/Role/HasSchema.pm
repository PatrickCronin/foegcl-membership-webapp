package FOEGCL::Membership::Role::HasSchema;
# ABSTRACT: Provides the WebApp schema to Moose objects

use Moose::Role;

use Const::Fast qw(const);
use FOEGCL::Membership::Schema::WebApp ();

const my $DSN => 'dbi:Pg:dbname=**REDACTED**;host=**REDACTED**';
const my $USERNAME => '**REDACTED**';
const my $PASSWORD => '**REDACTED**';

has _schema => (
	is => 'ro',
	isa => 'FOEGCL::Membership::Schema::WebApp',
	builder => '_build_schema',	
);

sub _build_schema {	
	return FOEGCL::Membership::Schema::WebApp->connect($DSN, $USERNAME, $PASSWORD);
}

1;