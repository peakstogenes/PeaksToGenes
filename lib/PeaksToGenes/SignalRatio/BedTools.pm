
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
use File::Path qw(make_path remove_tree);
use FindBin;
use lib "$FindBin::Bin/../lib";
use Parallel::ForkManager;
use Data::Dumper;

with 'PeaksToGenes::Database';

=head2 annotate_signal_ratio

This subroutine is passed the following arguments:

    A Hash Ref of merged BED-format reads files for the IP reads
    A Hash Ref of merged BED-format reads files for the Input reads
    A string for the current genome
    An integer value for the number of processors being used
    A floating point variable for the scaling factor to be used

And returns a Hash Ref of enrichment values indexed by transcript accession and
relative genomic location column name.

=cut

sub annotate_signal_ratio {
	my $self = shift;
    my $ip_files_hash = shift;
    my $input_files_hash = shift;
    my $genome = shift;
    my $processors = shift;
    my $scaling_factor = shift;

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

    # Run the _split_index_files_by_chromosome subroutine to return an Array Ref
    # of Hash Refs of relative genomic coordinates that have been split by
    # chromosome
    my $split_index_files = $self->_split_index_files_by_chromosome(
        $index_files,
        $genome
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
                $data_structure->{genes}) {

                # Iterate through the genes found in the current relative
                # genomic location
                for ( my $index_gene = 0; $index_gene <
                    @{$data_structure->{genes}}; $index_gene++ ) {

                    # Store the ratio of IP reads to Input reads in
                    # indexed_signal_ratios indexed by index gene and relative
                    # genomic location. If the ratio is less than 1, return 1 to
                    # indicate that there was no enrichment.
                    my $enrichment = $data_structure->{ip_reads}[$index_gene] / ($data_structure->{input_reads}[$index_gene] * $scaling_factor);
                    if ( $enrichment >= 1 ) {
                        $indexed_signal_ratios->{$data_structure->{genes}[$index_gene]}{$data_structure->{index_column}}
                        = $enrichment;
                    } else {
                        $indexed_signal_ratios->{$data_structure->{genes}[$index_gene]}{$data_structure->{index_column}}
                        = 1;
                    }
                }
            }
		}
	);

    # Use a C-style loop to iterate through the relative genomic index files
    # that have been split by chromosome. Using a C-style loop will allow for
    # cross-referencing of the index_columns Array Ref.
    for ( my $i = 0; $i < @{$split_index_files}; $i++ ) {

        # Start a new thread if one is available
        $pm->start and next;

        # Pre-declare Array Refs for the genes, IP reads, and Input reads,
        # respectively.
        my $genes = [];
        my $ip_reads = [];
        my $input_reads = [];

        # Iterate through the chromosomes defined in the current relative index
        # location
        foreach my $chr ( keys %{$split_index_files->[$i]} ) {

            # Pre-declare Array Refs to hold the intersectBed results for the IP
            # and Input files, respectively
            my $ip_results = [];
            my $input_results = [];

            # Define two strings for the intersectBed calls that will be run for
            # the IP and Input files, respectively
            my $ip_command = join(" ",
                which('intersectBed'),
                '-c',
                '-a',
                $split_index_files->[$i]{$chr},
                '-b',
                $ip_files_hash->{$chr}
            );
            my $input_command = join(" ",
                which('intersectBed'),
                '-c',
                '-a',
                $split_index_files->[$i]{$chr},
                '-b',
                $input_files_hash->{$chr}
            );

            # Use IPC::Run3 to run the IP and Input commands, storing the
            # results in the ip_results and input_results, respectively
            run3 $ip_command, undef, $ip_results, undef;
            run3 $input_command, undef, $input_results, undef;

            # Make sure that the results Array Refs are the same length
            unless ( scalar ( @{$ip_results} ) && scalar ( @{$input_results} ) && ( scalar ( @{$ip_results} ) == scalar ( @{$input_results} ) ) ) {
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
        }

        # End the thread and return the relevant information
        $pm->finish(0,
            {
                index_column    =>  $index_columns->[$i],
                genes           =>  $genes,
                ip_reads        =>  $ip_reads,
                input_reads     =>  $input_reads,
            }
        );
    }

    # Make sure all of the threads are finished
    $pm->wait_all_children;

    # Run the _remove_split_index_files subroutine to delete the temporarily
    # created relative coordinates index files that were split by chromosome.
    $self->_remove_split_index_files($genome);

    # Return the indexed_signal_ratios
    return $indexed_signal_ratios;

#	# Iterate through the ordered index, and intersect the reads file
#	# with the index file. Extract the information from any intersections
#	# that occur and store them in the indexed_peaks Hash Ref.
#	foreach my $index_file (@{$self->genomic_index}) {
#
#		$pm->start and next;
#
#		# Pre-declare a string to hold the genomic location of each index file
#		my $location = '';
#		# Match the location from the file string
#		if ($index_file =~ qr/($base_regex)(.+?)\.bed$/ ) {
#			$location = $2;
#		}
#
#		# If the location string has been found, intersect the location file with the
#		# summits file
#		if ($location) {
#			# Store the string corresponding to either the number of peaks,
#			# peaks information, or the interval size for annotation into a
#			# scalar string so it is easier to store in the Hash Ref.
#			my $peak_number = $location . '_Number_of_Peaks';
#
#			# Pre-declare a string to hold the results of the intersectBed
#			# calls for the IP channel
#			my $intersected_ip_fh = "IP_" . $peak_number . '.bed';
#
#			# Make a back ticks call to intersectBed with the -wo option so
#			# that the original entry for both the experimental intervals
#			# and the genomic intervals are returned for each instance
#			# where the experimental interval overlaps a genomic interval.
#			`intersectBed -wo -a $index_file -b $ip_file > $intersected_ip_fh`;
#
#			# Pre-declare a Hash Ref to hold the information for the IP
#			# peaks
#			my $ip_peaks_hash_ref = {};
#
#			# Open the intersected IP file, and iterate through the lines,
#			# extracting the data and storing the 1Kb normalized number of
#			# reads in the ip_peaks_hash_ref
#			open my $ip_fh, "<", $intersected_ip_fh or 
#			croak "\n\nCould not read from $intersected_ip_fh $! \n\n";
#			while (<$ip_fh>) {
#
#				my $intersected_ip_line = $_;
#
#				chomp ($intersected_ip_line);
#
#				# Split the line by tab
#				my ($index_chr, $index_start, $index_stop, $accession,
#					$ip_chr, $ip_start, $ip_stop, $number_of_ip_reads,
#					$overlap) = split(/\t/, $intersected_ip_line);
#
#				# Calculate the size of the interval
#				my $ip_interval_size = $index_stop - $index_start + 1;
#
#				# Store the number of IP reads per interval normalized by
#				# the size of the interval
#				if ( $ip_peaks_hash_ref->{$accession} ) {
#					$ip_peaks_hash_ref->{$accession} +=
#					($number_of_ip_reads * (1000 / $ip_interval_size));
#				} else {
#					$ip_peaks_hash_ref->{$accession} =
#					($number_of_ip_reads * (1000 / $ip_interval_size));
#				}
#			}
#			close $ip_fh;
#			unlink $intersected_ip_fh;
#
#			# Pre-declare a string to hold the results of the intersectBed
#			# calls for the IP channel
#			my $intersected_input_fh = "Input_" . $peak_number . '.bed';
#
#			`intersectBed -wo -a $index_file -b $input_file > $intersected_input_fh`;
#
#			# Pre-declare a Hash Ref to hold the information for the Input
#			# peaks
#			my $input_peaks_hash_ref = {};
#
#			# Open the intersected Input file, and iterate through the lines,
#			# extracting the data and storing the 1Kb normalized number of
#			# reads in the input_peaks_hash_ref
#			open my $input_fh, "<", $intersected_input_fh or 
#			croak "\n\nCould not read from $intersected_input_fh $! \n\n";
#			while (<$input_fh>) {
#				my $intersected_input_line = $_;
#
#				chomp ($intersected_input_line);
#
#				# Split the line by tab
#				my ($index_chr, $index_start, $index_stop, $accession,
#					$input_chr, $input_start, $input_stop,
#					$number_of_input_reads, $overlap) = split(/\t/,
#					$intersected_input_line);
#
#				# Calculate the size of the interval
#				my $input_interval_size = $index_stop - $index_start + 1;
#
#				if ( $input_peaks_hash_ref->{$accession} ) {
#					$input_peaks_hash_ref->{$accession} +=
#					($number_of_input_reads * (1000 / $input_interval_size));
#				} else {
#					$input_peaks_hash_ref->{$accession} =
#					($number_of_input_reads * (1000 / $input_interval_size));
#				}
#			}
#			close $input_fh;
#			unlink $intersected_input_fh;
#
#			$pm->finish(0, 
#				{
#					ip_peaks			=>	$ip_peaks_hash_ref,
#					input_peaks			=>	$input_peaks_hash_ref,
#					peak_number			=>	$peak_number,
#				}
#			);
#		
#		} else {
#			croak "There was a problem determining the location of the " .
#			"index file relative to transcription start site";
#		}
#	}
#
#	$pm->wait_all_children;
#
#	# Return the Hash Ref of experimental intervals annotated based on
#	# location relative to RefSeq transcripts to the main subroutine.
#	return $indexed_signal_ratios;

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

=head2 _split_index_files_by_chromosome

This subroutine is passed an Array Ref of relative coordinates index files and a
string for the user-defined genome. This subroutine then splits the coordinates
files by chromosome in the tmp directory. This subroutine returns an Array Ref
of Hash Refs containing the file paths to the relative coordinates index files
that are indexed by chromosome.

=cut

sub _split_index_files_by_chromosome    {
    my $self = shift;
    my $relative_coordinates_index_files = shift;
    my $genome_string = shift;

    # Create a folder for the user-defined genome in the tmp folder
    # 
    # Define a string for the path
    my $tmp_base = "$FindBin::Bin/../tmp/" . $genome_string;
    make_path($tmp_base);

    # Pre-declare an Array Ref to hold the paths to the split files
    my $split_files = [];

    # Create an instance of Parallel::ForkManager with the number of threads
    # being equal to the number of relative coordinates
    my $pm = Parallel::ForkManager->new( 
        scalar ( @{$relative_coordinates_index_files} ) 
    );

    # Define a subroutine to be executed at the end of each thread
    $pm->run_on_finish(
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
                $data_structure) = @_;

            # Check to make sure that everything has been returned correctly
            if ( $data_structure && $data_structure->{split_files_hash} ) {

                # Store the information in the split_files Array Ref
                $split_files->[$data_structure->{array_position}] =
                $data_structure->{split_files_hash};
            }
        }
    );

    # Use a C-style loop to iterate through the relative_coordinates_index_files
    # so that the Array Ref position can be known to each thread.
    for ( my $i = 0; $i < @{$relative_coordinates_index_files}; $i++ ) {

        # Start a new thread if one is available
        $pm->start and next;

        # Pre-declare a Hash Ref to hold the per-chromosome coordinates of the
        # current relative index coordinates file
        my $per_chromosome_coordinates = {};

        # Pre-declare a Hash Ref to hold the paths to the per-chromosome
        # coordinates files for the current relative index coordinates file
        my $per_chromosome_files = {};

        # Use File::Basename to extract the relative coordinate location. Then
        # make a directory for the current relative location in the tmp
        # directory below the genome folder
        my ($relative_filename, $relative_dir, $relative_suffix) = fileparse(
            $relative_coordinates_index_files->[$i], ".bed"
        );
        my $relative_base_dir = $tmp_base . '/' . $relative_filename;
        make_path($relative_base_dir);

        # Open the current file, and store the lines by chromosome in the
        # per_chromosome_coordinates Hash Ref
        open my $file, "<", $relative_coordinates_index_files->[$i] or croak
        "\n\nCould not read from " . $relative_coordinates_index_files->[$i] .
        " $!\n\n";
        while (<$file>) {
            my $line = $_;
            chomp($line);
            push( @{$per_chromosome_coordinates->{(split /\t/, $line)[0]}},
                $line
            );
        }
        close $file;

        # Iterate through the chromosomes defined in per_chromosome_coordinates
        # and write them to file. Store the file paths in per_chromosome_files
        foreach my $chr ( keys %{$per_chromosome_coordinates} ) {

            # Define a file path for the current chromosome and relative genomic
            # location
            my $fh = $relative_base_dir . '/' . $chr . '.bed';

            # Write the coordinates to file and store the file in the
            # per_chromosome_files Hash Ref
            open my $out_file, ">", $fh or croak 
            "\n\nCould not write to $fh $! \n\n";
            print $out_file join("\n", @{$per_chromosome_coordinates->{$chr}});
            close $out_file;

            # Clear out the Array Ref
            $per_chromosome_coordinates->{$chr} = [];

            $per_chromosome_files->{$chr} = $fh;
        }

        # End the thread and return the coordinates that were written
        $pm->finish(0,
            {
                array_position      =>  $i,
                split_files_hash    =>  $per_chromosome_files,
            }
        );
    }

    # Make sure all of the threads have finished
    $pm->wait_all_children;

    return $split_files;
}

=head2 _remove_split_index_files

This subroutine is passed a string that corresponds to the user-defined genome.
Using File::Path, this subroutine removes the directory created in tmp for the
relative index files split by chromosome.

=cut

sub _remove_split_index_files   {
    my $self = shift;
    my $genome_string = shift;

    # Define a string for the path to the base directory
    my $base_tmp_dir = "$FindBin::Bin/../tmp/" . $genome_string;

    # Run the remove_tree function from File::Path to remove the temporary files
    remove_tree($base_tmp_dir);
}

1;
