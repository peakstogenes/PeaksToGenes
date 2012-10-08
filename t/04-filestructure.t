#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 04-filestructure.t
#
#  DESCRIPTION: This test script is designed to test the functions of
#  				PeaksToGenes::Annotate::FileStructure.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/08/2012 01:42:02 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;
use PeaksToGenes::Update;
use PeaksToGenes::Annotate::FileStructure;

BEGIN {

	# Call the external install_database.pl script to clear the database and
	# index files before testing
	`$FindBin::Bin/../install_database.pl`;

	# Begin by creating PeaksToGenes and PeaksToGenes::Update objects to
	# create a genomic index for hg19
	my $peaks_to_genes = PeaksToGenes->new(
		'genome'	=>	'hg19',
	);
	my $update = PeaksToGenes::Update->new(
		'genome'	=>	'hg19',
		'schema'	=>	$peaks_to_genes->schema,
	);
	$update->update;

	# Create an instance of PeaksToGenes::Annotate::FileStructure and test
	# to make sure that it was created correctly.
	my $hg19_file_structure = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$peaks_to_genes->schema,
		genome	=>	'hg19',
		name	=>	'testing',
	);
	isa_ok($hg19_file_structure, 'PeaksToGenes::Annotate::FileStructure');

	# Test the ability of PeaksToGenes::Annotate::FileStructure to find the
	# genome id of the user-defined genome.
	can_ok($hg19_file_structure, 'test_genome');

	# Run the PeaksToGenes::Annotate::FileStructure::test_genome subroutine
	# to return a search result, which contains the genome_id and the file
	# strings corresponding to the genomic index files
	my $hg19_genomic_search_result = $hg19_file_structure->test_genome;
	isa_ok($hg19_genomic_search_result,
		'PeaksToGenes::Schema::Result::AvailableGenome');

	# Insert into the experiment table, the fictitious experiment
	# 'testing1' to test the ability for
	# PeaksToGenes::Annotate::FileStructure::test_name to identify an
	# instance when the user-defined experiment name is already in use.
	can_ok($peaks_to_genes->schema->resultset('Experiment'), 'populate');
	eval {
		$peaks_to_genes->schema->resultset('Experiment')->populate(
			[
				{
					genome_id	=>	$hg19_genomic_search_result->id,
					experiment	=>	'testing1',
				}
			]
		);
	};
	ok( ! $@, 'The experiment \'testing1\' was properly inserted');

	# Create an mm9 version of PeaksToGenes::Annotate::FileStructure to
	# test the ability for
	# PeaksToGenes::Annotate::FileStructure::test_genome to identify a
	# genome that has not been indexed on the user's machine.
	my $mm9_file_structure = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$peaks_to_genes->schema,
		genome	=>	'mm9',
		name	=>	'testing1',
	);
	can_ok($mm9_file_structure, 'test_genome');
	eval {
		my $mm9_genomes_search_result = $mm9_file_structure->test_genome;
	};
	ok($@, 'PeaksToGenes::Annotate::FileStructure::test_genome correctly '
		. 'identified that the mm9 genome has not been indexed');

	can_ok($mm9_file_structure, 'test_name');
	can_ok($hg19_file_structure, 'test_name');
	eval {
		$hg19_file_structure->test_name;
	};
	ok(! $@, 'PeaksToGenes::Annotate::FileStructure::test_name correctly '
		. 'identified that \'testing\' is not a previously defined ' .
		'experiment name');
	eval {
		$mm9_file_structure->test_name;
	};
	ok( $@, 'PeaksToGenes::Annotate::FileStructure::test_name correctly ' .
		'identified that \'testing1\' has already been used as an ' .
		'experimental name');

	# Test the ability to the
	# PeaksToGenes::Annotate::FileStructure::get_index_file_names
	# subroutine and correctly return an ordered index of file strings
	# corresponding to the genomic index files
	can_ok($hg19_file_structure, 'get_index_file_names');
	my $hg19_index =
	$hg19_file_structure->get_index_file_names($hg19_genomic_search_result);
	isa_ok($hg19_index, 'ARRAY');
	cmp_ok(@$hg19_index, '==', 214);

	# Iterate through the file index and ensure that it is properly ordered
	# and that each file is readable
	for ( my $i = 0; $i < 100; $i++ ) {
		my $upstream_distance = (100 - $i) . 'Kb_Upstream';
		like($hg19_index->[$i], qr/$upstream_distance/, 'The file is ' . 
			'correctly located in the index');
		ok( -r $hg19_index->[$i], 'The file is readable');
	}
	like($hg19_index->[100], qr/5Prime_UTR/, 'The  5\'-UTR file is ' .
		'correctly located in the index');
	ok( -r $hg19_index->[100], 'The file is readable');
	like($hg19_index->[101], qr/Exons/, 'The Exons file is correctly ' .
		'located in the index');
	ok( -r $hg19_index->[101], 'The file is readable');
	like($hg19_index->[102], qr/Introns/, 'The Introns file is correctly '.
		'located in the index');
	ok( -r $hg19_index->[102], 'The file is readable');
	like($hg19_index->[103], qr/3Prime_UTR/, 'The 3\'-UTR file is ' .
		'correctly located in the index');
	ok( -r $hg19_index->[103], 'The file is readable');
	for ( my $i = 104; $i < 114; $i++ ) {
		my $gene_body_file_string = 'Gene_Body_' . ($i-104)*10 . '_to_' .
		($i-103)*10;
		like($hg19_index->[$i], qr/$gene_body_file_string/, 'The gene body'
			. ' file is correctly located in the index.');
		ok( -r $hg19_index->[$i], 'The gene body file is readable');
	}
	for ( my $i = 114; $i < 214; $i++ ) {
		my $downstream_distance = ($i-113) . 'Kb_Downstream';
		like($hg19_index->[$i], qr/$downstream_distance/, 'The file is ' . 
			'correctly located in the index');
		ok( -r $hg19_index->[$i], 'The file is readable');
	}

	# Create a new instance of PeaksToGenes::Annotate::FileStructure and
	# test the ability to run the
	# PeaksToGenes::Annotate::FileStructure::test_and_extract function,
	# which glues together all of the previously tested functions and
	# should return the ordered Array Ref of files

	my $full_hg19 = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$peaks_to_genes->schema,
		genome	=>	'hg19',
		name	=>	'testing',
	);
	
	# Clear the previously filled Array Ref
	$hg19_index = [];

	# Test that it has been cleared
	cmp_ok( @$hg19_index,'==', 0, 'The index has been cleared');

	can_ok($full_hg19, 'test_and_extract');
	$hg19_index = $full_hg19->test_and_extract;
	isa_ok( $hg19_index, 'ARRAY');
	cmp_ok(@$hg19_index, '==', 214);


	# Iterate through the file index and ensure that it is properly ordered
	# and that each file is readable
	for ( my $i = 0; $i < 100; $i++ ) {
		my $upstream_distance = (100 - $i) . 'Kb_Upstream';
		like($hg19_index->[$i], qr/$upstream_distance/, 'The file is ' . 
			'correctly located in the index');
		ok( -r $hg19_index->[$i], 'The file is readable');
	}
	like($hg19_index->[100], qr/5Prime_UTR/, 'The  5\'-UTR file is ' .
		'correctly located in the index');
	ok( -r $hg19_index->[100], 'The file is readable');
	like($hg19_index->[101], qr/Exons/, 'The Exons file is correctly ' .
		'located in the index');
	ok( -r $hg19_index->[101], 'The file is readable');
	like($hg19_index->[102], qr/Introns/, 'The Introns file is correctly '.
		'located in the index');
	ok( -r $hg19_index->[102], 'The file is readable');
	like($hg19_index->[103], qr/3Prime_UTR/, 'The 3\'-UTR file is ' .
		'correctly located in the index');
	ok( -r $hg19_index->[103], 'The file is readable');
	for ( my $i = 104; $i < 114; $i++ ) {
		my $gene_body_file_string = 'Gene_Body_' . ($i-104)*10 . '_to_' .
		($i-103)*10;
		like($hg19_index->[$i], qr/$gene_body_file_string/, 'The gene body'
			. ' file is correctly located in the index.');
		ok( -r $hg19_index->[$i], 'The gene body file is readable');
	}
	for ( my $i = 114; $i < 214; $i++ ) {
		my $downstream_distance = ($i-113) . 'Kb_Downstream';
		like($hg19_index->[$i], qr/$downstream_distance/, 'The file is ' . 
			'correctly located in the index');
		ok( -r $hg19_index->[$i], 'The file is readable');
	}

	# Call the external install_database.pl script to clear the database and
	# index files after testing is complete
	`$FindBin::Bin/../install_database.pl`;
}

done_testing;
