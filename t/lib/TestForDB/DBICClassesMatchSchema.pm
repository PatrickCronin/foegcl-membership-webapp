package TestForDB::DBICClassesMatchSchema;

use FOEGCL::Membership::Test::Class::Moose;

use Algorithm::Diff ();
use File::Copy::Recursive 'dircopy';
use FOEGCL::Membership::Storage::WebAppSchemaDumper ();
use List::Compare                                   ();
use List::Util                                      ();
use Module::Runtime 'module_notional_filename';
use Path::Iterator::Rule ();
use Path::Tiny qw(tempdir path);

with qw(
    FOEGCL::Membership::Role::HasConfig
    FOEGCL::Membership::Role::UsesWebAppDatabase
);

sub test_dbic_classes_match_schema ( $self, @ ) {
    my $tempdir = tempdir();

    my $relative_schema_path
        = module_notional_filename( $self->_db_config->schema_class_name );

    my $webapp_schema_path
        = $self->_config->project_root->child( 'lib', $relative_schema_path );

    my $temp_schema_path = $tempdir->child($relative_schema_path);

    # Copy the existing DBIC classes to the temp dump location so that any
    # customizations can be incorporated into the temp dump and they don't
    # get reported as unexpected diffs.
    diag 'Copying existing DBIC classes to temp dump location...';
    dircopy(
        $webapp_schema_path->parent->child('WebApp'),
        $temp_schema_path->parent->child('WebApp'),
    );
    $webapp_schema_path->copy($temp_schema_path);

    # We dump the DBIC classes for the test database, which is fresh copy
    # of the DDL, and compare those classes with the existing DBIC classes
    # in the repo.
    diag 'Dumping DBIC classes for the current WebApp schema...';
    FOEGCL::Membership::Storage::WebAppSchemaDumper->new(
        db_config      => $self->_db_config,
        dump_directory => $tempdir->stringify,
    )->run;

    # Diff the schema class itself
    $self->_diff_file( $webapp_schema_path, $temp_schema_path );

    # Diff the resultset and result classes
    $self->_diff_dirs(
        $webapp_schema_path->parent->child('WebApp'),
        $temp_schema_path->parent->child('WebApp'),
    );
}

sub _diff_dirs ( $self, $dir1, $dir2 ) {
    my $rule          = Path::Iterator::Rule->new;
    my @dir1_contents = map { path($_)->relative($dir1) } $rule->all($dir1);
    my @dir2_contents = map { path($_)->relative($dir2) } $rule->all($dir2);

    my $lc = List::Compare->new( \@dir1_contents, \@dir2_contents );

    for my $relative ( $lc->get_unique ) {
        fail("$relative is not supported by the current schema");
    }

    for my $relative ( $lc->get_complement ) {
        fail("Expected to find $relative based on the current schema");
    }

    for my $relative ( $lc->get_intersection ) {
        $self->_diff_file( $dir1->child($relative), $dir2->child($relative) );
    }
}

sub _diff_file ( $self, $file1, $file2 ) {
    my $diff = Algorithm::Diff->new( [ $file1->lines ], [ $file2->lines ] );

    my @ignorable_items = (
        qr/^\s*$/,
        qr/^# Created by DBIx::Class::Schema::Loader/,
        qr/^# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/,
    );

    my @differences;
    $diff->Base(1);              # Return line numbers, not indices
    while ( $diff->Next() ) {    # for each hunk in the diff
        next if $diff->Same();

        my @deletions = grep {
            my $item = $_;
            List::Util::none { $item =~ $_ } @ignorable_items
        } $diff->Items(1);

        my @insertions = grep {
            my $item = $_;
            List::Util::none { $item =~ $_ } @ignorable_items
        } $diff->Items(2);

        next if !@insertions && !@deletions;

        my $sep = q{};
        if ( !@insertions ) {
            push @differences,
                sprintf "%d,%dd%d\n", $diff->Get(qw( Min1 Max1 Max2 ));
        }
        elsif ( !@deletions ) {
            push @differences,
                sprintf "%da%d,%d\n", $diff->Get(qw( Max1 Min2 Max2 ));
        }
        else {
            $sep = "---\n";
            push @differences,
                sprintf "%d,%dc%d,%d\n",
                $diff->Get(qw( Min1 Max1 Min2 Max2 ));
        }

        push @differences, "< $_" for @deletions;
        push @differences, $sep;
        push @differences, "> $_" for @insertions;
    }

    my $path = $file1->relative( $self->_config->project_root );
    ok( !@differences, $path )
        or diag explain @differences;
}

__PACKAGE__->meta->make_immutable;

1;
