package PeaksToGenes::Contrast 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Contrast::GenomicRegions;
use PeaksToGenes::Contrast::Genes;
use PeaksToGenes::Contrast::Stats;
use PeaksToGenes::Contrast::ParseStats;
use PeaksToGenes::Contrast::Aggregate;
use PeaksToGenes::Contrast::Out;
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
	default		=>	1,
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
	my $genes;
	if ( $self->background_genes_fh ) {

		$genes = PeaksToGenes::Contrast::Genes->new(
			schema				=>	$self->schema,
			genome				=>	$self->genome,
			test_genes_fh		=>	$self->test_genes_fh,
			background_genes_fh	=>	$self->background_genes_fh,
		);
	} else {
		$genes = PeaksToGenes::Contrast::Genes->new(
			schema				=>	$self->schema,
			genome				=>	$self->genome,
			test_genes_fh		=>	$self->test_genes_fh,
		);
	}
	
	print "\n\nNow checking your lists of RefSeq accessions\n\n";
	my ($valid_test_genes, $invalid_test_genes, $valid_background_genes,
		$invalid_background_genes) = $genes->get_genes;

	print "\n\nThe following accessions in your test genes file were not" . 
	" found in the PeaksToGenes database for the genome specified: \n\t" ,
	join("\n\t", @$invalid_test_genes), "\n\n" if (@$invalid_test_genes);

	print "\n\nThe following accessions in your background genes file were not" . 
	" found in the PeaksToGenes database for the genome specified: \n\t" ,
	join("\n\t", @$background_test_genes), "\n\n" if (@$background_test_genes);

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
		genome				=>	$self->genome,
		processors			=>	$self->processors,
	);

	print "\n\nNow extracting genomic information\n\n";
	my $genomic_regions_structure =
	$genomic_regions->extract_genomic_regions;

	# Use the PeaksToGenes::Contrast::GenomicRegions::get_ordered_index
	# subroutine to extract an ordered Array Ref of genomic locations
	my $genomic_locations = $genomic_regions->get_ordered_index;

	# Pre-declare a Hash Ref to store the parsed results of any statistical
	# tests and of the aggregate tables
	my $parsed_array_refs = {};

	# If any statistical tests have been defined create an instance of
	# PeaksToGenes::Contrast::Stats, which is a sub-controller type module
	# to determine which statistical tests have been defined by the user
	# and will be run.
	if ( $self->statistical_tests ) {

		print "\n\nNow beginning to run statistical tests\n\n";

		my $stats = PeaksToGenes::Contrast::Stats->new(
			genomic_regions_structure	=>	$genomic_regions_structure,
			statistical_tests			=>	$self->statistical_tests,
			processors					=>	$self->processors,
		);

		my $statistical_results = $stats->run_statistical_tests;

		# Create an instance of PeaksToGenes::Contrast::ParseStats in order
		# to parse the results of the statistical tests using the
		# PeaksToGenes::Contrast::ParseStats::parse_stats subroutine
		my $parse_stats = PeaksToGenes::Contrast::ParseStats->new(
			stats_results	=>	$statistical_results,
			genomic_index	=>	$genomic_locations,
		);

		$parsed_array_refs = $parse_stats->parse_stats;

	}

	# Create a new instance of PeaksToGenes::Contrast::Aggregate to run the
	# PeaksToGenes::Contrast::Aggregate::create_table subroutine and return
	# an Array Ref tablet to be stored in the parsed_array_refs Hash Ref
	my $aggregate = PeaksToGenes::Contrast::Aggregate->new(
		genomic_regions_structure	=>	$genomic_regions_structure,
		genomic_index				=>	$genomic_locations,
	);

	print "\n\nParsing statistical results into tables\n\n";

	$parsed_array_refs->{aggregate} = $aggregate->create_table;

	# Create an instance of PeaksToGenes::Contrast::Out and run the
	# PeaksToGenes::Contrast::Out::print_tables function, to print the
	# tables to file based on the user-defined contrast_name
	my $out = PeaksToGenes::Contrast::Out->new(
		parsed_array_refs	=>	$parsed_array_refs,
		contrast_name		=>	$self->contrast_name,
	);

	print "\n\nPrinting statistical tables to files\n\n";

	$out->print_tables;
}

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
