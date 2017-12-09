package FOEGCL::Membership::Schema::Legacy::ResultSet;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(
    'Helper::ResultSet::OneRow',
    'Helper::ResultSet::Shortcut::HRI',
);

1;
