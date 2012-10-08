package PeaksToGenes::Annotate::BedTools 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Update::UCSC;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Annotate::BedTools

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module provides most of the business logic for the PeaksToGenes
program. Given a bed file of peak summits, and a list of index files,
this module will annotate the locations of the summits relative to
the transcriptional start site of each transcript.

=head1 SUBROUTINES/METHODS

=head2 Moose declarations

This section contains objects that are added to an instance of
PeaksToGenes::Annotate::BedTools.

=cut

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has index_files	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[Str]',
	required	=>	1,
);

has summits	=>	(
	is			=>	'ro',
	isa			=>	'Str',
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

=head2 annotate_peaks

This subroutine is passed the file name of a bed file of summits,
and array reference of index files and makes backticks calls to the
executable intersectBed utility from the BedTools suite of programs.
annotate peaks returns an array reference of hash references for each
transcript.

=cut

sub annotate_peaks {
	my $self = shift;

	# Run the PeaksToGenes::Annotate::BedTools::check_bed_file subroutine
	# to be sure that the user-defined BED-format file is correctly
	# formatted.
	$self->check_bed_file;

	# Make a call to align_peaks to determine to overlap of peaks relative
	# to RefSeq gene positions
	my $indexed_peaks = $self->align_peaks;

	# Return the indexed_peaks Hash Ref to the PeaksToGenes::Annotate
	# controller module.
	return $indexed_peaks;
}

=head2 check_bed_file

This subroutine determines if the user-defined BED file is valid for
the genome defined by the user.

=cut

sub check_bed_file {
	my $self = shift;

	# Create an instance of PeaksToGenes::Update::UCSC
	my $ucsc = PeaksToGenes::Update::UCSC->new(
		genome	=>	$self->genome,
	);

	# Get the chromosome sizes from the UCSC MySQL Tables
	my $chromosome_sizes = $ucsc->chromosome_sizes;

	# Pre-declare a line number to return useful errors to the user
	my $line_number = 1;

	# Open the user-defined file, iterate through and parse the lines. Any
	# errors found will cause an immediate termination of the script and
	# return an error message to the user.
	open my $summits_fh, "<", $self->summits or croak 
	"Could not read from BED file: " . $self->summits . 
	". Please check the permissions on this file. $!\n\n";
	while (<$summits_fh>) {
		my $line = $_;
		chomp ($line);
		# Split the line by tab characters
		my ($chr, $start, $stop, $name, $score, $rest_of_line) =
		split(/\t/, $line);

		# Test to make sure the chromosome defined in column 1 is a valid
		# chromosome for the user-defined genome
		unless ( $chromosome_sizes->{$chr} ) {
			croak "On line: $line_number the chromosome: " . $chr . 
			" is not defined in the user-defined genome: " . 
			$self->genome . 
			". Please check your file and the genome you would like to " .
			"use.\n\n";
		}

		# Test to make sure that the values in for the interval start in
		# column 2 and the interval end in column 3 are integers
		unless ( $start =~ /^\d+$/ ) {
			croak "On line: $line_number the interval start defined: " .
			$start . " is not an integer. Please check your file.\n\n";
		}
		unless ( $stop =~ /^\d+$/ ) {
			croak "On line: $line_number the interval stop defined: " .
			$stop . " is not an integer. Please check your file.\n\n";
		}

		# Test to make sure the integer value defined for the interval end
		# in column three is greater than the interval value defined for
		# the interval start in column two
		unless ( $stop > $start ) {
			croak "On line: $line_number the stop: $stop is not larger " .
			"than the start: $start. Please check your file.\n\n";
		}

		# Test to make sure that the integer values defined for the
		# interval start in column two and the interval end in column three
		# are valid coordinates based on the length of the chromosome
		# defined in column one for the user-defined genome
		unless (($start < $chromosome_sizes->{$chr}) && 
			($stop < $chromosome_sizes->{$chr})) {
			croak "On line: $line_number the coordinates are not valid " .
			"for the user-defined genome: " . $self->genome 
			. ". Please check your file.\n\n";
		}

		# Test to make sure that a name is defined in the fourth column. It
		# does not have to be unique.
		unless ($name) {
			croak "On line: $line_number you do not have anything in the "
			. "fourth column to designate an interval/peak name. Please " .
			"check your file or use the helper script to add a nominal " .
			"name in this column.\n\n";
		}

		# Test to make sure a score is defined in the fifth column and
		# that it is a numerical value 
		unless ($score && ($score >= 0 || $score <= 0)) {
			croak "On line: $line_number you do not have a score entered ".
			"for your peak/interval. If these intervals do not have " . 
			"scores associated with them, please use the helper script " .
			"to add a nominal score in the fifth column.\n\n";
		}

		# Test to make sure there are no other tab-delimited fields in the
		# file past the score in the fifth column.
		if ($rest_of_line){
			croak "On line: $line_number, you have extra tab-" . 
			"delimited items after the fifth (score) column. Please " .
			"use the helper script to trim these entries from your " .
			"file.\n\n";
		}

		$line_number++;
	}
}

sub align_peaks {
	my $self = shift;

	# Copy the base regular expression into a scalar string.
	my $base_regex = $self->base_regex;

	# Copy the file string for the experimental intervals into a scalar
	# string
	my $summits_file = $self->summits;

	# Pre-declare a Hash Ref to hold the intersected peaks information
	my $indexed_peaks = {};

	# Iterate through the ordered index, and intersect the Summits file
	# with the index file. Extract the information from any intersections
	# that occur and store them in the indexed_peaks Hash Ref.
	foreach my $index_file (@{$self->index_files}) {

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
			my $peak_info = $location . '_Peaks_Information';
			my $interval_size = $location . '_Interval_Size';

			# Make a back ticks call to intersectBed with the -wo option so
			# that the original entry for both the experimental intervals
			# and the genomic intervals are returned for each instance
			# where the experimental interval overlaps a genomic interval.
			# The intersected interval lines will be stored in an array.
			my @intersected_peaks = 
			`intersectBed -wo -a $summits_file -b $index_file`;

			# Parse the information, and store it in the Hash Ref
			foreach my $intersected_peak (@intersected_peaks) {
				chomp ($intersected_peak);

				# Split the fields by the tab-delimiter. Because of the
				# nature of the method here, the input file must be
				# correctly formatted.
				my ($summit_chr, $summit_start, $summit_end, $summit_name,
					$summit_score, $index_chr, $index_start, $index_stop,
					$index_gene, $overlap) = split(/\t/,
					$intersected_peak);

				# If an experimental interval has been found for this
				# genomic interval, add to the number. If not, set the
				# number to 1.
				if ($indexed_peaks->{$index_gene}{$peak_number} ) {
					$indexed_peaks->{$index_gene}{$peak_number}++;
				} else {
					$indexed_peaks->{$index_gene}{$peak_number} = 1;
				}

				# If an experimental interval has been found for this
				# genomic interval, add to the string. If not, set the
				# string equal to the experimental information
				if ( $indexed_peaks->{$index_gene}{$peak_info} ) {
					$indexed_peaks->{$index_gene}{$peak_info} .= 
					' /// ' . join(":", $summit_chr, $summit_start,
						$summit_end, $summit_name, $summit_score) . 
					' /// ';
				} else {
					$indexed_peaks->{$index_gene}{$peak_info} = 
					' /// ' . join(":", $summit_chr, $summit_start,
						$summit_end, $summit_name, $summit_score) . 
					' /// ';
				}

				# If an experimental interval has been found for this
				# genomic interval, add to the length of the interval
				# (really only used in the case of introns and exons.
				# If not, set the string equal to the length of the
				# genomic interval.
				if ( $indexed_peaks->{$index_gene}{$interval_size} ) {
					$indexed_peaks->{$index_gene}{$interval_size} +=
					($index_stop - $index_start + 1);
				} else {
					$indexed_peaks->{$index_gene}{$interval_size}
					= ($index_stop - $index_start + 1);
				}
			}
		} else {
			croak "There was a problem determining the location of the " .
			"index file relative to transcription start site";
		}
	}

	# Return the Hash Ref of experimental intervals annotated based on
	# location relative to RefSeq transcripts to the main subroutine.
	return $indexed_peaks;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Annotate::BedTools


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PeaksToGenes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PeaksToGenes>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PeaksToGenes>

=item * Search CPAN

L<http://search.cpan.org/dist/PeaksToGenes/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jason R. Dobson.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of PeaksToGenes::Annotate::BedTools
