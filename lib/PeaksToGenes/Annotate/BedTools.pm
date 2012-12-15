package PeaksToGenes::Annotate::BedTools 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Update::UCSC;
use Parallel::ForkManager;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Annotate::BedTools

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module provides most of the business logic for the PeaksToGenes
program. Given a bed file of genomic intervals, and a list of index files,
this module will annotate the locations of the peaks relative to the
transcriptional start site of each transcript.

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
);

has bed_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
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

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	1,
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

	# Run the PeaksToGenes::Annotate::BedTools::merge_bed subroutine to
	# merge any overlapping intervals into a temporary BED-format file for
	# faster indexed with intersectBed
	my $merged_bed_file = $self->merge_bed;

	# Make a call to align_peaks to determine to overlap of peaks relative
	# to RefSeq gene positions
	my $indexed_peaks = $self->align_peaks($merged_bed_file);

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

	# Fetch the chromosome sizes from the database by calling
	# PeaksToGenes::Annotate::BedTools::chromosome_sizes
	my $chromosome_sizes = $self->chromosome_sizes;

	# Pre-declare a line number to return useful errors to the user
	my $line_number = 1;

	# Open the user-defined file, iterate through and parse the lines. Any
	# errors found will cause an immediate termination of the script and
	# return an error message to the user.
	open my $summits_fh, "<", $self->bed_file or croak 
	"Could not read from BED file: " . $self->bed_file . 
	". Please check the permissions on this file. $!\n\n";
	while (<$summits_fh>) {
		my $line = $_;
		chomp ($line);
		# Split the line by tab characters
		my ($chr, $start, $stop, $name, $rest_of_line) =
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
		unless (($start <= $chromosome_sizes->{$chr}) && 
			($stop <= $chromosome_sizes->{$chr})) {
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

		$line_number++;
	}
}

sub merge_bed {
	my $self = shift;

	# Define a string to hold the temporary peaks file
	my $merged_peaks_fh = "$FindBin::Bin/../temp_merged.bed";

	# Copy the BED-format file into a scalar string
	my $unmerged_peaks_file = $self->bed_file;

	# Run mergeBed to merge the overlapping peak intervals
	`mergeBed -n -i $unmerged_peaks_file > $merged_peaks_fh`;

	# Return the file name to the main subroutine
	return $merged_peaks_fh;
}

sub chromosome_sizes {
	my $self = shift;

	# Create an instance of PeaksToGenes::Update::UCSC and run the
	# PeaksToGenes::Update::UCSC::genome_info subroutine to make sure that
	# the user-define genome string is a valid RefSeq genome
	my $ucsc = PeaksToGenes::Update::UCSC->new(
		genome	=>	$self->genome,
	);
	unless ( $ucsc->genome_info->{$self->genome} ) {
		croak "\n\nThe genome you have entered: " .
		$self->genome . " is not a valid RefSeq annotated genome. Please check and make sure you have entered the correct genome\n\n";
	}

	# Fetch the genome_id for the user-defined genome
	my $genome_search = $self->schema->resultset('AvailableGenome')->find(
		{
			genome	=>	$self->genome
		}
	);

	# Pre-declare a scalar to hold the genome ID if it has been found in
	# the PeaksToGenes database
	my $genome_id;
	if ( $genome_search ) {
		$genome_id = $genome_search->id;
	} else {
		croak "\n\nThe genome: " . $self->genome . 
		" has not been installed in the PeaksToGenes database. Please use Update Mode to install this genome.\n\n";
	}

	# Using the genome_id, fetch the file string for the chromosome sizes
	# file corresponding to the user-defined genome
	my $chromosome_sizes_fh =
	$self->schema->resultset('ChromosomeSize')->find(
		{
			genome_id	=>	$genome_id,
		}
	)->chromosome_sizes_file;

	# Pre-declare a Hash Ref to store the chromosome sizes information
	my $chromosome_sizes = {};

	# Open the chromosome sizes file, iterate through the lines, parse the
	# data and store it in the Hash Ref
	open my $chromosome_sizes_file, "<", $chromosome_sizes_fh or croak 
	"Could not read from the chromosome sizes file: $chromosome_sizes_fh $!\n";
	while (<$chromosome_sizes_file>) {
		my $line = $_;
		chomp($line);
		my ($chr, $length) = split(/\t/, $line);
		$chromosome_sizes->{$chr} = $length;
	}
	return $chromosome_sizes;
}

sub align_peaks {
	my ($self, $summits_file) = @_;

	# Copy the base regular expression into a scalar string.
	my $base_regex = $self->base_regex;

	# Pre-declare a Hash Ref to hold the intersected peaks information
	my $indexed_peaks = {};

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

			foreach my $index_gene ( keys
				%{$data_structure->{intersected_peaks}} ) {
				$indexed_peaks->{$index_gene}{$peak_number} =
				$data_structure->{intersected_peaks}{$index_gene};
			}
		}
	);


	# Iterate through the ordered index, and intersect the Summits file
	# with the index file. Extract the information from any intersections
	# that occur and store them in the indexed_peaks Hash Ref.
	foreach my $index_file (@{$self->index_files}) {

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

			# Make a back ticks call to intersectBed with the -wo option so
			# that the original entry for both the experimental intervals
			# and the genomic intervals are returned for each instance
			# where the experimental interval overlaps a genomic interval.
			# The intersected interval lines will be stored in an array.
			my @intersected_peaks = 
			`intersectBed -wo -a $index_file -b $summits_file`;

			# Pre-declare a Hash Ref to hold the information for the peaks
			my $peaks_hash_ref = {};

			# Iterate through the intersected lines and parse the
			# information, storing it in the peaks_hash_ref
			foreach my $intersected_line ( @intersected_peaks ) {

				chomp($intersected_line);

				# Split the line by tab
				my ($index_chr, $index_start, $index_stop, $index_gene,
					$peaks_chr, $peaks_start, $peaks_stop,
					$number_of_peaks, $overlap) = split(/\t/, $intersected_line);

				# Calculate the size of the index interval
				my $interval_size = $index_stop - $index_start + 1;

				# Add the normalized (per Kb) number of peaks found to the
				# peaks_hash_ref
				if ( $peaks_hash_ref->{$index_gene} ) {
					$peaks_hash_ref->{$index_gene} += ( $number_of_peaks *
						(1000/$interval_size)
					);
				} else {
					$peaks_hash_ref->{$index_gene} = ( $number_of_peaks *
						(1000/$interval_size)
					);
				}

			}

			$pm->finish(0, 
				{
					intersected_peaks	=>	$peaks_hash_ref,
					peak_number			=>	$peak_number,
				}
			);

		
		} else {
			croak "There was a problem determining the location of the " .
			"index file relative to transcription start site";
		}
	}

	$pm->wait_all_children;

	# Remove the temporary merged BED-format file
	unlink $summits_file;

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
