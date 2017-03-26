package FOEGCL::Membership::Role::HasSchema;

use Moose::Role;

use Const::Fast qw(const);
use FOEGCL::Membership::WebApp::Schema ();

const my $DSN => 'dbi:Pg:dbname=**REDACTED**;host=**REDACTED**';
const my $USERNAME => '**REDACTED**';
const my $PASSWORD => '**REDACTED**';

has _schema => (
	is => 'ro',
	isa => '',
	builder => _build_schema,	
);

sub _build_schema {	
	return FOEGCL::Membership::WebApp::Schema->connect($DSN, $USERNAME, $PASSWORD);
}

1;