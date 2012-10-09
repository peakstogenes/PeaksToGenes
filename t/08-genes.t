#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 08-genes.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions of
#  				the PeaksToGenes::Contrast::Genes model module
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/09/2012 11:29:20 AM
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

BEGIN {

	# Call the external install_database.pl script to clear the database and
	# index files before testing
	`$FindBin::Bin/../install_database.pl`;

	# Begin by creating PeaksToGenes and PeaksToGenes::Update objects to
	# create a genomic index for hg18
	my $peaks_to_genes = PeaksToGenes->new(
		'genome'	=>	'hg18',
	);
	my $update = PeaksToGenes::Update->new(
		'genome'	=>	'hg18',
		'schema'	=>	$peaks_to_genes->schema,
	);
	$update->update;

	# Annotate ER binding sites from Carroll et al 2006
	my $annotate = PeaksToGenes::Annotate->new(
		schema		=>	$peaks_to_genes->schema,
		genome		=>	'hg18',
		name		=>	'brown_er',
		summits		=>	't/ER_binding_neg_log_p_value.bed',
	);
	can_ok($annotate, 'annotate');
	$annotate->annotate;

	# Create a new instance of PeaksToGenes::Contrast::Genes and test the
	# ability to return the correct Array Refs of gene ID lists, or invalid
	# RefSeq accessions
	my $genes = PeaksToGenes::Contrast::Genes->new(
		schema					=>	$peaks_to_genes->schema,
		genome					=>	'hg18',
		test_genes_fh			=>	't/0_to_12_Gene_List.txt',
	);
	isa_ok($genes, 'PeaksToGenes::Contrast::Genes');

	# Test the PeaksToGenes::Contrast::Genes::all_genes function to make
	# sure that it returns a DBIx::Class::ResultSet
	can_ok($genes, 'all_genes');
	my $all_genes_result_set = $genes->all_genes;
	isa_ok($all_genes_result_set, 'DBIx::Class::ResultSet');
	my $number = 1;
	while ( $all_genes_result_set->next ) {
		$number++;
	}
	$all_genes_result_set->reset;
	cmp_ok($number, '==', 40362, 'There are 40362 genes in the hg18 ' . 
		'RefSeq genome');

	# Test the PeaksToGenes::Contrast::Genes::extract_genes function to
	# make sure that it returns an Array Ref of valid IDs and an Array Ref
	# of invalid accessions
	can_ok($genes, 'extract_genes');
	my ($valid_test_ids, $invalid_test_ids) =
	$genes->extract_genes($genes->test_genes_fh, $all_genes_result_set);
	isa_ok($valid_test_ids, 'ARRAY');
	isa_ok($invalid_test_ids, 'ARRAY');
	cmp_ok(@$valid_test_ids, '==', 873, 'There are 873 valid IDs found');
	cmp_ok(@$invalid_test_ids, '==', 28, 'There are 28 invalid accessions');

	# Test the PeaksToGenes::Contrast::Genes::default_background function
	# to make sure that it returns an Array Ref of valid IDs that is the
	# mirror of the list defined in the list of valid test IDs
	can_ok($genes, 'default_background');
	my $valid_background_ids = $genes->default_background($valid_test_ids,
		$all_genes_result_set);
	isa_ok($valid_background_ids, 'ARRAY');
	cmp_ok(@$valid_background_ids, '==', 39489, 'The default background ID'
		. ' list has 39489 transcript IDs');

	# Create a new instance of PeaksToGenes::Contrast::Genes and test the
	# ability to return the correct Array Refs of gene ID lists, or invalid
	# RefSeq accessions
	my $test_only_genes = PeaksToGenes::Contrast::Genes->new(
		schema					=>	$peaks_to_genes->schema,
		genome					=>	'hg18',
		test_genes_fh			=>	't/0_to_12_Gene_List.txt',
	);
	isa_ok($test_only_genes, 'PeaksToGenes::Contrast::Genes');
	# Test the ability of the PeaksToGenes::Contrast::Genes::extract_genes
	# to correctly identify whether a background file has been set by the
	# user or not and return the correct Array Refs of transcript IDs and
	# invalid accessions
	can_ok($test_only_genes, 'get_genes');
	my ($test_only_valid_test_ids, $test_only_invalid_test_accessions,
		$test_only_valid_background_ids,
		$test_only_invalid_background_accessions) =
	$test_only_genes->get_genes;
	isa_ok($test_only_valid_test_ids, 'ARRAY');
	isa_ok($test_only_invalid_test_accessions, 'ARRAY');
	cmp_ok(@$test_only_valid_test_ids, '==', 873, 
		'There are 873 valid IDs found');
	cmp_ok(@$test_only_invalid_test_accessions, '==', 28, 
		'There are 28 invalid accessions');
	isa_ok($test_only_valid_background_ids, 'ARRAY');
	cmp_ok(@$test_only_valid_background_ids, '==', 39489, 'The default ' .
		'background ID list has 39489 transcript IDs');
	isa_ok($test_only_invalid_background_accessions, 'ARRAY');
	cmp_ok(@$test_only_invalid_background_accessions, '==', 0,
		'There are no invalid accessions for the default background ' .
		'accessions list');

	# Create a new instance of PeaksToGenes::Contrast::Genes and test the
	# ability to return the correct Array Refs of gene ID lists, or invalid
	# RefSeq accessions
	my $test_genes = PeaksToGenes::Contrast::Genes->new(
		schema					=>	$peaks_to_genes->schema,
		genome					=>	'hg18',
		test_genes_fh			=>	't/0_to_12_Gene_List.txt',
		background_genes_fh		=>	't/0_to_3_Gene_List.txt',
	);
	isa_ok($test_genes, 'PeaksToGenes::Contrast::Genes');
	# Test the ability of the PeaksToGenes::Contrast::Genes::extract_genes
	# to correctly identify whether a background file has been set by the
	# user or not and return the correct Array Refs of transcript IDs and
	# invalid accessions
	can_ok($test_genes, 'get_genes');
	my ($test_valid_test_ids, $test_invalid_test_accessions,
		$test_valid_background_ids,
		$test_invalid_background_accessions) =
	$test_genes->get_genes;
	isa_ok($test_valid_test_ids, 'ARRAY');
	isa_ok($test_invalid_test_accessions, 'ARRAY');
	cmp_ok(@$test_valid_test_ids, '==', 873, 
		'There are 873 valid IDs found');
	cmp_ok(@$test_invalid_test_accessions, '==', 28, 
		'There are 28 invalid accessions');
	isa_ok($test_valid_background_ids, 'ARRAY');
	cmp_ok(@$test_valid_background_ids, '==', 360, 'The user-defined' .
		' background list has 360 genes');
	isa_ok($test_invalid_background_accessions, 'ARRAY');
	cmp_ok(@$test_invalid_background_accessions, '==', 11,
		'There are 11 invalid accessions found in the user-defined ' .
		'background list.');

	# Call the external install_database.pl script to clear the database and
	# index files after testing
	`$FindBin::Bin/../install_database.pl`;

}

done_testing;
