package FOEGCL::Membership::Report::Membership;

# ABSTRACT: The Current Membership report

use FOEGCL::Membership::Moose;

use POSIX 'strftime';
use FOEGCL::Membership::Report::PDFReportCreator;

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
        name                 => 'Membership Report',
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
            text      => 'Current Friends Membership - '
                . strftime( '%Y', localtime ),
        }
    ];
}

sub _page_footer_cells {
    [
        {
            percent   => 60,
            font_size => 10,
            align     => 'left',
            text      => 'Created on ' . strftime( '%d %b %Y', localtime ),
        },
        {
            percent   => 40,
            font_size => 10,
            align     => 'right',
            text      => 'Page %PAGE% of %PAGES%',
        },
    ];
}

sub _data_header_settings {
    {
        background => {
            shape  => 'box',
            colour => 'darkgray',
        }
    };
}

sub _data_field_settings {
    [
        { name => 'Member',              percent => 20, },
        { name => 'Street Address',      percent => 22, },
        { name => 'City, State and ZIP', percent => 25, },
        { name => 'Email(s)',            percent => 23, },
        { name => 'Phone(s)',            percent => 10, },
    ];
}

sub _data ($self) {
    my $rs = $self->_schema->resultset('ReportCurrentMembershipList')->hri;

    my @data;
    while ( my $person = $rs->next ) {
        push @data, [
            $person->{name},
            $person->{street_lines} // q{},
            $person->{csz}          // q{},
            $person->{emails}       // q{},
            $person->{phones}       // q{},
        ];
    }

    return \@data;
}

__PACKAGE__->meta->make_immutable;

1;
