package FOEGCL::Membership::Schema::WebApp::ResultSet;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::Shortcut::HRI');

1;
