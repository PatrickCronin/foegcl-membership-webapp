package FOEGCL::Membership::Report::ContributingFriends;

use FOEGCL::Membership::Moose;

use DateTime          ();
use PDF::ReportWriter ();
use POSIX 'strftime';

has _report_writer => (
    is      => 'ro',
    isa     => 'PDF::ReportWriter',
    lazy    => 1,
    builder => '_build_report_writer',
);

with 'FOEGCL::Membership::Role::HasWebAppSchema';

my $data_row_number = 0;

sub _build_report_writer ( $self, @ ) {
    return PDF::ReportWriter->new(
        {
            destination       => '/tmp/contributing_friends_report.pdf',
            paper             => 'Letter',
            orientation       => 'landscape',
            font_list         => [qw( Times )],
            default_font      => 'Times',
            default_font_size => 10,
            x_margin => 30,    # in points; 72 pt = 1 in
            y_margin => 30,
            info     => {
                Author  => 'FOEGCL::Membership Report Generator',
                Subject => 'Contributing Friends Report',
                Title   => 'Contributing Friends Report',
            },
        }
    );
}

sub run ($self) {
    $self->_report_writer->render_data(
        {
            page       => $self->_page_settings,
            headings   => $self->_field_headings,
            fields     => $self->_fields,
            data_array => $self->_report_data,
        }
    );
    $self->_report_writer->save;
}

sub _page_settings ($self) {
    return {
        header => [
            {
                percent   => 100,
                font_size => 20,
                align     => 'left',
                text      => 'Contributing Friends - ' . DateTime->now->year,
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
    return [
        _standard_cell( { name => 'Year',                  percent => 6, } ),
        _standard_cell( { name => "Contributing\nFriends", percent => 12, } ),
        _standard_cell( { name => 'Renewees',              percent => 10, } ),
        _standard_cell( { name => 'Refreshees',            percent => 10, } ),
        _standard_cell( { name => 'First Timers',          percent => 10, } ),
        _standard_cell( { name => "Total\nContributed",    percent => 12, } ),
        _standard_cell( { name => "Membership\nPortion",   percent => 12, } ),
        _standard_cell( { name => "Donation\nPortion",     percent => 10, } ),
        _standard_cell(
            { name => "Number of\nContributions", percent => 12, }
        ),
    ];
}

sub _report_data ($self) {
    my $rs = $self->_schema->resultset('ReportContributingFriend')->hri;

    my @data;
    while ( my $person = $rs->next ) {
        push @data, [
            $person->{Year},
            $person->{'Contributing Friends'} // q{},
            $person->{Renewees} // q{},
            $person->{Refreshees} // q{},
            $person->{'First Timers'} // q{},
            $person->{'Total Contributed'} // q{},
            $person->{'Membership Portion'} // q{},
            $person->{'Donation Portion'} // q{},
            $person->{'Number of Contributions'} // q{},
        ];
    }

    return \@data;
}

sub _standard_cell ( $args ) {
    return {
        align           => 'left',
        background_func => \&_alternate_data_row_background,
        colour          => 'black',
        font_size       => 10,
        name            => 'Unnamed',
        percent         => 10,
        wrap_text       => 1,
        $args->%*
    };
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
