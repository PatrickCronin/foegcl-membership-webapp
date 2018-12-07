package FOEGCL::Membership::Controller::Report;

use FOEGCL::Membership::Moose::Mojo;
extends 'Mojolicious::Controller';

use FOEGCL::Membership::Report::ContributingFriends ();
use FOEGCL::Membership::Report::Membership          ();
use Mojo::Asset::Memory                             ();

with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub blast_email_list ($self) {
    my @emails = map { $_->{email_address} }
        $self->_schema->resultset('ReportBlastEmailList')->hri->all;

    $self->render( text => join ', ', @emails );
}

sub contributing_friends ($self) {
    my $report = FOEGCL::Membership::Report::ContributingFriends->new;

    $self->_render_pdf_asset(
        $report->basename,
        Mojo::Asset::Memory->new->add_chunk( $report->stringify ),
    );
}

sub current_membership ($self) {
    my $report = FOEGCL::Membership::Report::Membership->new;

    $self->_render_pdf_asset(
        $report->basename,
        Mojo::Asset::Memory->new->add_chunk( $report->stringify ),
    );
}

sub _render_pdf_asset ( $self, $basename, $asset ) {
    my $clean_basename = $basename =~ s/"//gr;
    $self->res->headers->content_type('application/pdf');
    $self->res->headers->content_disposition(
        qq{attachment; filename="$clean_basename"});
    $self->reply->asset($asset);
}

1;
