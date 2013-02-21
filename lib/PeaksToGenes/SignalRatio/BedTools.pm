
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

use Moose;
use Carp;
use Parallel::ForkManager;
use Data::Dumper;

has input_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has ip_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has genomic_index	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef',
	required	=>	1,
);

has scaling_factor	=>	(
	is			=>	'ro',
	isa			=>	'Num',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

has base_regex	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
	default		=>	sub {
		my $self = shift;
		# Create a regular expression string to be used to match the
		# location of each index file.
		my $base_regex = "\.\.\/" . $self->genome . "_Index\/" .
		$self->genome;
		return $base_regex;
	}
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

sub annotate_signal_ratio {
	my $self = shift;

	# Pre-declare a Hash Ref to store the annotated signal ratio
	# information
	my $indexed_signal_ratios = {};

	# Copy the base regular expression into a scalar string
	my $base_regex = $self->base_regex;

	# Store the IP and Input files in scalar variables
	my $input_file = $self->input_file;
	my $ip_file = $self->ip_file;

	# Create an instance of Parallel::ForkManager with the number of
	# threads allowed based on the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be run at the end of each thread, so that the
	# information is correctly stored in the indexed_peaks Hash Ref
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;

			my $peak_number = $data_structure->{peak_number};

			foreach my $index_gene ( keys %{$data_structure->{ip_peaks}} )
			{
				if ( $data_structure->{input_peaks}{$index_gene} ) {
					$indexed_signal_ratios->{$index_gene}{$peak_number} =
					$data_structure->{ip_peaks}{$index_gene} /
					$data_structure->{input_peaks}{$index_gene} *
					$self->scaling_factor;
				} else {
					$indexed_signal_ratios->{$index_gene}{$peak_number} = 
					$data_structure->{ip_peaks}{$index_gene}
					/ $self->scaling_factor;
				}
			}
		}
	);

	# Iterate through the ordered index, and intersect the reads file
	# with the index file. Extract the information from any intersections
	# that occur and store them in the indexed_peaks Hash Ref.
	foreach my $index_file (@{$self->genomic_index}) {

		$pm->start and next;

		# Pre-declare a string to hold the genomic location of each index file
		my $location = '';
		# Match the location from the file string
		if ($index_file =~ qr/($base_regex)(.+?)\.bed$/ ) {
			$location = $2;
		}

		# If the location string has been found, intersect the location file with the
		# summits file
		if ($location) {
			# Store the string corresponding to either the number of peaks,
			# peaks information, or the interval size for annotation into a
			# scalar string so it is easier to store in the Hash Ref.
			my $peak_number = $location . '_Number_of_Peaks';

			# Pre-declare a string to hold the results of the intersectBed
			# calls for the IP channel
			my $intersected_ip_fh = "IP_" . $peak_number . '.bed';

			# Make a back ticks call to intersectBed with the -wo option so
			# that the original entry for both the experimental intervals
			# and the genomic intervals are returned for each instance
			# where the experimental interval overlaps a genomic interval.
			`intersectBed -wo -a $index_file -b $ip_file > $intersected_ip_fh`;

			# Pre-declare a Hash Ref to hold the information for the IP
			# peaks
			my $ip_peaks_hash_ref = {};

			# Open the intersected IP file, and iterate through the lines,
			# extracting the data and storing the 1Kb normalized number of
			# reads in the ip_peaks_hash_ref
			open my $ip_fh, "<", $intersected_ip_fh or 
			croak "\n\nCould not read from $intersected_ip_fh $! \n\n";
			while (<$ip_fh>) {

				my $intersected_ip_line = $_;

				chomp ($intersected_ip_line);

				# Split the line by tab
				my ($index_chr, $index_start, $index_stop, $accession,
					$ip_chr, $ip_start, $ip_stop, $number_of_ip_reads,
					$overlap) = split(/\t/, $intersected_ip_line);

				# Calculate the size of the interval
				my $ip_interval_size = $index_stop - $index_start + 1;

				# Store the number of IP reads per interval normalized by
				# the size of the interval
				if ( $ip_peaks_hash_ref->{$accession} ) {
					$ip_peaks_hash_ref->{$accession} +=
					($number_of_ip_reads * (1000 / $ip_interval_size));
				} else {
					$ip_peaks_hash_ref->{$accession} =
					($number_of_ip_reads * (1000 / $ip_interval_size));
				}
			}
			close $ip_fh;
			unlink $intersected_ip_fh;

			# Pre-declare a string to hold the results of the intersectBed
			# calls for the IP channel
			my $intersected_input_fh = "Input_" . $peak_number . '.bed';

			`intersectBed -wo -a $index_file -b $input_file > $intersected_input_fh`;

			# Pre-declare a Hash Ref to hold the information for the Input
			# peaks
			my $input_peaks_hash_ref = {};

			# Open the intersected Input file, and iterate through the lines,
			# extracting the data and storing the 1Kb normalized number of
			# reads in the input_peaks_hash_ref
			open my $input_fh, "<", $intersected_input_fh or 
			croak "\n\nCould not read from $intersected_input_fh $! \n\n";
			while (<$input_fh>) {
				my $intersected_input_line = $_;

				chomp ($intersected_input_line);

				# Split the line by tab
				my ($index_chr, $index_start, $index_stop, $accession,
					$input_chr, $input_start, $input_stop,
					$number_of_input_reads, $overlap) = split(/\t/,
					$intersected_input_line);

				# Calculate the size of the interval
				my $input_interval_size = $index_stop - $index_start + 1;

				if ( $input_peaks_hash_ref->{$accession} ) {
					$input_peaks_hash_ref->{$accession} +=
					($number_of_input_reads * (1000 / $input_interval_size));
				} else {
					$input_peaks_hash_ref->{$accession} =
					($number_of_input_reads * (1000 / $input_interval_size));
				}
			}
			close $input_fh;
			unlink $intersected_input_fh;

			$pm->finish(0, 
				{
					ip_peaks			=>	$ip_peaks_hash_ref,
					input_peaks			=>	$input_peaks_hash_ref,
					peak_number			=>	$peak_number,
				}
			);
		
		} else {
			croak "There was a problem determining the location of the " .
			"index file relative to transcription start site";
		}
	}

	$pm->wait_all_children;

	# Return the Hash Ref of experimental intervals annotated based on
	# location relative to RefSeq transcripts to the main subroutine.
	return $indexed_signal_ratios;

}

1;
