package FOEGCL::Membership::Report::PDFReportCreator;

# ABSTRACT: A wrapper around PDF::ReportWriter for simplified MS Access-like report specification

use FOEGCL::Membership::Moose;

use DateTime          ();
use FOEGCL::Membership::Types qw( ArrayRef HashRef NonEmptySimpleStr PositiveInt );
use Path::Tiny ();
use PDF::ReportWriter ();
use POSIX 'strftime';

has name => (
    is => 'ro',
    isa => NonEmptySimpleStr,
    required => 1,
);

{
    use Moose::Util::TypeConstraints 'enum';
    
    my $orientation_enum = enum( [ qw( portrait landscape ) ]);
    has orientation => (
        is => 'ro',
        isa => $orientation_enum,
        lazy => 1,
        default => sub { 'portrait' },
    );
}

has default_font_size => (
    is => 'ro',
    isa => PositiveInt,
    lazy => 1,
    default => sub { 12 },
);

has page_header_cells => (
    is => 'ro',
    isa => ArrayRef[ HashRef ],
    lazy => 1,
    default => sub { {} },
);

has page_footer_cells => (
    is => 'ro',
    isa => ArrayRef[ HashRef ],
    lazy => 1,
    default => sub { {} },
);

has data_header_settings => (
    is => 'ro',
    isa => HashRef,
    lazy => 1,
    default => sub { {} },
);

has data_field_settings => (
    is => 'ro',
    isa => ArrayRef[ HashRef ],
    lazy => 1,
    default => sub { {} },
);

has _data_field_settings_with_defaults => (
    is => 'ro',
    isa => ArrayRef[ HashRef ],
    lazy => 1,
    builder => '_build_data_field_settings_with_defaults',
);

has data => (
    is => 'ro',
    isa => ArrayRef[ ArrayRef ],
    lazy => 1,
    default => sub { {} },
);

has _pdf_report_writer => (
    is => 'ro',
    isa => 'PDF::ReportWriter',
    lazy => 1,
    builder => '_build_pdf_report_writer',
    handles => [qw( save saveas stringify )],
);

sub _build_data_field_settings_with_defaults ( $self, @ ) {
    my %defaults = (
        align           => 'left',
        colour          => 'black',
        wrap_text       => 1,
        background_func => \&_alternate_data_row_bgcolor,
    );

    [ map { { %defaults, $_->%* } } $self->data_field_settings->@* ];
}

sub _build_pdf_report_writer ( $self, @ ) {
    my $pdf_report_writer = PDF::ReportWriter->new(
        {
            destination       => Path::Tiny->cwd->child(
                $self->_report_basename
            )->stringify,
            paper             => 'Letter',
            orientation       => $self->orientation,
            font_list         => [qw( Times )],
            default_font      => 'Times',
            default_font_size => $self->default_font_size,
            x_margin => 30,    # in points; 72 pt = 1 in
            y_margin => 30,
            info     => {
                Author  => 'FOEGCL::Membership Report Generator',
                Subject => $self->name,
                Title   => $self->name,
            },
        }
    );

    $pdf_report_writer->render_data(
        {
            page       => {
                $self->page_header_cells->@*
                ? ( header => $self->page_header_cells )
                : (),
                $self->page_footer_cells->@*
                ? ( footer => $self->page_footer_cells )
                : (),                
            },
            headings   => $self->data_header_settings,
            fields     => $self->_data_field_settings_with_defaults,
            data_array => $self->data,
        }
    );

    return $pdf_report_writer;
}

sub _report_basename ( $self ) {
    return $self->name . q{ } . DateTime->now->strftime('%Y%m%d %H%M%S.pdf');
}

sub _alternate_data_row_bgcolor ( $value, $row, $options ) {
    state $row_number = 0;
    
    $row_number++
        if $options->{row_type} eq 'data' && !$options->{cell_counter};

    return {
        shape  => 'box',
        colour => $row_number % 2
        ? 'white'
        : 'lightgray'
    };
}

__PACKAGE__->meta->make_immutable;

1;