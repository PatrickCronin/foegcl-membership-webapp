package FOEGCL::Membership::Storage::LegacySchemaDumper;

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Config::LegacyDatabase ();

with 'FOEGCL::Membership::Role::DumpsDBICSchema';

sub _build_db_config ( $self, @ ) {
    return FOEGCL::Membership::Config::LegacyDatabase->instance;
}

sub _build_loader_options ( $self, @ ) {
    my $tables_alternation = join q{|}, qw(
      CityStateZip
      Configuration
      ContactInfo
      ContactType
      DataYears
      Donations
      Friends
      Roles
      RolesTypes
    );

    return { constraint => qr/\A(?:$tables_alternation)\z/, };
}

__PACKAGE__->meta->make_immutable;

1;
