package TestHelper::TestLoader;

# ABSTRACT: This will find and require all perl modules under the specified dirs in t/lib

use FOEGCL::Membership::Moose;

=head1 DESCRIPTION

This test class is "complicated" because of the need to provide different sets
of tests to the ETL test runner, and the standard test runner.

Why not Test::Class::Moose::Load? It `use ()` all found packages, instead of
requiring them, which prevented symbols in the system under test from being
loaded into test packages that needed them.

=cut

use FOEGCL::Membership::Types qw( ArrayRef Path );
use Module::Runtime 'require_module';
use Path::Iterator::Rule ();
use Path::Tiny 'path';

has _search_root => (
    is            => 'ro',
    isa           => Path,
    default       => sub { path(__FILE__)->parent(2) },
    documentation => 'Defaults to (effectively) t/lib',
);

has specific_classes => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
);

has source_dirs => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    builder => '_build_source_dirs',
    documentation =>
        'List of dirs to read within the search root. Defaults to all the dirs that do not start with a dot.',
);

has _hard_exclude_dirs => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [qw( TestHelper TestRole )] },
    documentation =>
        'List of dirctories in the search root to not scan, even if specified explicitly as a source dir',
);

has skip_dirs => (
    is            => 'ro',
    isa           => ArrayRef,
    default       => sub { [] },
    documentation => 'List of dirs to ignore within the search root',
);

sub _build_source_dirs ( $self, @ ) {
    my $source_dirs = $self->_search_root->visit(
        sub ( $path, $state ) {
            return if $path->is_file;
            return if $path->basename =~ m/\A [.]/x;
            $state->{ $path->basename } = 1;
        },
    );
    return [ keys $source_dirs->%* ];
}

# If specific classes are specified, we only load those. Otherwise, we scan
# for all packages in source_dirs minus _hard_exclude_dirs minus skip_dirs
sub test_class_packages ( $self ) {
    my @test_class_packages
        = $self->specific_classes->@*
        ? $self->_packages_for_specified_classes
        : $self->_scan_for_packages;

    unshift @INC, $self->_search_root->stringify;
    require_module($_) for @test_class_packages;

    return \@test_class_packages;
}

sub _packages_for_specified_classes ( $self ) {

    # TODO: Ensure the found specified_classes are within the provided
    # scannable directories

    my @test_class_packages;
    foreach my $class ( $self->specific_classes->@* ) {
        push @test_class_packages, $class =~ m/::/
            ? $class
            : $self->_paths_to_packages( path($class)->realpath );
    }

    return @test_class_packages;
}

sub _scan_for_packages ($self) {
    my %search_path = map { $_ => 1 } $self->source_dirs->@*;
    delete @search_path{
        $self->_hard_exclude_dirs->@*,
        $self->skip_dirs->@*,
    };

    my @search_paths
        = map { $self->_search_root->child($_) } keys %search_path;

    my @test_class_paths;
    foreach my $search_path (@search_paths) {
        push @test_class_paths,
            map { path($_) }
            Path::Iterator::Rule->new->perl_module->all(
            $search_path->stringify );
    }

    return $self->_paths_to_packages(@test_class_paths);
}

sub _paths_to_packages ( $self, @abs_paths ) {
    return map { $_ =~ s/[.]pm \z//xr }
        map    { $_ =~ s{/}{::}gr }
        map    { $_->relative( $self->_search_root ) } @abs_paths;
}

__PACKAGE__->meta->make_immutable;

1;
