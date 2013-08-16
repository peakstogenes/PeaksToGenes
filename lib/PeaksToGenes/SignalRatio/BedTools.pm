
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

package PeaksToGenes::SignalRatio::BedTools 0.001;

use Moose::Role;
use Carp;
use File::Basename;
use File::Which;
use IPC::Run3;
use List::Util qw(sum);
use File::Path qw(make_path remove_tree);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Parallel::ForkManager;
use Data::Dumper;

with 'PeaksToGenes::Database';

=head2 annotate_signal_ratio

This subroutine is passed the following arguments:

    A string for the sorted IP file
    A string for the sorted Input file
    A string for the current genome
    An integer value for the number of processors being used
    A floating point variable for the scaling factor to be used

And returns a Hash Ref of enrichment values indexed by transcript accession and
relative genomic location column name.

=cut

sub annotate_signal_ratio {
	my $self = shift;
    my $ip_file = shift;
    my $input_file = shift;
    my $genome = shift;
    my $processors = shift;
    my $scaling_factor = shift;

    # Extract the length of the step size used for this genome
    my ($ucsc, $step_size) = split(/-/, $genome);

    # Die if the step size is not found and is not greater than 0
    unless ( $step_size && $step_size > 0 ) {
        croak "\n\nUnable to extract the genome step size from $genome.\n\n";
    }

	# Pre-declare a Hash Ref to store the annotated signal ratio
	# information
	my $indexed_signal_ratios = {};

    # Store the ordered Array Ref of relative coordinates files in a local
    # variable
    my $index_files = $self->index_file_names->{$genome};

    # Run the _map_index_files_to_table_columns subroutine to return an Array
    # Ref of table column names that corresponds to the index_files
    my $index_columns = $self->_map_index_files_to_table_columns(
        $index_files,
        $genome,
    );

	# Create an instance of Parallel::ForkManager with the number of
	# threads allowed based on the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($processors);

	# Define a subroutine to be run at the end of each thread, so that the
	# information is correctly stored in the indexed_peaks Hash Ref
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;

            # Make sure the proper information has been returned
            if ( $data_structure && $data_structure->{index_column} &&
                $data_structure->{ip_reads} && $data_structure->{input_reads} &&
                $data_structure->{genes} && $data_structure->{window_sizes}) {

                # Determine whether the current index_column being returned is
                # introns or exons. If it is, run a function to combine the
                # exons/introns for each gene.
                if ( $data_structure->{index_column} =~ /exon/ ||
                    $data_structure->{index_column} =~ /intron/ ) {

                    # Pre-declare a Hash Ref to hold the values for IP and Input
                    # reads per intron/exon
                    my $reads_per_gene = {};

                    # Iterate through the reads per interval returned
                    for ( my $i = 0; $i < @{$data_structure->{genes}}; $i++ ) {

                        # Add the IP and Input values to the reads_per_gene
                        # structure as Array Ref values
                        push(
                            @{$reads_per_gene->{$data_structure->{genes}[$i]}{input}},
                            $data_structure->{input_reads}[$i]
                        );
                        push(
                            @{$reads_per_gene->{$data_structure->{genes}[$i]}{ip}},
                            $data_structure->{ip_reads}[$i]
                        );

                        # Add the lengths of each intron and exon for the given
                        # gene.
                        if ( $reads_per_gene->{$data_structure->{genes}[$i]}{size} ) {
                            $reads_per_gene->{$data_structure->{genes}[$i]}{size} +=
                            $data_structure->{window_sizes}[$i];
                        } else {
                            $reads_per_gene->{$data_structure->{genes}[$i]}{size} =
                            $data_structure->{window_sizes}[$i];
                        }
                    }

                    # Iterate through each gene, and calculate the reads per
                    # total length
                    foreach my $gene ( keys %{$reads_per_gene} ) {
                        my $enrichment = 
                        (
                            ( sum(@{$reads_per_gene->{$gene}{ip}}) - (scalar(@{$reads_per_gene->{$gene}{ip}}) - 1) ) / 
                            ( ( sum(@{$reads_per_gene->{$gene}{input}}) - (scalar(@{$reads_per_gene->{$gene}{input}}) - 1) ) 
                                * $scaling_factor
                            )
                        ) / $reads_per_gene->{$gene}{size};

                        # Make sure the enrichment is a positive number
                        if ( $enrichment > 0 ) {
                            $indexed_signal_ratios->{$gene}{$data_structure->{index_column}}
                            = log($enrichment) / log(2);
                        } else {
                            $indexed_signal_ratios->{$gene}{$data_structure->{index_column}}
                            = 0;
                        }
                    }
                } else {

                    # Iterate through the genes found in the current relative
                    # genomic location
                    for ( my $index_gene = 0; $index_gene <
                        @{$data_structure->{genes}}; $index_gene++ ) {

                        # Store the ratio of IP reads to Input reads in
                        # indexed_signal_ratios indexed by index gene and relative
                        # genomic location. If the ratio is less than 1, return 1 to
                        # indicate that there was no enrichment.
                        my $enrichment = ($data_structure->{ip_reads}[$index_gene] /
                            ($data_structure->{input_reads}[$index_gene] *
                                $scaling_factor) /
                            $data_structure->{window_sizes}[$index_gene]
                        );
                        if ( $enrichment > 0 ) {
                            $indexed_signal_ratios->{$data_structure->{genes}[$index_gene]}{$data_structure->{index_column}}
                            = log($enrichment) / log(2);
                        } else {
                            $indexed_signal_ratios->{$data_structure->{genes}[$index_gene]}{$data_structure->{index_column}}
                            = 0;
                        }
                    }
                }
            }
		}
	);

    # Use a C-style loop to iterate through the relative genomic index files
    # that have been split by chromosome. Using a C-style loop will allow for
    # cross-referencing of the index_columns Array Ref.
    for ( my $i = 0; $i < @{$index_files}; $i++ ) {

        # Start a new thread if one is available
        $pm->start and next;

        # Pre-declare Array Refs for the genes, IP reads, Input reads, and
        # window sizes respectively.
        my $genes = [];
        my $ip_reads = [];
        my $input_reads = [];
        my $window_sizes = [];

        # Pre-declare Array Refs to hold the intersectBed results for the IP
        # and Input files, respectively
        my $ip_results = [];
        my $input_results = [];

        # Define two strings for the intersectBed calls that will be run for
        # the IP and Input files, respectively
        my $ip_command = join(" ",
            which('intersectBed'),
            '-c',
            '-sorted',
            '-a',
            $index_files->[$i],
            '-b',
            $ip_file
        );
        my $input_command = join(" ",
            which('intersectBed'),
            '-c',
            '-sorted',
            '-a',
            $index_files->[$i],
            '-b',
            $input_file
        );

        # Use IPC::Run3 to run the IP and Input commands, storing the
        # results in the ip_results and input_results, respectively
        run3 $ip_command, undef, $ip_results, undef;
        run3 $input_command, undef, $input_results, undef;

        # Make sure that the results Array Refs are the same length
        unless ( scalar ( @{$ip_results} ) && scalar ( @{$input_results} ) && (
                scalar ( @{$ip_results} ) == scalar ( @{$input_results} ) ) ) {
            croak "\n\n There was a problem running intersectBed. " .
            "There were unequal results produced per gene for the " .
            "IP and Input files.\n\n";
        }

        # Use a C-style loop to iterate through both of the results Array
        # Refs concurrently
        for ( my $j = 0; $j < @{$ip_results}; $j++ ) {

            # Chomp the lines to remove any newline characters
            chomp($ip_results->[$j]);
            chomp($input_results->[$j]);

            # Split the lines by the tab character
            my @ip_line_items = split(/\t/, $ip_results->[$j]);
            my @input_line_items = split(/\t/, $input_results->[$j]);

            # Make sure that the gene accession strings are equal. If not,
            # kill the thread.
            if ( $ip_line_items[3] eq $input_line_items[3] ) {

                # Calculate the factor that will be used to scale the number of
                # reads to the step size and add it to the window_sizes Array
                # Ref
                push( @{$window_sizes}, 
                    (($ip_line_items[2] - $ip_line_items[1] + 1) / $step_size) 
                );

                # Add the gene name, IP reads, and Input reads to their
                # respective Array Ref. Add a pseudo count of 1 to both read
                # values before adding to the Array Ref.
                push(@{$genes}, $ip_line_items[3]);
                push(@{$ip_reads}, ($ip_line_items[4] + 1));
                push(@{$input_reads}, ($input_line_items[4] + 1));
            } else {
                croak "\n\nThere was a problem running intersectBed" .
                ". The results are not 1:1 in relation.\n\n";
            }
        }

        # End the thread and return the relevant information
        $pm->finish(0,
            {
                index_column    =>  $index_columns->[$i],
                genes           =>  $genes,
                ip_reads        =>  $ip_reads,
                input_reads     =>  $input_reads,
                window_sizes    =>  $window_sizes,
            }
        );
    }

    # Make sure all of the threads are finished
    $pm->wait_all_children;

    # Return the indexed_signal_ratios
    return $indexed_signal_ratios;
}

=head2 _map_index_files_to_table_columns

This private subroutine is passed an Array Ref of relative coordinates index
files and the genome string then returns an Array Ref of index file column names
that correspond to the index files.

=cut

sub _map_index_files_to_table_columns   {
    my $self = shift;
    my $index_array = shift;
    my $genome_string = shift;

    # Pre-declare an Array Ref to hold the column names
    my $column_array = [];

    # Iterate through the index_array using File::Basename and regular
    # expressions to convert the files in the index_array into column names.
    for ( my $i = 0; $i < @{$index_array}; $i++ ) {
        my ($filename, $directory, $suffix) = 
        fileparse($index_array->[$i],
            ".bed"
        );

        # Split the filename string by the _ character
        my @location_strings = split(/_/, $filename);

        # Pre-declare an Array Ref to hold the components of the column string
        my $column_components = [];

        foreach my $location_string ( @location_strings ) {
            
            # Don't add the genome_string to the column_components
            unless ( $location_string eq $genome_string ) {

                # Add the lowercase version of the string to the
                # column_components with a '_' character prepended to the string
                push(@{$column_components}, '_' . lc($location_string));
            }
        }

        # Combine the column_components with the 'number_of_peaks' string
        $column_array->[$i] = 
        join("", @{$column_components}, '_number_of_peaks');
    }

    return $column_array;
}

1;
