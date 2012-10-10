#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 09-genomicregions.t
#
#  DESCRIPTION: This Perl test script is designed to test the function of
#  				PeaksToGenes::Contrast::GenomicRegions module.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/09/2012 10:50:47 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;
use PeaksToGenes::Update;
use PeaksToGenes::Annotate;
use PeaksToGenes::Contrast::Genes;
use PeaksToGenes::Contrast::GenomicRegions;

BEGIN {
#
#	# Call the external install_database.pl script to clear the database and
#	# index files before testing
#	`$FindBin::Bin/../install_database.pl`;
#
#	# Begin by creating PeaksToGenes and PeaksToGenes::Update objects to
#	# create a genomic index for hg18
	my $peaks_to_genes = PeaksToGenes->new(
		'genome'	=>	'hg18',
	);
#	my $update = PeaksToGenes::Update->new(
#		'genome'	=>	'hg18',
#		'schema'	=>	$peaks_to_genes->schema,
#	);
#	$update->update;
#
#	# Annotate ER binding sites from Carroll et al 2006
#	my $annotate = PeaksToGenes::Annotate->new(
#		schema		=>	$peaks_to_genes->schema,
#		genome		=>	'hg18',
#		name		=>	'brown_er',
#		summits		=>	't/ER_binding_neg_log_p_value.bed',
#	);
#	can_ok($annotate, 'annotate');
#	$annotate->annotate;

	# Create a new instance of PeaksToGenes::Contrast::Genes and test the
	# ability to return the correct Array Refs of gene ID lists, or invalid
	# RefSeq accessions
	my $genes = PeaksToGenes::Contrast::Genes->new(
		schema					=>	$peaks_to_genes->schema,
		genome					=>	'hg18',
		test_genes_fh			=>	't/0_to_12_Gene_List.txt',
	);
	my ($valid_test_ids, $invalid_test_accessions, $valid_background_ids,
		$invalid_background_accessions) = $genes->get_genes;
	isa_ok($valid_test_ids, 'ARRAY');
	isa_ok($invalid_test_accessions, 'ARRAY');
	cmp_ok(@$valid_test_ids, '==', 873, 
		'There are 873 valid IDs found');
	cmp_ok(@$invalid_test_accessions, '==', 28, 
		'There are 28 invalid accessions');
	isa_ok($valid_background_ids, 'ARRAY');
	cmp_ok(@$valid_background_ids, '==', 39489, 'The default ' .
		'background ID list has 39489 transcript IDs');
	isa_ok($invalid_background_accessions, 'ARRAY');
	cmp_ok(@$invalid_background_accessions, '==', 0,
		'There are no invalid accessions for the default background ' .
		'accessions list');

	# Create a new instance of PeaksToGenes::Contrast::GenomicRegions to
	# test the functions for retrieval of peaks per Kb and peak scores
	# based on the user-defined test and background lists
	my $genomic_regions = PeaksToGenes::Contrast::GenomicRegions->new(
		schema				=>	$peaks_to_genes->schema,
		name				=>	'brown_er',
		test_genes			=>	$valid_test_ids,
		background_genes	=>	$valid_background_ids,
	);
	isa_ok($genomic_regions, 'PeaksToGenes::Contrast::GenomicRegions');

}

done_testing;
