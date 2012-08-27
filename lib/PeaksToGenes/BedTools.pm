package PeaksToGenes::BedTools 0.001;
use Moose;
use Carp;
use PeaksToGenes::Update::UCSC;
use Data::Dumper;

=head1 NAME

PeaksToGenes::BedTools

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

This section contains objects that are added to an instance of PeaksToGenes::BedTools

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

=head2 annotate_peaks

This subroutine is passed the file name of a bed file of summits,
and array reference of index files and makes backticks calls to the
executable intersectBed utility from the BedTools suite of programs.
annotate peaks returns an array reference of hash references for each
transcript.

=cut

sub annotate_peaks {
	my $self = shift;
	my $summits_file = $self->summits;
	my $index_files = $self->index_files;
	# Create a regular expression string to be used to match the location of each
	# index file
	my $base_regex = "\.\.\/" . $self->genome . "_Index\/" . $self->genome;
	# Make a call to the private _create_blank index to make a blank genome-defined
	# peaks to genes structures
	my $indexed_peaks = $self->_create_blank_index($index_files, $base_regex);
	print "Now aligning your peaks to:\n\n";
	# Iterate through the ordered index, and interset the Summits file with the index
	# file. Extract the information from any intersections that occur and store them
	# in the indexed_peaks Hash Ref
	foreach my $index_file (@$index_files) {
		# Pre-declare a string to hold the genomic location of each index file
		my $location = '';
		if ($index_file =~ qr/($base_regex)(.+?)\.bed$/ ) {
			$location = $2;
		}
		# If the location string has been found, intersect the location file with the
		# summits file
		if ($location) {
			print "\t" . $self->genome . "$location\n";
			my $peak_number = $location . '_Number_of_Peaks';
			my $peak_info = $location . '_Peaks_Information';
			my @intersected_peaks = `intersectBed -wb -a $summits_file -b $index_file`;
			foreach my $intersected_peak (@intersected_peaks) {
				chomp ($intersected_peak);
				my ($summit_chr, $summit_start, $summit_end, $summit_name, $summit_score,
					$index_chr, $index_start, $index_stop, $index_gene, $index_score,
					$index_strand) = split(/\t/, $intersected_peak);
				$indexed_peaks->{$index_gene}{$peak_number}++;
				$indexed_peaks->{$index_gene}{$peak_info} .= ' /// ' . join(":", $summit_chr, $summit_start, $summit_start, $summit_name) . ' /// ';
			}
		} else {
			croak "There was a problem determining the location of the index file relative to transcription start site";
		}
	}
	print "\n";
	return $indexed_peaks;
}

=head2 _create_blank_index

This is a private subroutine called by annotate_peaks to create a blank
user-defined index where information will be stored

=cut

sub _create_blank_index {
	my ($self, $index_files, $base_regex) = @_;
	# Pre-declare a Hash-ref to be defined by the indexed files
	my $indexed_peaks = {};
	# Pre-declcare an Array Ref to hold the list of RefSeq accession
	my $genes = [];
	# Iterate through the index files to find the promoters file, once
	# found open the promoter file and extract the RefSeq accessions,
	# pushing each one onto the genes Array Ref
	foreach my $index_file (@$index_files) {
		if ($index_file =~ /Promoters/) {
			open my($promoters), "<", $index_file or croak "Could not open $index_file $! \n";
			while (<$promoters>) {
				my $line = $_;
				chomp ($line);
				my ($chr, $start, $stop, $name, $rest_of_line) = split(/\t/, $line);
				push (@$genes, $name);
			}
		}
	}
	# Iterate through the index files, extract the base name
	# and create a key value for both the number of peaks
	# and for the peaks information at each location for each
	# RefSeq Accession
	foreach my $index_file (@$index_files) {
		foreach my $gene (@$genes) {
			# Pre-declare a string to hold the index base
			my $index_base = '';
			if ($index_file =~ qr/($base_regex)(.+?)\.bed$/ ) {
				$index_base = $2;
			}
			# If the index base has been defined, place empty values
			# at each genome-defined position
			if ( $index_base ) {
				my $peak_numbers = $index_base . '_Number_of_Peaks';
				$indexed_peaks->{$gene}{$peak_numbers} = 0;
				my $peak_info = $index_base . '_Peaks_Information';
				$indexed_peaks->{$gene}{$peak_info} = '';
			}
		}
	}
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
	open my $summits_fh, "<", $self->summits or die "Could not read from BED file: " . $self->summits . ". Please check the permissions on this file. $!\n\n";
	while (<$summits_fh>) {
		my $line = $_;
		chomp ($line);
		# Split the line by tab characters
		my ($chr, $start, $stop, $name, $score, $rest_of_line) = split(/\t/, $line);
		unless ( $chromosome_sizes->{$chr} ) {
			die "On line: $line_number the chromosome: $chr is not defined in the user-defined genome: " . $self->genome . ". Please check your file and the genome you would like to use.\n\n";
		}
		unless ( $stop > $start ) {
			die "On line: $line_number the stop: $stop is not larger than the start: $start. Please check your file.\n\n";
		}
		unless (($start < $chromosome_sizes->{$chr}) && ($stop < $chromosome_sizes->{$chr})) {
			die "On line: $line_number the coordinates are not valid for the user-defined genome: " . $self->genome . ". Please check your file.\n\n";
		}
		unless ($name) {
			die "On line: $line_number you do not have anything in the fourth column to designate an interval/peak name. Please check your file.\n\n";
		}
		unless ($score > 0) {
			die "On line: $line_number you do not have a score entered for your peak/interval. If these intervals do not have scores associated with them, please use the helper script to add a nominal score in the fifth column.\n\n";
		}
		if ($rest_of_line){
				die "On line: $line_number, you have extra tab-delimited items after the fifth (score) column. Please use the helper script to trim these entries from your file.\n\n";
		}
		$line_number++;
	}
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::BedTools


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

1; # End of PeaksToGenes::BedTools
