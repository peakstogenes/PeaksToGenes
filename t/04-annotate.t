#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 04-annotate.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions
#  				used by PeaksToGenes to annotate peaks files to a
#  				user-defined genome
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/04/2012 02:07:25 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;
use PeaksToGenes::Update;
use PeaksToGenes::FileStructure;
use Data::Dumper;

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
	# Create an instance of PeaksToGenes::FileStructure
	my $file_structure = PeaksToGenes::FileStructure->new(
		genome	=>	'hg19',
		schema	=>	$peaks_to_genes->schema,
		name	=>	'testing01',
	);
	# Test to make sure that file_structure is a
	# PeaksToGenes::FileStructure object
	isa_ok($file_structure, 'PeaksToGenes::FileStructure');
	# Test to make sure that the file_structure object can execute the
	# PeaksToGenes::FileStructure::test_name function
	can_ok($file_structure, 'test_name');
	# Check to make sure that the name entered by the user has not been
	# previously used using PeaksToGenes::FileStructure::test_name
	$file_structure->test_name;
	# Check to make sure that the hg19 genome has been indexed using the
	# PeaksToGenes::FileStructure::test_genome
	can_ok($file_structure, 'test_genome');
	my $available_genome_search_results = $file_structure->test_genome;
	isa_ok($available_genome_search_results, 'DBIx::Class::ResultSet');
	# Check to make sure the
	# PeaksToGenes::FileStructure::get_index_file_names subroutine can be
	# called
	can_ok($file_structure, 'get_index_file_names');
	# Run the PeaksToGenes::FileStructure::get_index_file_names subroutine
	# and test to make sure the object returned is an Array Ref
	my $genome_info =
	$file_structure->get_index_file_names($available_genome_search_results);
	isa_ok($genome_info, 'ARRAY', 'The object returned from get_index_file_names ');
	# Test to make sure that each string listed in the list corresponds to
	# a readable file
	foreach my $index_file (@$genome_info) {
		ok( -r $index_file, "Index file string corresponds to a readable file");
	}
	# Test to make sure there are right number of index files found
	cmp_ok(@$genome_info, '==', 214, 'The index has the correct number of files');
}

done_testing;
