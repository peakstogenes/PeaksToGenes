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
			my $interval_size = $data_structure->{interval_size};

			foreach my $index_gene ( keys %{$data_structure->{ip_peaks}} )
			{
				if (
					$data_structure->{input_peaks}{$index_gene}{$peak_number}
					) {
					$indexed_signal_ratios->{$index_gene}{$peak_number} =
					$data_structure->{ip_peaks}{$index_gene}{$peak_number}
					/
					$data_structure->{input_peaks}{$index_gene}{$peak_number}
					* $self->scaling_factor;
				} else {
					$indexed_signal_ratios->{$index_gene}{$peak_number} = 
					$data_structure->{ip_peaks}{$index_gene}{$peak_number}
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
			my $interval_size = $location . '_Interval_Size';

			# Make a back ticks call to intersectBed with the -wo option so
			# that the original entry for both the experimental intervals
			# and the genomic intervals are returned for each instance
			# where the experimental interval overlaps a genomic interval.
			# The intersected interval lines will be stored in an array.
			my @intersected_ip_peaks = 
			`intersectBed -wo -a $ip_file -b $index_file`;

			# Pre-declare a Hash Ref to hold the information for the IP
			# peaks
			my $ip_peaks_hash_ref = {};

			# Pre-declare a Hash Ref to store the interval size values
			my $interval_size_hash = {};

			# Iterate through the intersected lines and parse the
			# information storing it in the ip_peaks_hash_ref
			foreach my $intersected_ip_line ( @intersected_ip_peaks ) {

				chomp ($intersected_ip_line);

				# Split the line by tab
				my ($ip_chr, $ip_start, $ip_end, $ip_number_reads,
					$index_chr, $index_start, $index_stop, $index_gene,
					$overlap) = split(/\t/, $intersected_ip_line);

				# Store the number of IP reads per interval
				if ( $ip_peaks_hash_ref->{$index_gene}{$peak_number} ) {
					$ip_peaks_hash_ref->{$index_gene}{$peak_number} +=
					$ip_number_reads;
				} else {
					$ip_peaks_hash_ref->{$index_gene}{$peak_number} =
					$ip_number_reads;
				}

				# If an experimental interval has been found for this
				# genomic interval, store the minimum and maximum
				# index_start and index_stop to calculate the size of the
				# interval
				if (
					$interval_size_hash->{$index_gene}{$interval_size}{min} ) {
					if ( $index_start <
						$interval_size_hash->{$index_gene}{$interval_size}{min}
						) {
							$interval_size_hash->{$index_gene}{$interval_size}{min}
							= $index_start;
						}
				} else {
					$interval_size_hash->{$index_gene}{$interval_size}{min}
					= $index_start;
				}
				if (
					$interval_size_hash->{$index_gene}{$interval_size}{max} ) {
					if ( $index_stop >
						$interval_size_hash->{$index_gene}{$interval_size}{max}
						) {
							$interval_size_hash->{$index_gene}{$interval_size}{max}
							= $index_stop;
						}
				} else {
					$interval_size_hash->{$index_gene}{$interval_size}{max}
					= $index_stop;
				}

			}

			# Iterate through the interval_size_hash, calculating the size
			# of the intervals, and store the value in the
			# ip_peaks_hash_ref.
			foreach my $index_gene (keys %$interval_size_hash) {
				$ip_peaks_hash_ref->{$index_gene}{$interval_size} =
				$interval_size_hash->{$index_gene}{$interval_size}{max} -
				$interval_size_hash->{$index_gene}{$interval_size}{min} +
				1;
			}

			# Delete the interval_size_hash
			$interval_size_hash = {};

			# Delete the intersected_ip_peaks
			@intersected_ip_peaks = ();

			my @intersected_input_peaks = 
			`intersectBed -wo -a $input_file -b $index_file`;

			# Pre-declare a Hash Ref to hold the information for the Input
			# peaks
			my $input_peaks_hash_ref = {};

			# Iterate through the intersected lines and parse the
			# information storing it in the input_peaks_hash_ref
			foreach my $intersected_input_line ( @intersected_input_peaks ) {

				chomp ($intersected_input_line);

				# Split the line by tab
				my ($input_chr, $input_start, $input_end,
					$input_number_reads, $index_chr, $index_start,
					$index_stop, $index_gene, $overlap) = split(/\t/,
					$intersected_input_line);

				if ( $input_peaks_hash_ref->{$index_gene}{$peak_number} ) {
					$input_peaks_hash_ref->{$index_gene}{$peak_number} +=
					$input_number_reads;
				} else {
					$input_peaks_hash_ref->{$index_gene}{$peak_number} =
					$input_number_reads;
				}
			}

			$pm->finish(0, 
				{
					ip_peaks			=>	$ip_peaks_hash_ref,
					input_peaks			=>	$input_peaks_hash_ref,
					peak_number			=>	$peak_number,
					interval_size		=>	$interval_size,
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
