
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

package PeaksToGenes::Contrast 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Contrast::ParseStats;
use PeaksToGenes::Contrast::Aggregate;
use PeaksToGenes::Contrast::Out;
use Data::Dumper;

with 'PeaksToGenes::Database'; 
with 'PeaksToGenes::Contrast::Genes';
with 'PeaksToGenes::Contrast::GenomicRegions'; 
with 'PeaksToGenes::Contrast::Stats';
with 'PeaksToGenes::Contrast::Aggregate';

=head1 NAME

PeaksToGenes::Contrast  

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=cut

=head1 DESCRIPTION

This module is called by the main PeaksToGenes module and provides the busniess
logic to extract aggregate peaks information based on a user-defined list of
RefSeq accessions and a user-defined set of indexed peaks. This module will tell
the user about any accessions in their list that are not found in the database,
and will not run if the user has not chosen a valid name for a set of indexed
peaks.

=cut

=head2 name

This Moose attribute holds the user-defined string for an experiment name
defined in the PeaksToGenes database. This attribute is required for object
creation.

=cut

has name    =>  (
    is          =>  'ro',
    isa         =>  'Str',
    required    =>  1,
    lazy        =>  1,
    default     =>  sub {
        croak "\n\nYou must set an experiment name to use this class.\n\n";
    },
);

=head2 test_genes_fh

This Moose attribute holds the user-defined path to the file containing a list
of RefSeq transcript accessions that will be compared to either the rest of the
current genome or a list of background genes defined from the file in
'background_genes_fh'.

=cut

has test_genes_fh   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    required    =>  1,
    lazy        =>  1,
    default     =>  sub {
        croak "\n\nYou must set a list of test genes to use this class.\n\n";
    },
);

=head2 background_genes_fh

This Moose attribute holds the user-defined path to the file containing a list
of RefSeq transcript accessions that will be used as a set of background genes
to compare the binding of the factor corresponding to the current 'name'
experiment. This attribute is not required, and if not filled, will be trigger
this list of genes to be automatically defined.

=cut

has background_genes_fh =>  (
    is          =>  'ro',
    isa         =>  'Str',
    predicate   =>  'has_background_genes_fh',
);

=head2 contrast_name

This Moose attribute holds a user-defined string that corresponds to the name of
the contrast they are currently running. This attribute is required and must be
set at runtime. Using a unique name here will help to ensure that previous
analyses are not overwritten.

=cut

has contrast_name   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    required    =>  1,
    lazy        =>  1,
    default     =>  sub {
        croak "\n\nYou must set a contrast name to use this class.\n\n";
    },
);

=head2 statistical_tests

This Moose attribute holds a Hash Ref of named statistical tests as keys and
Boolean values as values that define whether that test will be run or not. By
default, the values of this Hash Ref are set to False.

=cut

has statistical_tests   =>  (
    is              =>  'ro',
    isa             =>  'HashRef[Bool]',
    required        =>  1,
    default         =>  sub {
        my $self = shift;
        return {
            wilcoxon        =>  0,
            point_biserial  =>  0,
        };
    },
);

=head2 processors

This Moose attribute holds the desired number of processors the user would like
to use for executing the PeaksToGenes contrast function. This is an integer
value that must be greater than 0. By default this value is set to 1.

=cut

has processors  =>  (
    is          =>  'ro',
    isa         =>  'Int',
    default     =>  1,
);

=head2 fisher_threshold

This Moose attribute holds the floating point value at which binding ratios will
be separated into "bound" and "unbound" for the Fisher exact test. By default,
this value is set to 1, which will separate regions with one or more peaks from
regions that have no peaks.

=cut

has fisher_threshold    =>  (
    is          =>  'ro',
    isa         =>  'Num',
    default     =>  0,
);

=head2 valid_test_genes

This Moose attribute holds a Hash Ref of RefSeq accessions as Keys and
transcript_id (gene) PeaksToGenes database row_ID values as values.

=cut

has valid_test_genes    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_valid_test_genes',
    writer      =>  '_set_valid_test_genes',
);

before  'valid_test_genes'  =>  sub {
    my $self = shift;
    unless ($self->has_valid_test_genes) {
        $self->_set_valid_test_genes(
            $self->get_genes(
                $self->test_genes_fh,
                $self->name,
            )
        );
    }
};

=head2 valid_background_genes

This Moose attribute holds a Hash Ref of RefSeq accessions as Keys and
transcript_id (gene) PeaksToGenes database row_ID values as values. This
attribute is dynamically filled based on whether the user has defined a file for
the background set of genes.

=cut

has valid_background_genes  =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_valid_background_genes',
    writer      =>  '_set_valid_background_genes',
);

before  'valid_background_genes'    =>  sub {
    my $self = shift;
    unless ( $self->has_valid_background_genes ) {

        # Determine whether a background file has been set or not. If this file
        # has been set, use the get_genes function from
        # PeaksToGenes::Contrast::Genes to fill the attribute. If not, use the
        # get_background_dynamically function from PeaksToGenes::Contrast::Genes.
        if ( $self->has_background_genes_fh ) {
            $self->_set_valid_background_genes(
                $self->get_genes(
                    $self->background_genes_fh,
                    $self->name,
                )
            );
        } else {
            $self->_set_valid_background_genes(
                $self->get_background_dynamically(
                    $self->valid_test_genes,
                    $self->name,
                )
            );
        }
    }
};

=head2 test_and_contrast

This subroutine is called by the main PeaksToGenes class.

First, this subroutine ensures that the database contains the set of indexed
peaks defined by the user. If it does not, the program dies and tell the user
that the peaks they are looking for are not in the database.

Second, this subroutine checks each RefSeq accession given by the user to ensure
that the given accession is indexed in the user-defined database. Each invalid
accession is returned to the user in an error message during program execution.

Finally, while iterating through and testing the possible RefSeq accessions,
this program creates an aggregate of the number of peaks in each relative
location for the subset of user-defined accessions. This is returned to the
PeaksToGenes main module in the form of an Array Ref.

=cut

sub test_and_contrast {
    my $self = shift;

    # Run the 'all_regions' function imported from
    # PeaksToGenes::Contrast::GenomicRegions to get a Hash Ref of all binding
    # for the user-defined experiment name
    my $genome_wide_binding = $self->all_regions($self->name);

    # Run the separate_binding_regions_by_gene_lists subroutine imported from
    # PeaksToGenes::Contrast::GenomicRegions to get Array Refs of binding
    # enrichment data indexed in Hash Refs by relative genomic location as the
    # primary keys and the type of data (test or background) as the secondary
    # keys.
    my $separated_binding_data = $self->separate_binding_regions_by_gene_lists(
        $genome_wide_binding,
        {
            test_genes          =>  $self->valid_test_genes,
            background_genes    =>  $self->valid_background_genes,
        }
    );

    # Run the 'run_statistical_tests' function consumed from
    # PeaksToGenes::Contrast::Stats, which will run any statistical tests
    # defined by the user
    my $statistics_results = $self->run_statistical_tests(
        $separated_binding_data,
        $self->statistical_tests,
        $self->processors,
        $self->fisher_threshold,
    );

    # Run the 'get_binding_stats' consumed from
    # PeaksToGenes::Contrast::Aggregate to get the binding stats for each
    # distribution
    my $descriptive_stats = $self->get_binding_stats(
        $separated_binding_data,
        $self->processors
    );

#    # Create an instance of PeaksToGenes::Contrast::GenomicRegions and run
#    # PeaksToGenes::Contrast::GenomicRegions::extract_genomic_regions to
#    # return a Hash Ref containing two Hash Refs (one for the test and one
#    # for the background) each of which will contain two Array Refs for
#    # each genomic region (one for the peaks per Kb, and one for the peak
#    # scores).
#    my $genomic_regions = PeaksToGenes::Contrast::GenomicRegions->new(
#        schema              =>  $self->schema,
#        name                =>  $self->name,
#        test_genes          =>  $valid_test_genes,
#        background_genes    =>  $valid_background_genes,
#        genome              =>  $self->genome,
#        processors          =>  $self->processors,
#    );
#
#    print "\n\nNow extracting genomic information\n\n";
#    my $genomic_regions_structure =
#    $genomic_regions->extract_genomic_regions;
#
#    # Use the PeaksToGenes::Contrast::GenomicRegions::get_ordered_index
#    # subroutine to extract an ordered Array Ref of genomic locations
#    my $genomic_locations = $genomic_regions->get_ordered_index;
#
#    # Pre-declare a Hash Ref to store the parsed results of any statistical
#    # tests and of the aggregate tables
#    my $parsed_array_refs = {};
#
#    # If any statistical tests have been defined create an instance of
#    # PeaksToGenes::Contrast::Stats, which is a sub-controller type module
#    # to determine which statistical tests have been defined by the user
#    # and will be run.
#    if ( $self->statistical_tests ) {
#
#        print "\n\nNow beginning to run statistical tests\n\n";
#
#        my $stats = PeaksToGenes::Contrast::Stats->new(
#            genomic_regions_structure   =>  $genomic_regions_structure,
#            statistical_tests           =>  $self->statistical_tests,
#            processors                  =>  $self->processors,
#        );
#
#        my $statistical_results = $stats->run_statistical_tests;
#
#        # Create an instance of PeaksToGenes::Contrast::ParseStats in order
#        # to parse the results of the statistical tests using the
#        # PeaksToGenes::Contrast::ParseStats::parse_stats subroutine
#        my $parse_stats = PeaksToGenes::Contrast::ParseStats->new(
#            stats_results   =>  $statistical_results,
#            genomic_index   =>  $genomic_locations,
#        );
#
#        $parsed_array_refs = $parse_stats->parse_stats;
#    }
#
#    # Create a new instance of PeaksToGenes::Contrast::Aggregate to run the
#    # PeaksToGenes::Contrast::Aggregate::create_table subroutine and return
#    # an Array Ref tablet to be stored in the parsed_array_refs Hash Ref
#    my $aggregate = PeaksToGenes::Contrast::Aggregate->new(
#        genomic_regions_structure   =>  $genomic_regions_structure,
#        genomic_index               =>  $genomic_locations,
#    );
#
#    print "\n\nParsing statistical results into tables\n\n";
#
#    $parsed_array_refs->{aggregate} = $aggregate->create_table;
#
#    # Create an instance of PeaksToGenes::Contrast::Out and run the
#    # PeaksToGenes::Contrast::Out::print_tables function, to print the
#    # tables to file based on the user-defined contrast_name
#    my $out = PeaksToGenes::Contrast::Out->new(
#        parsed_array_refs   =>  $parsed_array_refs,
#        contrast_name       =>  $self->contrast_name,
#    );
#
#    print "\n\nPrinting statistical tables to files\n\n";
#
#    $out->print_tables;
}

__PACKAGE__->meta->make_immutable;

1; # End of PeaksToGenes::Contrast
