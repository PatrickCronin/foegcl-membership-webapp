package FOEGCL::Membership::Report::Membership;

use FOEGCL::Membership::Moose;

use DateTime          ();
use PDF::ReportWriter ();
use POSIX 'strftime';

has _report_writer => (
    is      => 'ro',
    isa     => 'PDF::ReportWriter',
    lazy    => 1,
    builder => '_build_report_writer',
    handles => [qw(saveas stringify)],
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

my $data_row_number = 0;

sub _build_report_writer ( $self, @ ) {
    my $report_writer = PDF::ReportWriter->new(
        {
            destination       => '/tmp/membership_report.pdf',
            paper             => 'Letter',
            orientation       => 'landscape',
            font_list         => [qw( Times )],
            default_font      => 'Times',
            default_font_size => 10,
            x_margin => 30,    # in points; 72 pt = 1 in
            y_margin => 30,
            info     => {
                Author  => 'FOEGCL::Membership Report Generator',
                Subject => 'Membership Report',
                Title   => 'Membership Report',
            },
        }
    );

    $report_writer->render_data(
        {
            page       => $self->_page_settings,
            headings   => $self->_field_headings,
            fields     => $self->_fields,
            data_array => $self->_report_data,
        }
    );

    return $report_writer;
}

sub _page_settings ($self) {
    return {
        header => [
            {
                percent   => 100,
                font_size => 20,
                align     => 'left',
                text => 'Current Friends Membership - ' . DateTime->now->year,
            }
        ],
        footer => [
            {
                percent   => 60,
                font_size => 10,
                align     => 'left',
                text      => 'Created on ' . strftime( '%d %b %Y', localtime )
            },
            {
                percent   => 40,
                font_size => 10,
                align     => 'right',
                text      => 'Page %PAGE% of %PAGES%',
            },
        ],
    };
}

sub _field_headings ($self) {
    return {
        background => {
            shape  => 'box',
            colour => 'darkgray',
        }
    };
}

sub _fields ($self) {
    my %defaults = (
        align           => 'left',
        colour          => 'black',
        font_size       => 10,
        wrap_text       => 1,
        background_func => \&_alternate_data_row_background,
    );

    return [
        {
            ## no critic (ValuesAndExpressions::ProhibitCommaSeparatedStatements)
            %defaults,
            name    => 'Member',
            percent => 20,
        },
        {
            %defaults,
            name    => 'Street Address',
            percent => 22,
        },
        {
            %defaults,
            name    => 'City, State and ZIP™',
            percent => 25,
        },
        {
            %defaults,
            name    => 'Email(s)',
            percent => 23,
        },
        {
            %defaults,
            name    => 'Phone(s)',
            percent => 10,
        },
    ];
}

sub _report_data ($self) {
    my $rs = $self->_schema->resultset('ReportCurrentMembershipList')->hri;

    my @data;
    while ( my $person = $rs->next ) {
        push @data, [
            $person->{name},
            $person->{street_lines} // q{},
            $person->{csz} // q{},
            $person->{emails} // q{},
            $person->{phones} // q{},
        ];
    }

    return \@data;
}

sub _alternate_data_row_background ( $value, $row, $options ) {
    $data_row_number++
        if $options->{row_type} eq 'data' && !$options->{cell_counter};

    return {
        shape  => 'box',
        colour => $data_row_number % 2 == 0
        ? 'white'
        : 'lightgray'
    };
}

__PACKAGE__->meta->make_immutable;

1;
