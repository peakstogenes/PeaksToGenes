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
use Data::Dumper;

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

	# Test the private
	# PeaksToGenes::Contrast::GenomicRegions::table_dispatch method and
	# make sure that the string defined at the end of each series of Hash
	# Refs is a valid table name in the PeaksToGenes database
	can_ok($genomic_regions, 'table_dispatch');
	isa_ok($genomic_regions->table_dispatch, 'HASH');
	foreach my $location (keys %{$genomic_regions->table_dispatch}) {
		foreach my $info_type (keys
			%{$genomic_regions->table_dispatch->{$location}}) {
			isa_ok($peaks_to_genes->schema->resultset($genomic_regions->table_dispatch->{$location}{$info_type}),
				'DBIx::Class::ResultSet');
		}
	}

	# Test the ability of
	# PeaksToGenes::Contrast::GenomicRegions::create_blank_index to create
	# and return a structure to store the information extracted from the
	# tables.
	can_ok($genomic_regions, 'create_blank_index');
	my $genomic_regions_structure = $genomic_regions->create_blank_index;
	isa_ok($genomic_regions_structure->{test_genes}, 'HASH');
	isa_ok($genomic_regions_structure->{background_genes}, 'HASH');
	foreach my $gene_type (keys %$genomic_regions_structure) {
		for (my $i = 1; $i <= 100; $i++) {
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_downstream'}, 'HASH');
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_upstream'}, 'HASH');
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_downstream'}{'number_of_peaks'}, 'ARRAY');
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_upstream'}{'number_of_peaks'}, 'ARRAY');
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_downstream'}{'peaks_information'}, 'ARRAY');
			isa_ok($genomic_regions_structure->{$gene_type}{'_' . $i .
				'kb_upstream'}{'peaks_information'}, 'ARRAY');
		}
		for (my $i = 0; $i < 100; $i +=10) {
			isa_ok($genomic_regions_structure->{$gene_type}{'_gene_body_' .
				$i . '_to_' . ($i+10)}, 'HASH');
			isa_ok($genomic_regions_structure->{$gene_type}{'_gene_body_' .
				$i . '_to_' . ($i+10)}{'number_of_peaks'}, 'ARRAY');
			isa_ok($genomic_regions_structure->{$gene_type}{'_gene_body_' .
				$i . '_to_' . ($i+10)}{'peaks_information'}, 'ARRAY');
		}
		foreach my $location (qw( _5prime_utr _exons _introns _3prime_utr )) {
			isa_ok($genomic_regions_structure->{$gene_type}{$location},
				'HASH');
			isa_ok($genomic_regions_structure->{$gene_type}{$location}{'peaks_information'},
				'ARRAY');
			isa_ok($genomic_regions_structure->{$gene_type}{$location}{'number_of_peaks'},
				'ARRAY');
		}
	}

	# Run the PeaksToGenes::Contrast::GenomicRegions::get_peaks subroutine
	# and test it's ability to properly extract the peak numbers and scores
	# from the tables
	$genomic_regions_structure =
	$genomic_regions->get_peaks($genomic_regions_structure);


	# Call the external install_database.pl script to clear the database and
	# index files after testing
	`$FindBin::Bin/../install_database.pl`;

}

done_testing;
