
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

package PeaksToGenes::SignalRatio 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Annotate::FileStructure;
use PeaksToGenes::Annotate::BedTools;
use PeaksToGenes::SignalRatio::BedTools;
use Data::Dumper;

has ip_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has input_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has scaling_factor	=>	(
	is			=>	'ro',
	isa			=>	'Num',
	required	=>	1,
);

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

sub index_signal_ratio {
	my $self = shift;

	# Run the PeaksToGenes::SignalRatio::get_genomic_index subroutine to
	# get an Array Ref of genomic index files
	my $genomic_index = $self->get_genomic_index;

	# Run the PeaksToGenes::SignalRatio::check_files subroutine to be sure
	# that each user-defined BED-format file of reads is valid
	$self->check_files;

	# Run the PeaksToGenes::SignalRatio::merge_files subroutine to merge
	# the overlapping reads and return the string where the temporary files
	# have been written
	my ($merged_ip_file, $merged_input_file) = $self->merge_files;

	# Create an instance of PeaksToGenes::SignalRatio::BedTools and run
	# PeaksToGenes::SignalRatio::BedTools::annotate_signal_ratio to return
	# a Hash Ref of genomic signal ratio data
	my $bedtools = PeaksToGenes::SignalRatio::BedTools->new(
		ip_file			=>	$merged_ip_file,
		input_file		=>	$merged_input_file,
		genome			=>	$self->genome,
		genomic_index	=>	$genomic_index,
		scaling_factor	=>	$self->scaling_factor,
		processors		=>	$self->processors,
	);

	my $indexed_signal_ratios = $bedtools->annotate_signal_ratio;

	unlink ($merged_ip_file);
	unlink ($merged_input_file);

	# Create an instance of PeaksToGenes::Annotate::Database and run the
	# PeaksToGenes::Annotate::Database::parse_and_store subroutine to
	# insert the information into the PeaksToGenes database
	my $database = PeaksToGenes::Annotate::Database->new(
		schema			=>	$self->schema,
		indexed_peaks	=>	$indexed_signal_ratios,
		name			=>	$self->name,
		ordered_index	=>	$genomic_index,
		genome			=>	$self->genome,
		processors		=>	$self->processors,
	);
	$database->parse_and_store;

}

sub get_genomic_index {
	my $self = shift;

	# Create an instance of PeaksToGenes::Annotate::FileStructure and run
	# the PeaksToGenes::Annotate::FileStructure::Test_and_extract
	# subroutine to return an ordered Array Ref of index files
	# corresponding to the user-defined genome.
	my $genomic_index_fetcher = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$self->schema,
		genome	=>	$self->genome,
		name	=>	$self->name,
	);

	my $genomic_index = $genomic_index_fetcher->test_and_extract;

	return $genomic_index;
}

sub check_files {
	my $self = shift;

	# Create an instance of PeaksToGenes::Annotate::BedTools to fetch the
	# chromosome sizes for the given genome
	my $annotate_bedtools = PeaksToGenes::Annotate::BedTools->new(
		schema		=>	$self->schema,
		genome		=>	$self->genome,
		bed_file	=>	$self->ip_file
	);

	# Fetch the chromosome sizes from the database by calling
	# PeaksToGenes::Annotate::BedTools::chromosome_sizes
	my $chromosome_sizes = $annotate_bedtools->chromosome_sizes;

	foreach my $bed_file ( $self->ip_file, $self->input_file ) {

		print "\n\nNow checking $bed_file to ensure that the contents " .
		"are valid\n\n";

		# Pre-declare a line number to return useful errors to the user
		my $line_number = 1;

		# Open the user-defined file, iterate through and parse the lines. Any
		# errors found will cause an immediate termination of the script and
		# return an error message to the user.
		open my $summits_fh, "<", $bed_file or croak 
		"Could not read from BED file: " . $self->bed_file . 
		". Please check the permissions on this file. $!\n\n";
		while (<$summits_fh>) {
			my $line = $_;
			chomp ($line);
			# Split the line by tab characters
			my ($chr, $start, $stop, $name, $score, $strand, $rest_of_line) =
			split(/\t/, $line);

			# Test to make sure the chromosome defined in column 1 is a valid
			# chromosome for the user-defined genome
			unless ( $chromosome_sizes->{$chr} ) {
				croak "On line: $line_number the chromosome: " . $chr . 
				" is not defined in the user-defined genome: " . 
				$self->genome . 
				". Please check your file: $bed_file and the genome you would like to " .
				"use.\n\n";
			}

			# Test to make sure that the values in for the interval start in
			# column 2 and the interval end in column 3 are integers
			unless ( $start =~ /^\d+$/ ) {
				croak "On line: $line_number the interval start defined: " .
				$start . " is not an integer. Please check your file:
				$bed_file.\n\n";
			}
			unless ( $stop =~ /^\d+$/ ) {
				croak "On line: $line_number the interval stop defined: " .
				$stop . " is not an integer. Please check your file:
				$bed_file.\n\n";
			}

			# Test to make sure the integer value defined for the interval end
			# in column three is greater than the interval value defined for
			# the interval start in column two
			unless ( $stop > $start ) {
				croak "On line: $line_number the stop: $stop is not larger " .
				"than the start: $start. Please check your file: $bed_file.\n\n";
			}

			# Test to make sure that the integer values defined for the
			# interval start in column two and the interval end in column three
			# are valid coordinates based on the length of the chromosome
			# defined in column one for the user-defined genome
			unless (($start <= $chromosome_sizes->{$chr}) && 
				($stop <= $chromosome_sizes->{$chr})) {
				croak "On line: $line_number the coordinates are not valid " .
				"for the user-defined genome: " . $self->genome 
				. ". Please check your file: $bed_file.\n\n";
			}

			# Test to make sure that a name is defined in the fourth column. It
			# does not have to be unique.
			unless ($name) {
				croak "On line: $line_number you do not have anything in the "
				. "fourth column to designate an interval/peak name. Please " .
				"check your file: $bed_file or use the helper script to add a nominal " .
				"name in this column.\n\n";
			}

			# Test to make sure a score is defined in the fifth column and
			# that it is a numerical value 
			unless ($score && ($score >= 0 || $score <= 0)) {
				croak "On line: $line_number of your file: $bed_file you "
				. "do not have a score entered ".
				"for your peak/interval. If these intervals do not have " . 
				"scores associated with them, please use the helper script " .
				"to add a nominal score in the fifth column.\n\n" unless (
					$score == 0 );
			}

			unless ($strand eq '-' || $strand eq '+') {
				croak "On line: $line_number of your file: $bed_file," .
				" there is not a valid entry in the sixth column for the "
				. "strand. It should be either a '-' or a '+'\n\n";
			}

			# Test to make sure there are no other tab-delimited fields in the
			# file past the strand in the sixth column.
			if ($rest_of_line){
				croak "On line: $line_number, you have extra tab-" . 
				"delimited items after the sixth (strand) column. Please " .
				"use the helper script to trim these entries from your " .
				"file: $bed_file.\n\n";
			}

			$line_number++;
		}
	}
}

sub merge_files {
	my $self = shift;

	# Create a temporary file to store the merged BED-format files
	my $merged_ip_file = "$FindBin::Bin/../" . $self->name .
	'_merged_ip_file.bed';

	my $merged_input_file = "$FindBin::Bin/../" . $self->name .
	'_merged_input_file.bed';

	# Copy the input and IP files into strings
	my $unmerged_ip_file = $self->ip_file;
	my $unmerged_input_file = $self->input_file;

	# Run mergeBed to merge the overlapping read intervals and add the
	# scores together
	`mergeBed -n -i $unmerged_ip_file > $merged_ip_file`;
	`mergeBed -n -i $unmerged_input_file > $merged_input_file`;

	return ($merged_ip_file, $merged_input_file);
}

1;
