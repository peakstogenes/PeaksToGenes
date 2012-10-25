package PeaksToGenes::Contrast 0.001;
use Moose;
use Carp;
use PeaksToGenes::Contrast::GenomicRegions;
use PeaksToGenes::Contrast::Stats;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Contrast  

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is called by the main PeaksToGenes module and provides
the busniess logic to extract aggregate peaks information based on
a user-defined list of RefSeq accessions and a user-defined set of
indexed peaks. This module will tell the user about any accessions
in their list that are not found in the database, and will not run
if the user has not chosen a valid name for a set of indexed peaks.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::FileStructure class.

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

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has test_genes_fh	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
);

has background_genes_fh	=>	(
	is					=>	'ro',
	isa					=>	'Str',
);

has contrast_name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has statistical_tests	=>	(
	is				=>	'ro',
	isa				=>	'HashRef[Bool]',
	required		=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	sub {
		my $self = shift;
		return 1;
	}
);

=head1 SUBROUTINES/METHODS

=head2 test_and_contrast

This subroutine is called by the main PeaksToGenes class.

First, this subroutine ensures that the database contains
the set of indexed peaks defined by the user. If it does
not, the program dies and tell the user that the peaks
they are looking for are not in the database.

Second, this subroutine checks each RefSeq accession given
by the user to ensure that the given accession is indexed in
the user-defined database. Each invalid accession is returned
to the user in an error message at the end of the program's
execution.

Finally, while iterating through and testing the possible
RefSeq accessions, this program creates an aggregate of the
number of peaks in each relative location for the subset of
user-defined accessions. This is returned to the PeaksToGenes
main module in the form of an Array Ref.

=cut

sub test_and_contrast {
	my $self = shift;

	# Create an instance of PeaksToGenes::Contrast::Genes and run
	# PeaksToGenes::Contrast::Genes::extract_genes to return Array Refs of
	# valid test genes, invalid test genes, valid background genes, and
	# invalid background genes.
	my $genes = PeaksToGenes::Contrast::Genes->new(
		schema				=>	$self->schema,
		genome				=>	$self->genome,
		test_genes_fh		=>	$self->test_genes_fh,
		background_genes_fh	=>	$self->background_genes_fh,
	);
	my ($valid_test_genes, $invalid_test_genes, $valid_background_genes,
		$invalid_background_genes) = $genes->extract_genes;

	# Create an instance of PeaksToGenes::Contrast::GenomicRegions and run
	# PeaksToGenes::Contrast::GenomicRegions::extract_genomic_regions to
	# return a Hash Ref containing two Hash Refs (one for the test and one
	# for the background) each of which will contain two Array Refs for
	# each genomic region (one for the peaks per Kb, and one for the peak
	# scores).
	my $genomic_regions = PeaksToGenes::Contrast::GenomicRegions->new(
		schema				=>	$self->schema,
		name				=>	$self->name,
		test_genes			=>	$valid_test_genes,
		background_genes	=>	$valid_background_genes,
	);
	my $genomic_regions_structure =
	$genomic_regions->extract_genomic_regions;

	# Create an instance of PeaksToGenes::Contrast::Stats, which is a
	# sub-controller type module to determine which statistical tests have
	# been defined by the user and will be run.
	my $stats = PeaksToGenes::Contrast::Stats->new(
		genomic_regions_structure	=>	$genomic_regions_structure,
		statistical_tests			=>	$self->statistical_tests,
	);
}


#	# Pre-define a Hash Ref to hold the aggregate peak numbers
#	my $aggregate_peak_numbers = {
#		$self->genome . "_5Prime_UTR_Number_of_Peaks" => 0,
#		$self->genome . "_Exons_Number_of_Peaks" => 0,
#		$self->genome . "_Introns_Number_of_Peaks" => 0,
#		$self->genome . "_3Prime_UTR_Number_of_Peaks" => 0,
#	};
#	# Iterate through the relative locations and pre-define the
#	# values to zero
#	for ( my $i = 1; $i <= 100; $i++ ) {
#		$aggregate_peak_numbers->{$self->genome . '_' . $i . 'Kb_Downstream_Number_of_Peaks'} = 0;
#		$aggregate_peak_numbers->{$self->genome . '_' . $i . 'Kb_Upstream_Number_of_Peaks'} = 0;
#	}
#	# Pre-declare an Array Ref to hold the invalid RefSeq accesions
#	my $invalid_accessions = [];
#	# Determine if the user-defined experiment name is defined
#	# in the database
#	my $indexed_peaks_result_set = $self->schema->resultset('Annotatedpeak');
#	my $indexed_peaks_search_results = $indexed_peaks_result_set->search(
#		{
#			name	=>	$self->name
#		}
#	);
#	# Store all of the search results for the user-defined name in an Array
#	my @all_indexed_peaks = $indexed_peaks_search_results->all;
#	# If the array has results, open the user-defined file and create a Hash
#	# Ref with the keys being the potential RefSeq accessions
#	# Pre-declare two HashRefs, one for accessions given by the user, and one
#	# for all accessions found in the indexed peaks database. These will be used
#	# later to determine if any of the accessions entered by the user are invalid.
#	my $user_defined_accessions = {};
#	my $peaks_to_genes_accessions = {};
#	if ( @all_indexed_peaks ) {
#		open my $genes_file, "<", $self->genes or die "Could not read from the file " . $self->genes . ", please check that you have entered the path to the file correctly, and that the permissions of this file are readable by you.\n";
#		while (<$genes_file>) {
#			my $line = $_;
#			chomp($line);
#			if ( $line =~ /^(.+?)\.\d+$/ ) {
#				$user_defined_accessions->{$1} = 1;
#			} else {
#				$user_defined_accessions->{$line} = 1;
#			}
#		}
#		# Iterate through the search results returned that match the user-defined
#		# experiment name. At each line, add the accession to the peaks to genes 
#		# accessions Hash Ref. If the accession in a search result line matches a
#		# user-defined accession, add the number of peaks per relative region
#		# value to the Hash Ref of aggregate values.
#		foreach my $indexed_peaks ( @all_indexed_peaks ) {
#			$peaks_to_genes_accessions->{$indexed_peaks->gene} = 1;
#			if ( $user_defined_accessions->{$indexed_peaks->gene} ) {
#				$aggregate_peak_numbers->{$self->genome . "_5Prime_UTR_Number_of_Peaks"} += $indexed_peaks->_5prime_utr_number_of_peaks;
#				$aggregate_peak_numbers->{$self->genome . "_Exons_Number_of_Peaks"} += $indexed_peaks->_exons_number_of_peaks;
#				$aggregate_peak_numbers->{$self->genome . "_Introns_Number_of_Peaks"} += $indexed_peaks->_introns_number_of_peaks;
#				$aggregate_peak_numbers->{$self->genome . "_3Prime_UTR_Number_of_Peaks"} += $indexed_peaks->_3prime_utr_number_of_peaks;
#				# Iterate through the relative locations
#				for ( my $i = 1; $i <= 100; $i++ ) {
#					my $upsteam_location_string = '_' . $i . 'kb_upstream_number_of_peaks';
#					my $downsteam_location_string = '_' . $i . 'kb_downstream_number_of_peaks';
#					$aggregate_peak_numbers->{$self->genome . '_' . $i . 'Kb_Upstream_Number_of_Peaks'} += $indexed_peaks->$upsteam_location_string;
#					$aggregate_peak_numbers->{$self->genome . '_' . $i . 'Kb_Downstream_Number_of_Peaks'} += $indexed_peaks->$downsteam_location_string;
#				}
#			}
#		}
#		# Iterate through the user-defined accessions. If any of them are not defined
#		# in the peaks to genes accessions Hash Ref, add them to the invalid accessions
#		# Array Ref
#		foreach my $accession (keys %$user_defined_accessions) {
#			unless ( $peaks_to_genes_accessions->{$accession} ) {
#				push (@$invalid_accessions, $accession);
#			}
#		}
#		# If the number of invalid accessions is the same number as the number of accessions
#		# defined by the user, die and throw an error
#		if ( scalar keys %$user_defined_accessions == @$invalid_accessions ) {
#			die "None of the accessions entered in your text file are valid accessions for the " . $self->name . " experiment.\nPlease check your file and try again.\n";
#		}
#	# Else, throw an error telling the user that the name they have entered
#	# is not defined in their database
#	} else {
#		die "The experiment name " . $self->name . ", is not defined in your PeaksToGenes database. Please check that you have entered the name correctly.\n";
#	}
#	# Pre-declare an Array Ref to hold the results of the contrast test
#	my $contrast_array = [];
#	# Pre-define an Array Ref to hold the header line
#	my $header_line = [
#		$self->genome . "_5Prime_UTR_Number_of_Peaks",
#		$self->genome . "_Exons_Number_of_Peaks",
#		$self->genome . "_Introns_Number_of_Peaks",
#		$self->genome . "_3Prime_UTR_Number_of_Peaks",
#	];
#	# Add to the header line by iterating through the relative locations
#	for ( my $i = 1; $i <= 100; $i++ ) {
#		unshift ( @$header_line, $self->genome . '_' . $i . 'Kb_Upstream_Number_of_Peaks' );
#		push ( @$header_line, $self->genome . '_' . $i . 'Kb_Downstream_Number_of_Peaks' );
#	}
#	# Push the header line at the contrast array
#	push(@$contrast_array, join("\t", @$header_line));
#	# Pre-declare an Array Ref to hold the data
#	my $data_line = [];
#	# Iterate through the aggregate peaks numbers and create an Array Ref
#	foreach my $location (@$header_line) {
#		push(@$data_line, $aggregate_peak_numbers->{$location});
#	}
#	# Push the data line onto the contrast array
#	push(@$contrast_array, join("\t", @$data_line));
#	# Print the contrast test to file
#	open my $out_fh, ">", $self->name . "_Contrasted_By_" . $self->contrast_name . ".txt" or die "Could not write to " . $self->name . "_Contrasted_By_" . $self->contrast_name . ".txt Please check that you have permissions to write to this file or that it is a valid file-name\n";
#	print $out_fh join("\n", @$contrast_array);
#	return ($invalid_accessions);
#}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Contrast


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


1; # End of PeaksToGenes::Contrast
