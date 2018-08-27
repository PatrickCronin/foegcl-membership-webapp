package FOEGCL::Membership::DarkPAN;

use FOEGCL::Membership::Moose;

=head1

We want full control of our project's CPAN dependencies. Before updating
Perl modules on a live deployment, we want to run our test suite against an
updated version. If a module causes a problem, we can pin an older version
that works until the issue is resolved in another way, and work through that
process in a development environment instead of on production.

Project dependencies are listed in `cpanfile`. `cpanm` is used to download and
save distributions containing the specified modules from the CPAN. `cpanm`
also builds and installed into a temporary cache each downloaded distribution
so that it can determine and download futher depdencies recursively. The full
set of downloaded distributions are committed to the project's git repo in the
DarkPAN; the install cache, if kept, can only serve the purpose of saving some
bandwidth the next time our project distributions are updated from the CPAN.

On deployment, modules and distributions are only installed from our DarkPAN.
`cpanm` is again used to install all distributions from the DarkPAN onto the
machine.

=cut

use FOEGCL::Membership::Types 'Path';
use IPC::Run3 'run3';
use Module::CPANfile ();
use OrePAN2::Repository;
use OrePAN2::Indexer;
use Path::Iterator::Rule;
use Path::Tiny 'path';

{
    use Moose::Util::TypeConstraints 'enum';
    my $mode_enum = enum [ qw( update deploy ) ];
    has action => (
        is => 'ro',
        isa => $mode_enum,
        required => 1,
        documentation => 'One of ' . join(q{,}, $mode_enum->values->@*),
    );
}

has _dist_install_cache_dir => (
    is => 'ro',
    isa => Path,
    lazy => 1,
    builder => '_build_dist_install_cache_dir',
);

has _dist_archive_cache_dir => (
    is => 'ro',
    isa => Path,
    lazy => 1,
    builder => '_build_dist_archive_cache_dir',
);

has _darkpan_dir => (
    is => 'ro',
    isa => Path,
    lazy => 1,
    builder => '_build_darkpan_dir',
);

has _darkpan_repo => (
    is => 'ro',
    isa => 'OrePAN2::Repository',
    lazy => 1,
    builder => '_build_darkpan_repo',
);

with qw(
    FOEGCL::Membership::Role::HasConfig
    MooseX::Getopt::Dashes
);

sub _build_dist_install_cache_dir ( $self, @ ) {
    my $dir =
        $self->_config->infrastructure_dir->child('cpanm-install-cache');
    _maybe_create_dir($dir);
    return $dir;
}

sub _build_dist_archive_cache_dir ( $self, @ ) {
    my $dir = $self->_config->infrastructure_dir->child('cpanm-dist-cache');
    _maybe_create_dir($dir);
    return $dir;
}

sub _build_darkpan_dir ( $self, @ ) {
    my $dir = $self->_config->infrastructure_dir->child('darkpan');
    _maybe_create_dir($dir);
    return $dir;
}

sub _build_darkpan_repo ( $self, @ ) {
    return OrePAN2::Repository->new(
        directory => $self->_darkpan_dir->stringify,
        simple => 1,
    );
}

sub _maybe_create_dir ( $dir ) {
    $dir->mkpath if ! $dir->exists;
}

sub run ( $self ) {
    if ($self->action eq 'update' ) {
        $self->_update;
    }
    elsif ($self->action eq 'deploy' ) {
        $self->_deploy;
    }
}

sub _update ( $self ) {
    # What modules will we need?
    my $cpanfile = Module::CPANfile->new;
    $cpanfile->load;
    my $prereqs = $cpanfile->prereqs;
    my @required_modules = $prereqs->merged_requirements(
        [ $prereqs->phases ],
        [ $prereqs->types_in ],
    )->required_modules;

    # But these are modules, not distributions!

    $self->_validate_cpanfile_integrity;

    $self->_prime_install_cache_from_darkpan;
    $self->_update_archive_and_install_caches_from_cpan;

    # Empty the DarkPAN
    $self->_darkpan_dir->remove_tree;
    $self->_darkpan_dir->mkpath;

    $self->_update_darkpan_from_archive_cache;


    # my $index = $self->_darkpan_repo->load_index;

    # my @dist_archives = Path::Iterator::Rule->new->file->all(
    #     $self->_dist_archive_cache_dir );
    # my @darkpan_archives; 
    # foreach my $archive (@archives) {
    #     push @darkpan_archives,
    #         $self->_dist_archive_cache_dir->inject($archive);
    # }

    # $self->_darkpan_repo->indexer->do_metacpan_lookup(\@darkpan_archives);

    # foreach my $darkpan_archive (@darkpan_archives) {
    #     $self->_darkpan_repo->indexer->add_index($index, $darkpan_archive);    
    # }

    # $self->_darkpan_repo->indexer->write_index($index);

    # Delete any distributions that aren't in the index
    # $self->_darkpan_repo->gc;
}

sub _deploy ( $self ) {
    foreach my $archive ($self->_darkpan_archives) {
        _run_command(
            'cpanm',
            '--from' => 'file://' . $self->_darkpan_dir,
            '--notest',
            $archive,
        );
    }
}

sub _validate_cpanfile_integrity ( $self ) {
    # Check for modules listed twice or modules from the same distribution
    # but with different version numbers
}

# TODO: Only install modules from the darkpan that aren't already in there.
sub _prime_install_cache_from_darkpan ( $self ) {
    # Prime the install cache from the DarkPAN
    foreach my $archive ($self->_darkpan_archives) {
        _run_command(
            'cpanm',
            '--from' => $self->_darkpan_dir,
            '--local-lib-contained' => $self->_dist_install_cache_dir,
            '--notest',
            $archive
        );
    }
}

# Update the archive and install caches from CPAN using the requirements
# specified in the cpanfile
sub _update_archive_and_install_caches_from_cpan ( $self ) {
    _run_command(
        'cpanm',
        '--force',  # Install to cache despite not testing
        '--local-lib-contained' => $self->_dist_install_cache_dir,
        '--save-dists' => $self->_dist_archive_cache_dir,
        '--installdeps', # Also download and build dependencies of built distributions
        '--notest', # Don't test built distributions
        $self->_config->project_root,
    );
}

sub _update_darkpan_from_archive_cache ( $self ) {
    foreach my $archive (
        Path::Iterator::Rule->new->file->all(
            $self->_dist_archive_cache_dir )
    ) {
        $self->_darkpan_repo->inject($archive);
    }

    # Update the DarkPAN index from the archive and install caches
    $self->_darkpan_repo->indexer->make_index;
}

sub _run_command ( @cmd ) {
    say 'Running `' . (join q{ }, @cmd) . q{`};
    run3 \@cmd, \undef, \*STDOUT, \*STDERR;
    die if $?;
}

sub _darkpan_archives ( $self ) {
    return Path::Iterator::Rule->new->file->iname('*.tar.gz')->all(
            $self->_darkpan_dir);
}

__PACKAGE__->meta->make_immutable;

1;
