#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: sequenceDepthScale.pl
#
#        USAGE: ./sequenceDepthScale.pl  
#
#  DESCRIPTION: This in a Perl implementation of the sequence depth scaling
#  				algorithm described in Diaz et al Statistical Applications
#  				in Genetics and Molecular Biology 2012.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 09/20/2012 12:44:34 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Getopt::Long;
use Pod::Usage;
use File::Temp;
use Parallel::ForkManager;

# Pre-declare a string for the path to the user-defined chromosome sizes
# file
my $chromosome_sizes_fh = '';

# Pre-define an integer for the size of the step to be used
my $interval_step = 0;

# Pre-declare a string for the path to the user-defined input file
my $input_fh = '';

# Pre-declare a string for the path to the user-defined IP file
my $ip_fh = '';

# Pre-define an integer value for the number of processors to use. By
# default, this program will use one processor.
my $processors = 1;

# Pre-define Boolean false for a help message
my $help = 0;

# Pre-define Boolean false to display the manual
my $man= 0;

# Use Getopt::Long to read the variables in from the command line, while
# specifying that the chromosome sizes file my be a string and the step
# size my be an integer
GetOptions(
	'input=s'				=>	\$input_fh,
	'ip=s'					=>	\$ip_fh,
	'chromosome_sizes=s'	=>	\$chromosome_sizes_fh,
	'step=i'				=>	\$interval_step,
	'processors=i'			=>	\$processors,
	'help|?'				=>	\$help,
	'man'					=>	\$man,
) or pod2usage(2);

# If the user has selected the flag for help, print the POD for usage
if ($help) {
	pod2usage(
		-verbose	=>	1,
	);
}

# If the user has selected the flag for the manual, print the entire POD
if ($man) {
	pod2usage(
		-verbose	=>	2,
	);
}

# Test to ensure that the step size has been defined and is greater than
# zero
if ($interval_step <= 0) {
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\nThe step value must be an unsigned integer greater than 0\n\n",
		-exitval	=>	2,
	);
}

# Open the chromosome sizes file, if there are any errors in the file, or
# if the file is not readable by Perl, exit with an error message and
# display the USAGE and OPTIONS
open my $chromosome_sizes_file, "<", $chromosome_sizes_fh or
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\nYou must enter a valid path to a readable chromosome sizes file.\n\n",
		-exitval	=>	2,
);

# Pre-define a line number in case there are any errors in the chromosome
# sizes file so that an informative error message can be returned to the
# user
my $line_number = 1;

# Pre-declare an Array Ref to hold any error messages to be returned to the
# user
my $error_messages = [];

# Pre-declare a Hash Ref to hold the chromosome sizes
my $chromosome_sizes = {};

while (<$chromosome_sizes_file>) {
	my $line = $_;
	chomp ($line);
	my ($chr, $length) = split(/\t/, $line);
	# Check to make sure that the chromosome is defined, and that the
	# chromosome length is an integer value greater than 0.
	# 
	# If either is in error, push an error message onto the error messages
	# Array Ref to be returned to the user.
	if ( $chr && ( $length > 0 ) ) {
		$chromosome_sizes->{$chr} = $length;
	} else {
		if ( ! $chr ) {
			push(@$error_messages, "The chromosome field on line $line_number, is not defined.");
		}
		if ( $length <= 0 ) {
			push(@$error_messages, "The chromosome length field on line $line_number, is not valid.");
		}
	}
	$line_number++;
}

# If there are errors in the chromosome sizes file, return the errors to
# the user along with the USAGE and OPTIONS sections of the POD
if (@$error_messages) {
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\n" . join("\n", @$error_messages)  .  "\n\n",
		-exitval	=>	2,
	);
}

# Open the input file, if it is not readable, return an error message and the
# help information to the user
open my $input_file, "<", $input_fh or
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\nYou must enter a valid path to a BED-format reads file for the input reads. Please check that $input_fh is the correct path to your file.\n\n",
		-exitval	=>	2,
);

# Open the ip file, if it is not readable, return an error message and the
# help information to the user
open my $ip_file, "<", $ip_fh or
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\nYou must enter a valid path to a BED-format reads file for the IP reads. Please check that $ip_fh is the correct path to your file.\n\n",
		-exitval	=>	2,
);

# Check that the reads files entered are properly formatted and are valid
# within the constraints of the chromosome sizes file
# 
# Using the same subroutine, return the number of reads in each file
my $input_errors = [];
my $ip_errors = [];
my $number_of_input_reads = 0;
my $number_of_ip_reads = 0;
($input_errors, $number_of_input_reads) = check_reads($input_file, $input_fh, $chromosome_sizes);
($ip_errors, $number_of_ip_reads) = check_reads($ip_file, $ip_fh, $chromosome_sizes);

# If there are any errors, return them to the user
if ( @$input_errors ) {
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\n" . join("\n", @$input_errors)  .  "\n\n",
		-exitval	=>	2,
	);
}

if ( @$ip_errors ) {
	pod2usage(
		-verbose	=>	1,
		-message	=>	"\n\n" . join("\n", @$ip_errors)  .  "\n\n",
		-exitval	=>	2,
	);
}

# Now that the files have been checked, create a temporary BED file of
# non-overlapping intervals of the user-defined size

# Pre-declare a Array Ref to hold the coordinates
my $step_coordinates = [];

foreach my $chr ( keys %$chromosome_sizes ) {
	for ( my $i = 0; $i < $chromosome_sizes->{$chr}; $i += $interval_step )
	{
		push(@$step_coordinates, join("\t", $chr, $i, ($i +
					$interval_step -1)));
	}
}

# Create a temporary file object and write the interval coordinates to this
# temporary file
my $temp_bed_fh = File::Temp->new();
my $temp_bed_file_name = $temp_bed_fh->filename;
print $temp_bed_fh join("\n", @$step_coordinates);

# Use intersectBed to determine how many reads are in each interval for the
# IP reads and input reads BED files
#my @interval_ip_reads = `intersectBed -c -a $temp_bed_file_name -b $ip_fh`;
#my @interval_input_reads = `intersectBed -c -a $temp_bed_file_name -b $input_fh`;

my $interval_ip_reads = extract_reads($chromosome_sizes,
	$temp_bed_file_name, $ip_fh , $processors
);
my $interval_input_reads = extract_reads($chromosome_sizes,
	$temp_bed_file_name, $input_fh, $processors
);

sub extract_reads {
	my ($chromosome_sizes, $temp_bed_file_name, $reads_fh, $processors) = @_;

	# Pre-declare an Array Ref to hold the signal from each intersectBed
	# call
	my $reads_per_interval = [];

	# Create an instance of Parallel::ForkManager
	my $pm = Parallel::ForkManager->new($processors);

	# Define a subroutine to be executed at the end of each thread so that
	# the number of overlapped reads per interval will be stored in the
	# reads_per_interval Array Ref at the end of each thread
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$current_reads_per_interval) = @_;
			push(@$reads_per_interval, @$current_reads_per_interval) if
			(@$current_reads_per_interval);
		}
	);

	# Iterate through the chromosomes, extracting the reads for the given
	# chromosome in each file. Write the coordinates to a temporary BED-
	# format file.
	foreach my $current_chr ( keys %$chromosome_sizes ) {

		$pm->start and next;

		# Pre-declare an Array Ref to hold the data for the current
		# chromosome for the current file
		my $current_chr_lines = [];

		# Pre-declare an Array Ref to hold the data for the current
		# chromosome for the genomic intervals file
		my $current_chr_genomic_intervals = [];

		# Iterate through the given file, and extract the lines
		open my $current_file, "<", $reads_fh or die "Could not read from
		$reads_fh $!\n";
		while (<$current_file>) {
			my $line = $_;
			chomp ($line);
			my ($chr, $start, $stop, $name, $score, $strand) = split(/\t/,
				$line
			);

			if ( $chr eq $current_chr ) {
				push (@$current_chr_lines, $line);
			}
		}

		open my $genomic_intervals_fh, "<", $temp_bed_file_name or die
		"Could not read from $temp_bed_file_name $! \n";
		while (<$genomic_intervals_fh>) {
			my $line = $_;
			chomp ($line);
			my ($chr, $start, $stop, $name, $score, $strand) = split(/\t/,
				$line
			);

			if ( $chr eq $current_chr ) {
				push (@$current_chr_genomic_intervals, $line);
			}
		}

		if ( @$current_chr_lines ) {
			# Create an instance of File::Temp to write the current
			# chromosome lines to file.
			my $current_chr_file = File::Temp->new();
			my $current_chr_file_name = $current_chr_file->filename;
			print $current_chr_file join("\n", @$current_chr_lines);

			# Create an instance of File::Temp to write the current
			# chromosome lines to file
			my $current_chr_genomic_intervals_file = File::Temp->new();
			my $current_chr_genomic_intervals_file_name =
			$current_chr_genomic_intervals_file->filename;
			print $current_chr_genomic_intervals_file join("\n",
				@$current_chr_genomic_intervals
			);

			# Run intersectBed to determine the number of reads that
			# overlap the genomic intervals
			my @current_chr_reads_per_interval = `intersectBed -c -a $current_chr_genomic_intervals_file_name -b $current_chr_file_name`;

			$pm->finish(0, \@current_chr_reads_per_interval);
		} else {
			$pm->finish(0, []);
		}
	}

	$pm->wait_all_children;

	return $reads_per_interval;
}

# Pre-declare Hash Refs to store the parsed coordinates and read numbers
# for ordering
my $ip_reads_per_interval = {};
my $input_reads_per_interval = {};

# Iterate through the reads per interval Array, parsing the coordinates and
# storing the number of reads as the value and the coordinate string as the
# key in the ip_reads_per_interval or input_reads_per_interval Hash Refs
foreach my $interval_ip_read (@$interval_ip_reads) {
	my ($chr, $start, $stop, $reads) = split(/\t/, $interval_ip_read);
	$ip_reads_per_interval->{$chr . ':' . $start . '-' . $stop} = $reads;
}
foreach my $interval_input_read (@$interval_input_reads) {
	my ($chr, $start, $stop, $reads) = split(/\t/, $interval_input_read);
	$input_reads_per_interval->{$chr . ':' . $start . '-' . $stop} = $reads;
}

# Sort the IP reads in ascending order based on the number of reads per
# interval, store the keyvalues corresponding to the coordinates of the
# ordered intervals in an Array
my @ordered_intervals = sort { $ip_reads_per_interval->{$a} cmp
$ip_reads_per_interval->{$b} } keys %$ip_reads_per_interval;

# Iterate through the ordered intervals using the interval as the key to
# access the number of reads found in the interval. Calculate the partial
# sum of the number of reads for each interval, and determine the
# cumulative percent of reads for input and IP channels. Store the
# difference between the cumulative percentages and the bin number in a
# Hash Ref, which will be dynamically updated when the difference is
# larger. This will effectively calculate the bin at which the reads in the
# input channel maximally exceeds the reads in the IP channel. 
my $aggregate_ip_reads = 0;
my $aggregate_input_reads = 0;
my $maximum_bin_and_percentage_difference = {
	bin			=>	0,
	difference	=>	0,
};
my $bin = 1;
foreach my $ordered_interval (@ordered_intervals) {
	$aggregate_input_reads +=
	$input_reads_per_interval->{$ordered_interval} if
	($input_reads_per_interval->{$ordered_interval});
	$aggregate_ip_reads += $ip_reads_per_interval->{$ordered_interval} if
	($ip_reads_per_interval->{$ordered_interval});
	my $percentage_difference = (( $aggregate_input_reads /
		$number_of_input_reads ) * 100) - (( $aggregate_ip_reads /
		$number_of_ip_reads ) * 100);
	if ( $percentage_difference >
		$maximum_bin_and_percentage_difference->{difference} ) {
		$maximum_bin_and_percentage_difference->{difference} =
		$percentage_difference;
		$maximum_bin_and_percentage_difference->{bin} = $bin;
	}
	$bin++;
}

# Once the bin with the maximal difference is determine, calculate the
# ratio of the partial sums of reads between the IP and input channels up
# to the determined bin number
my $partial_sum_ip_reads = 0;
my $partial_sum_input_reads = 0;
for ( my $i = 0; $i < $maximum_bin_and_percentage_difference->{bin}; $i++)
{
	$partial_sum_ip_reads +=
	$ip_reads_per_interval->{$ordered_intervals[$i]} if
	$ip_reads_per_interval->{$ordered_intervals[$i]};
	$partial_sum_input_reads +=
	$input_reads_per_interval->{$ordered_intervals[$i]} if
	$input_reads_per_interval->{$ordered_intervals[$i]};
}
my $sequence_depth_scaling_factor = 0;
$sequence_depth_scaling_factor = $partial_sum_ip_reads /
$partial_sum_input_reads if ( $partial_sum_input_reads );
print $sequence_depth_scaling_factor, "\n";

#===  CLASS METHOD  ============================================================
#        CLASS: GLOBAL
#       METHOD: check_reads
#   PARAMETERS: file_handle, file_path, chromosome_sizes_hash_ref
#      RETURNS: array_ref_of_error_messages, number_of_reads
#  DESCRIPTION: The following subroutine is used to check the content of
#  				the user-defined input and IP BED-format files.
#  				It will also determine the number of reads in the file.
#       THROWS: no exceptions
#     COMMENTS: This subroutine will rapidly iterate through a user-defined
#     			BED-file of reads to determine if the file meets the
#     			following criteria:
#     				1. Each line contains 6 fields, seperated by tabs
#     				2. The first field is a valid chromosome name as
#     				   defined in the chromosome sizes file.
#     				3. The second and third fields are integers greater
#     				   than zero
#     				4. The third field is greater than the second field
#     				5. The second and third field are valid coordinates
#     				   based on the length of the chromosome defined in the
#     				   chromosome sizes file.
#     SEE ALSO: 
#===============================================================================

sub check_reads {
	my ($file_handle, $file_path, $chromosome_sizes) = @_;
	# Pre-declare an Array Ref to hold error messages
	my $error_messages = [];
	# Pre-declare an integer for the line number to return useful error
	# messages to the user
	my $line_number = 1;
	
	# Iterate through the file, checking for errors.
	# If any errors are found, add a description to the error_messages
	# Array Ref to be returned to the user.
	while (<$file_handle>) {
		my $line = $_;
		chomp($line);
		my ($chr, $start, $stop, $read_name, $score, $strand) = split(/\t/,
			$line);
		unless ( $chr && $read_name && $strand ) {
			push(@$error_messages, "On line $line_number of the $file_path file, there are not six tab-delimited fields. Please check that your file is correctly formatted");
		}
		if ( $stop <= $start ) {
			push(@$error_messages, "On line $line_number of the $file_path file, the stop coordinate $stop is not larger than the $start coordinate");
		} else {
			if ( ! $chromosome_sizes->{$chr} ) {
				push(@$error_messages, "On line $line_number of the $file_path file, the chromosome specified: $chr is not defined in the chromosome file.");
			} else {
				unless (
					$start >= 0 &&
					$stop >= 0 &&
					$start <= $chromosome_sizes->{$chr} &&
					$stop <= $chromosome_sizes->{$chr} ) {
					push (@$error_messages, "On line $line_number of the $file_path file, the coordinates are out of bounds for the size of the chromosome $chr defined");
				}
			}
		}
		$line_number++;
	}
	return ($error_messages, ($line_number-1));
}

__END__

=head1 NAME

sequenceDepthScale.pl

=head1 DESCRIPTION

This script is a Perl implementation of the sequence depth sclaing
algorithm described in Diaz et al Statistical Applications in Genetics and
Molecular Biology 2012.

This implementation requires that the users reads are mapped and have been
converted to BED format. A typical workflow for this conversion would be to
use Bowtie to map reads in SAM format, convert SAM files to BAM files using
samtools, and finally using bamToBed from BedTools, convert the BAM files
to a BED file.

For the pair of input and IP files defined by the user, a multiplicative
scaling factor will be determined. This scaling factor should be used to
scale the number of reads in the input file when determining enriched
regions in the IP file.

=head1 INPUT FILES

Both the input and IP files must be in BED6 format. To acheive this, the
following workflow is implemented before using this example shell script:

=item B<Example:>

for file in input ip
do
	bowtie -S GENOME ${file}.fastq >> ${file}.sam
	samtools view -bS ${file}.sam > ${file}.bam
	samtools sort ${file}.bam ${file}_sorted
	bamToBed -i ${file}_sorted.bam > ${file}.bed
done

Using Bowtie or Bowtie2 will not affect the resuts, as long as the program
is configured to output mapped reads in SAM format. Please note that with
paired-end reads, this script will not split the interval between the reads
into two separate BED lines.

=head1 SYNOPSIS

sequenceDepthScale.pl --step [STEP VALUE] --input [INPUT FILE] --ip [IP
FILE] --chromosome_sizes [CHROMOSOME SIZES FILE] --processors [NUMBER OF
PROCESSORS]

Options:

	-help				Prints a help page of USAGE and OPTIONS
	-man				Displays the manual in POD format
	--input				Path to the BED-format input file
	--ip				Path to the BED-format IP file
	--chromosome_sizes		Path to chromosome sizes file
	--step				Integer value for step size
	--processors			(Optional) Number of processors

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and then exit.

=item B<-man>

Displate the POD page.

=item B<--chromosome_sizes>

This is the path to the user-defined chromosome sizes file.

The chromosome sizes file is a tab-delimited file, with the first column
being the name of the chromosome, and the second column being an integer
value specifying the length (in bases) of that chromosome.

Please see the chromInfo table on the UCSC MySQL server to download the
appropriate chromosome sizes for the genome you are designing intervals
for.

=item B<--step>

The integer value for the length of each step. Must be an unsigned integer.

=item B<--input>

The path to the user-defined Input file. The reads in this file must be in
BED6 format. Please see the full manual using the -man option for a longer
description on how to generate these files.

=item B<--ip>

The path to the user-defined IP file. The reads in this file must be in
BED6 format. Please see the full manual using the -man option for a longer
description on how to generate these files.

=item B<--processors>

[Optional] The number of processors to use for execution. Default: 1.

=back

=cut

