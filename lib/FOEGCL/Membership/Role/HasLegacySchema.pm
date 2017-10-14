package FOEGCL::Membership::Role::HasLegacySchema;

# ABSTRACT: Provides the legacy schema to Moose objects

use FOEGCL::Membership::Moose::Role;

use English qw(-no_match_vars);
use FOEGCL::Membership::Schema::Legacy ();

has _legacy_schema => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Schema::Legacy',
    lazy    => 1,
    builder => '_build_legacy_schema',
);

with 'FOEGCL::Membership::Role::HasConfig';

sub _build_legacy_schema ( $self, @ ) {
    die q{Can't access Legacy schema unless on Windows}
      if $OSNAME !~ m/MSWin32/;

    return FOEGCL::Membership::Schema::Legacy->connect(
        $self->_config->legacy_database->{dsn},
        undef, undef,
        {
            quote_char => [qw([ ])],
            name_sep   => q{.},

            # TraceLevel => 5
        }
    );
}

1;
