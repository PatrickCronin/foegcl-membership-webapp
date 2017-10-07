package FOEGCL::Membership::Role::HasLegacySchema;

use Moose::Role;

use Const::Fast qw(const);
use English qw(-no_match_vars);
use FOEGCL::Membership::Schema::Legacy ();

const my $DSN => 'dbi:ADO:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=**REDACTED**';

has _legacy_schema => (
	is => 'ro',
	isa => 'FOEGCL::Membership::Schema::Legacy',
	builder => '_build_legacy_schema',	
);

sub _build_legacy_schema {
	die q{Can't access Legacy schema unless on Windows}
		if $OSNAME !~ m/MSWin32/;
	
    return FOEGCL::Membership::Schema::Legacy->connect(
        $DSN,
        undef,
        undef,
        {
            quote_char => [qw([ ])],
            name_sep => q{.},
            # TraceLevel => 5
        }
    );
}

1;