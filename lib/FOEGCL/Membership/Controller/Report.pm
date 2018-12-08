package FOEGCL::Membership::Controller::Report;

use FOEGCL::Membership::Moose::Mojo;
extends 'Mojolicious::Controller';

use FOEGCL::Membership::Report::ContributingFriends ();
use FOEGCL::Membership::Report::Membership          ();
use Mojo::Asset::Memory                             ();
use POSIX 'strftime';

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub blast_email_list ($self) {
    my @emails = map { $_->{email_address} }
        $self->_schema->resultset('ReportBlastEmailList')->hri->all;

    $self->_render_file_from_asset(
        sprintf(
            '%s %s',
            'Blast Email List',
            DateTime->now->strftime('%Y%m%d %H%M%S.txt')
        ),
        'text/plain; charset=utf-8',
        Mojo::Asset::Memory->new->add_chunk( join ', ', @emails ),
    );
}

sub contributing_friends ($self) {
    my $report = FOEGCL::Membership::Report::ContributingFriends->new;

    $self->_render_file_from_asset(
        $report->basename,
        'application/pdf',
        Mojo::Asset::Memory->new->add_chunk( $report->stringify ),
    );
}

sub current_membership ($self) {
    my $report = FOEGCL::Membership::Report::Membership->new;

    $self->_render_file_from_asset(
        $report->basename,
        'application/pdf',
        Mojo::Asset::Memory->new->add_chunk( $report->stringify ),
    );
}

sub _render_file_from_asset ( $self, $basename, $content_type, $asset ) {
    my $clean_basename = $basename =~ s/"//gr;
    $self->res->headers->content_type($content_type);
    $self->res->headers->content_disposition(
        qq{attachment; filename="$clean_basename"});
    $self->reply->asset($asset);
}

1;
