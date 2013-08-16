
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

package PeaksToGenes::Contrast::Genes 0.001;
use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

with 'PeaksToGenes::Database';

=head1 NAME

PeaksToGenes::Contrast::Genes  

=cut

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=cut

=head1 DESCRIPTION

This role is consumed by the PeaksToGenes::Contrast controller module to extract
lists of test genes and background genes to be used for statistical tests of
enrichment.

=cut

=head2 get_genes

This subroutine is passed the path to a file containing a list of RefSeq
transcript accessions and an experiment name returns a Hash Ref of valid
accessions indexed by RefSeq ID and with PeaksToGenes transcript_id (gene) as
values. All values found in the file defined by the user will be printed to
STDOUT to show which transcripts were not found in the PeaksToGenes database.

=cut

sub get_genes {
	my $self = shift;
    my $fh = shift;
    my $experiment_name = shift;

    # Extract the genome_id from the experiment_names attribute exported by
    # PeaksToGenes::Database
    my $genome_id = $self->experiment_names->{$experiment_name}{genome_id};

    # If the genome_id can't be found. Die.
    unless ( $genome_id ) {
        croak "\n\nCould not extract the geneome ID for the experiment: " .
        $experiment_name . ". Please check that you have entered the correct" .
        " experiment name.\n\n";
    }

    # Pre-declare a Hash Ref to hold the valid RefSeq accessions as keys and
    # PeaksToGenes transcript ID as values
    my $valid_accession_hash = {};

    # Pre-declare an Array Ref to hold the invalid fields found in the
    # user-defined file
    my $invalid_accessions = [];

    # Open the user-defined file. Iterate through the lines. If the transcript
    # is found in the PeaksToGenes database and it is from the correct genome,
    # add the info to the valid_accession_hash. Otherwise add the line value to
    # the invalid_accessions Array Ref.
    open my $file, "<", $fh or croak "\n\nCould not read from $fh. Please " .
    "check that you have permission to read this file and that you have entered"
    .  " the full path correctly.\n\n";
    while ( <$file> ) {
        my $accession = $_;
        chomp ($accession);

        # Make sure there is still a value on this line
        if ( $accession ) {

            # Remove any whitespace characters that may be polluting the file
            $accession =~ s/\s//g;

            # If the accession is in the transcripts attribute exported by
            # PeaksToGenes::Database and is from the correct genome, add it to
            # the valid_accession_hash. Otherwise add this string value to the
            # Array ref of invalid_accessions
            if ( $self->transcripts->{$genome_id} &&
                $self->transcripts->{$genome_id}{$accession} ) {
                $valid_accession_hash->{$accession} =
                $self->transcripts->{$genome_id}{$accession}{id};
            } else {
                push ( @{$invalid_accessions}, $accession);
            }
        }
    }
    close $file;

    # Print the invalid accessions to STDOUT if there were any found
    if ( scalar ( @{$invalid_accessions} ) ) {
        print "\n\nThe following accessions were not valid for the " .
        "experiment: ", $experiment_name, " in the file: ", $fh, ":\n\n\t";
        print join("\n\t", @{$invalid_accessions}), "\n\n";
    }

    # Make sure that valid accessions were found. If so return them and if not
    # throw an error.
    if ( scalar ( keys %{$valid_accession_hash} ) )  {
        return $valid_accession_hash;
    } else {
        croak "\n\nNo valid valid accessions for the experiment: " .
        "$experiment_name in the file: $fh were found. Please check that this "
        . "list of genes is correctly paired to the proper experiment name and "
        . "that the list of RefSeq accessions is properly formatted.\n\n\t";
    }
}

=head2 get_background_dynamically

This function is passed a Hash Ref of test genes and a string corresponding to
the experiment name currently being accessed. This subroutine then returns all
transcript entries that were not defined in the test genes Hash Ref from the
same genome.

=cut

sub get_background_dynamically  {
    my $self = shift;
    my $test_genes_hash = shift;
    my $experiment_name = shift;

    # Extract the genome_id from the experiment_names attribute exported by
    # PeaksToGenes::Database
    my $genome_id = $self->experiment_names->{$experiment_name}{genome_id};

    # If the genome_id can't be found. Die.
    unless ( $genome_id ) {
        croak "\n\nCould not extract the geneome ID for the experiment: " .
        $experiment_name . ". Please check that you have entered the correct" .
        " experiment name.\n\n";
    }

    # Pre-declare a Hash Ref to hold the valid genes
    my $valid_genes_hash = {};

    # Iterate through the accessions defined in transcripts for the current
    # genome. If the transcript is found in the test_genes_hash, skip it,
    # otherwise add the info to the valid_genes_hash
    foreach my $accession ( keys %{$self->transcripts->{$genome_id}} ) {
        unless ( $test_genes_hash->{$accession} ) {
            $valid_genes_hash->{$accession} =
            $self->transcripts->{$genome_id}{$accession}{id};
        }
    }

    # Make sure that a background set of genes was found. If not die.
    unless ( scalar ( keys %{$valid_genes_hash} ) ) {
        croak "\n\nNo genes were defined for the background set. No contrast " .
        "can be done.\n\n";
    }

    return $valid_genes_hash;
}

1;
