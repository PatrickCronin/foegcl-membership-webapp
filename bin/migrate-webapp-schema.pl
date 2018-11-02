#!perl
# ABSTRACT: Update the WebApp database from source and unapplied migrations
# PODNAME: migrate-webapp-schema.pl

use FOEGCL::Membership::perlbase;

use FOEGCL::Membership::Storage::WebAppSchemaMigrator ();

FOEGCL::Membership::Storage::WebAppSchemaMigrator->new_with_options
    ->create_or_update_database;
