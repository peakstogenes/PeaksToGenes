#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 11-wilcoxon.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions of
#  				the PeaksToGenes::Contrast::Stats::Wilcoxon module.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/11/2012 05:28:50 PM
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
use PeaksToGenes::Contrast::Stats::RankOrder;
use PeaksToGenes::Contrast::Stats::Wilcoxon;
use Data::Dumper;

BEGIN {

#	# Call the external install_database.pl script to clear the database and
#	# index files before testing
#	`$FindBin::Bin/../install_database.pl`;

	# Begin by creating PeaksToGenes and PeaksToGenes::Update objects to
	# create a genomic index for hg18
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
		background_genes_fh		=>	't/0_to_3_Gene_List.txt',
	);
	my ($valid_test_ids, $invalid_test_accessions, $valid_background_ids,
		$invalid_background_accessions) = $genes->get_genes;

	# Create a new instance of PeaksToGenes::Contrast::GenomicRegions to
	# test the functions for retrieval of peaks per Kb and peak scores
	# based on the user-defined test and background lists
	my $genomic_regions = PeaksToGenes::Contrast::GenomicRegions->new(
		schema				=>	$peaks_to_genes->schema,
		name				=>	'brown_er',
		test_genes			=>	$valid_test_ids,
		background_genes	=>	$valid_background_ids,
		processors			=>	8,
	);
	isa_ok($genomic_regions, 'PeaksToGenes::Contrast::GenomicRegions');
	can_ok($genomic_regions, 'extract_genomic_regions');
	my $genomic_regions_structure =
	$genomic_regions->extract_genomic_regions;

	# Create a new instance of PeaksToGenes::Contrast::Stats::RankOrder and
	# test the
	# PeaksToGenes::Contrast::Stats::RankOrder::rank_order_genomic_regions
	# subroutine to make sure that it correctly runs the test and returns
	# the correct values
	my $rank_order = PeaksToGenes::Contrast::Stats::RankOrder->new(
		genomic_regions_structure	=>	$genomic_regions_structure,
		processors					=>	8,
	);
	isa_ok($rank_order, 'PeaksToGenes::Contrast::Stats::RankOrder');
	can_ok($rank_order, 'rank_order_genomic_regions');
	my $rank_ordered_genomic_regions =
	$rank_order->rank_order_genomic_regions;

	# Create an instance of PeaksToGenes::Contrast::Stats::Wilcoxon and
	# make sure that it can properly execute the
	# PeaksToGenes::Contrast::Stats::Wilcoxon::rank_sum test subroutine and
	# return a Hash Ref containing the Wilcoxon Rank Sum test results for
	# each relative genomic interval and data type
	my $wilcoxon = PeaksToGenes::Contrast::Stats::Wilcoxon->new(
		rank_ordered_genomic_regions	=>	$rank_ordered_genomic_regions,
		processors						=>	8,
	);
	isa_ok($wilcoxon, 'PeaksToGenes::Contrast::Stats::Wilcoxon');
	can_ok($wilcoxon, 'rank_sum_test');
	my $test_results = $wilcoxon->rank_sum_test;
	print Dumper $test_results;



#	# Call the external install_database.pl script to clear the database and
#	# index files after testing
#	`$FindBin::Bin/../install_database.pl`;
}


done_testing;
