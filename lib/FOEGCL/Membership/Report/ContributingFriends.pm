package FOEGCL::Membership::Report::ContributingFriends;

# ABSTRACT: The Contributing Friends report

use FOEGCL::Membership::Moose;

use FOEGCL::Membership::Report::PDFReportCreator ();
use POSIX 'strftime';

has _pdf_report_creator => (
    is      => 'ro',
    isa     => 'FOEGCL::Membership::Report::PDFReportCreator',
    lazy    => 1,
    builder => '_build_pdf_report_creator',
    handles => [qw( save saveas stringify )],
);
with 'FOEGCL::Membership::Role::UsesWebAppDatabase';

sub _build_pdf_report_creator ( $self, @ ) {
    return FOEGCL::Membership::Report::PDFReportCreator->new(
        name                 => 'Contributing Friends Report',
        orientation          => 'landscape',
        default_font_size    => 10,
        page_header_cells    => $self->_page_header_cells(),
        page_footer_cells    => $self->_page_footer_cells(),
        data_header_settings => $self->_data_header_settings(),
        data_field_settings  => $self->_data_field_settings(),
        data                 => $self->_data(),
    );
}

sub _page_header_cells {
    [
        {
            percent   => 100,
            font_size => 20,
            align     => 'left',
            text => 'Contributing Friends - ' . strftime( '%Y', localtime ),
        }
    ];
}

sub _page_footer_cells {
    [
        {
            percent => 60,
            align   => 'left',
            text    => 'Created on ' . strftime( '%d %b %Y', localtime )
        },
        {
            percent => 40,
            align   => 'right',
            text    => 'Page %PAGE% of %PAGES%',
        },
    ];
}

sub _data_header_settings {
    {
        background => {
            shape  => 'box',
            colour => 'darkgray',
        },
    };
}

sub _data_field_settings {
    [
        { name => 'Year',                     percent => 6, },
        { name => "Contributing\nFriends",    percent => 12, },
        { name => 'Renewees',                 percent => 10, },
        { name => 'Refreshees',               percent => 10, },
        { name => 'First Timers',             percent => 10, },
        { name => "Total\nContributed",       percent => 12, },
        { name => "Membership\nPortion",      percent => 12, },
        { name => "Donation\nPortion",        percent => 10, },
        { name => "Number of\nContributions", percent => 12, },
    ];
}

sub _data ($self) {
    my $rs = $self->_schema->resultset('ReportContributingFriend')->hri;

    my @data;
    while ( my $person = $rs->next ) {
        push @data,
            [
            map { $person->{$_} // q{} }
                map { $_->{name} =~ s/\n/ /gr }
                $self->_data_field_settings->@*
            ];
    }

    return \@data;
}

__PACKAGE__->meta->make_immutable;

1;
