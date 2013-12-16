# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.

package PeaksToGenes 0.001;
use Moose;
use Carp;
use Moose::Util::TypeConstraints;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Annotate;
use PeaksToGenes::Update;
use PeaksToGenes::Contrast;
use PeaksToGenes::SignalRatio;
use PeaksToGenes::Matrix;
use File::Which;
use Data::Dumper;

with 'MooseX::Getopt';
with 'PeaksToGenes::List';
with 'PeaksToGenes::Delete';
with 'PeaksToGenes::Database';

=head1 NAME

PeaksToGenes

=cut

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=cut

=head1 DESCRIPTION

This is the base module for PeaksToGenes.

Included in the main function of this module are several safety catches to
ensure that proper input has been declared by the user prior to execution
of peaksToGenes functions.

This module is not designed to be directly accessed by a Perl script,
but rather it should be accessed through the helper Perl script included
in this distribution utlizing command-line options.

=cut

=head2 Moose attributes

This section has a number of Moose attributes that are typically filled by the
peakstogenes.pl script found in the bin folder using MooseX::Getopt.

=cut

has annotate    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to annotate a dataset and store the results in the PeaksToGenes database',
);

has update  =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to install the genomic coordinates for a RefSeq genome',
);

has list    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to print out a list of the experimnetal names of datasets annotated in your installation of PeaksToGenes',
);

has delete  =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to delete a dataset from the PeaksToGenes database',
);

has contrast    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to run PeaksToGenes in contrast mode',
);

has signal_ratio    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set the mode to annoate a pair of IP and Input BED-format reads',
);

has matrix          =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Set this mode to export a tab-delimited file of peaks/signal ratios for a set of experiments and relative regions for all defined transcripts',
);

has ip_file =>  (
    is              =>  'ro',
    isa             =>  'Str',
    documentation   =>  'Signal Ratio mode only. The path to the BED-format file of IP reads',
    required        =>  1,
    lazy            =>  1,
    default         =>  sub {
        croak "\n\nTo run in signal_ratio mode, you must provide the path to the BED-format IP file.\n\n";
    },
);

has input_file  =>  (
    is              =>  'ro',
    isa             =>  'Str',
    documentation   =>  'Signal Ratio mode only. The path to the BED-format file of Input reads',
    required        =>  1,
    lazy            =>  1,
    default         =>  sub {
        croak "\n\nTo run in signal_ratio mode, you must provide the path to the BED-format Input file.\n\n";
    },
);

has scaling_factor  =>  (
    is              =>  'ro',
    isa             =>  'Num',
    default         =>  1,
    documentation   =>  'Signal Ratio mode only. An optional factor, which is used to scale the number of Input reads. The product of the number of input reads and the scaling factor is used as the denominator when calculating the ratio of IP reads. Default: 1.',
);

has wilcoxon    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Contrast Mode only. Set this mode to run the Wilcoxon (Mann-Whitney) nonparametric test in contrast mode',
);

has fisher    =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  'Contrast Mode only. Set this mode to run the Fisher\'s exact test in contrast mode',
);

has fisher_threshold    =>  (
    is              =>  'ro',
    isa             =>  'Num',
    documentation   =>  'Constrast Mode only. Set this floating point to define a threshold at which enrichment values will be separated into \'bound\' and \'unbound\', respectively.' .
    ' By default, this value is set to zero.',
    predicate       =>  'has_fisher_threshold',
    writer          =>  '_set_fisher_threshold',
);

has genome  =>  (
    is              =>  'ro',
    isa             =>  'Str',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  "The RefSeq genome string corresponding to the data you are working with (hg19, mm9, dm3, etc.)",
    default         =>  sub { croak "\n\nYou must provide the genome corresponding to your experiment.\n\n"},
);

has step_size   =>  (
    is              =>  'ro',
    isa             =>  'Int',
    predicate       =>  'has_step_size',
    documentation   =>  "The size of the windows to be used outside of gene " .
    "bodies and to normalize the length of intra-gene intervals to. By default "
    . "this value is dynamically generated based on the genome. (Update mode "
    . "only)",
);

has full_enrichment =>  (
    is              =>  'ro',
    isa             =>  'Bool',
    documentation   =>  "Signal Ratio mode only. Set this value if you want to "
    .  "index negative enrichment values as well as positive enrichment values."
    . " By default, enrichment ratios less than one are reported as one.",
);

has bed_file    =>  (
    is              =>  'ro',
    isa             =>  'Str',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  "Annotation Mode only. Path to the BED-format file for annotation",
    default         =>  sub { croak "\n\nYou must provide a path to the BED-format file.\n\n"},
);

has 'name'  =>  (
    is              =>  'ro',
    isa             =>  'Str',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  "The name of the experimental sample. Must be unique when running in Annotation Mode.",
    default         =>  sub { croak "\n\nYou must provide the name of the experimental sample.\n\n" },
);

has 'matrix_names'  =>  (
    is              =>  'ro',
    isa             =>  'ArrayRef[Str]',
    documentation   =>  'The names of the experimental samples you wish to combine into a matrix file',
    required        =>  1,
    lazy            =>  1,
    default         =>  sub {[]},
);

has 'test_genes'    =>  (
    is              =>  'ro',
    isa             =>  'Str',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  "Contrast Mode only. The file path to the list of RefSeq accessions (genes) you wish to extract from the database as a test set",
    default         =>  sub { croak "\n\nYou must enter a file name for the Test Genes to run in contrast mode\n\n" },
);

has 'background_genes'  =>  (
    is              =>  'ro',
    isa             =>  'Str',
    predicate       =>  'has_background_genes',
    documentation   =>  " Contrast Mode only. (Optional) The file path to the list of RefSeq accessions (genes) you wish to extract from the database as the background set. By defualt, the inverse (rest of the genome) from the list of test genes will be used as the background unless this flag is set",
);

has gene_list       =>  (
    is              =>  'ro',
    isa             =>  'Str',
    documentation   =>  'Matrix mode only. (Optional) The file path to the list of RefSeq accessions (genes) you wish to use to build the matrix file. Default: all genes in RefSeq genome.',
    default         =>  '',
);

has position_limit  =>  (
    is              =>  'ro',
    isa             =>  'Int',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  'Matrix mode only. (Optional) The integer value for the limits (in Kb) to be used upstream and downstream from the TSS and TSS respectively when making the matrix file. Default: 10',
    default         =>  10,
);

has 'contrast_name' =>  (
    is              =>  'ro',
    isa             =>  'Str',
    required        =>  1,
    lazy            =>  1,
    documentation   =>  "Contrast Mode only. The name of the contrast you are performing.",
    default         =>  sub { croak "\n\nYou must enter a contrast name to run in contrast mode\n\n" },
);

has processors      =>  (
    is              =>  'ro',
    isa             =>  'Int',
    default         =>  1,
    documentation   =>  "The number of processors you would like to run PeaksToGenes with",
);

=head2 execute

This is the main subroutine that is executed. It makes calls to subclasses
to process the summits into their respective locations, and then store the
information in an SQLite3 database.

Options passed to the execute subroutine come from the bin/peaksToGenes.pl
script using MooseX::Getopt.

=cut

sub execute {
    my $self = shift;

    # Determine the how the program will be run
    if ( $self->_check_modes > 1 ) {

        # The user has defined more than one mode, so exit.
        croak "\n\nYou can only specify one mode to run in at a time. Please run peaksToGenes.pl --help to see usage\n\n";

    } elsif ( $self->list ) {

        # Run in list mode
        $self->list_all_experiments;
    } elsif ( $self->delete ) {

        # Run in delete mode
        $self->seek_and_destroy($self->name);
    } elsif ( $self->update ) {

        # Run in update mode

        # Create an instance of PeaksToGenes::Update and run the
        # PeaksToGenes::Update::update subroutine to fetch, create, and
        # install the required files for PeaksToGenes
        if ( $self->has_step_size ) {
            my $update = PeaksToGenes::Update->new(
                genome      =>  $self->genome,
                processors  =>  $self->processors,
                window_size   =>  $self->step_size,
            );

            $update->update;
        } else {
            my $update = PeaksToGenes::Update->new(
                genome      =>  $self->genome,
                processors  =>  $self->processors,
            );

            $update->update;
        }

    } elsif ( $self->annotate ) {

        # Run in annotate mode for peak intervals files

        # Create an instance of PeaksToGenes::Annotate and run
        # PeaksToGenes::Annotate::annotate to create a meta-gene profile of
        # the dataset and insert this profile into the PeaksToGenes
        # database
        my $annotate = PeaksToGenes::Annotate->new(
            schema      =>  $self->schema,
            genome      =>  $self->genome,
            name        =>  $self->name,
            bed_file    =>  $self->bed_file,
            processors  =>  $self->processors,
        );

        $annotate->annotate;

    } elsif ( $self->contrast ) {

        # Run in contrast mode

        # Determine if the fisher_threshold has been set. If not, set this value
        # to zero. If this value has not been set, it is assumed that any value
        # greater than zero is considered binding (which would be true in the
        # case of peaks-derived data).
        unless ( $self->has_fisher_threshold ) {
            $self->_set_fisher_threshold(0);
        }

        # Create an instance of PeaksToGenes::Contrast and run
        # PeaksToGenes::Contrast::test_and_contrast to execute the
        # statistical testing defined by the user. Depending on whether the
        # user has specified a background gene list, this option will be
        # specified when creating the PeaksToGenes::Contrast object.
        if ( $self->has_background_genes ) {
            my $contrast = PeaksToGenes::Contrast->new(
                name                =>  $self->name,
                test_genes_fh       =>  $self->test_genes,
                background_genes_fh =>  $self->background_genes,
                contrast_name       =>  $self->contrast_name,
                processors          =>  $self->processors,
                statistical_tests   =>  {
                    wilcoxon        =>  $self->wilcoxon,
                    fisher          =>  $self->fisher
                },
                fisher_threshold    =>  $self->fisher_threshold,
            );

            $contrast->test_and_contrast;
        } else {
            my $contrast = PeaksToGenes::Contrast->new(
                name                =>  $self->name,
                test_genes_fh       =>  $self->test_genes,
                contrast_name       =>  $self->contrast_name,
                processors          =>  $self->processors,
                statistical_tests   =>  {
                    wilcoxon        =>  $self->wilcoxon,
                    fisher          =>  $self->fisher
                },
                fisher_threshold    =>  $self->fisher_threshold,
            );

            $contrast->test_and_contrast;
        }
    } elsif ( $self->signal_ratio ) {

        # Run in signal_ratio mode for BED-format reads files

        # Create an instance of PeaksToGenes::SignalRatio and run the
        # PeaksToGenes::SignalRatio::create_bed_file subroutine to check
        # the user-defined BED-format files, and then calculate the ratio
        # of IP reads to Input reads. The ratios will be reported in
        # BED-format.
        my $signal_ratio = PeaksToGenes::SignalRatio->new(
            ip_file         =>  $self->ip_file,
            input_file      =>  $self->input_file,
            scaling_factor  =>  $self->scaling_factor,
            name            =>  $self->name,
            genome          =>  $self->genome,
            processors      =>  $self->processors,
            full_enrichment =>  $self->full_enrichment,
        );

        $signal_ratio->index_signal_ratio;

    } elsif ( $self->matrix ) { 

        # Run in matrix mode
        
        # Create an instance of PeaksToGenes::Matrix and run the
        # PeaksToGenes::Matrix::create_matrix subroutine to extract the
        # information for each dataset, and print the information to a
        # tab-delimited file
        my $matrix = PeaksToGenes::Matrix->new(
            matrix_names    =>  $self->matrix_names,
            schema          =>  $self->schema,
            genome          =>  $self->genome,
            gene_list       =>  $self->gene_list,
            position_limit  =>  $self->position_limit,
        );

        $matrix->create_matrix;
    } else {
        croak "\n\nYou must set a mode to run PeaksToGenes in. Use peakToGenes.pl --help for more information\n\n";
    }
}

=head2 _check_modes

The private _check_modes subroutine is designed to make sure that the user
has not defined more than one running mode.

=cut

sub _check_modes {
    my $self = shift;

    # Count the number of modes the user has defined and return an integer
    # for the number of modes defined

    # Pre-define an integer value for the number of modes defined
    my $bool_test = 0;

    if ( $self->delete ) {
        $bool_test++;
    }
    if ( $self->list ) {
        $bool_test++;
    }
    if ( $self->annotate ) {
        $bool_test++;
    }
    if ( $self->update ) {
        $bool_test++;
    }
    if ( $self->contrast ) {
        $bool_test++;
    }
    if ( $self->signal_ratio ) {
        $bool_test++;
    }
    if ( $self->matrix ) {
        $bool_test++;
    }

    return $bool_test;
}

__PACKAGE__->meta->make_immutable;

1; # End of PeaksToGenes
