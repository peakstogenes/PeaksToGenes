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
use PeaksToGenes::BedTools;
use PeaksToGenes::Out;
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
	# Create a series of BED files with errors to test the
	# PeaksToGenes::BedTools::check_bed_file subroutine
	my $bad_bed_lines = [
		"chr1\t57000\t56999\tname1\t1",
		"chr23\t57000\t58000\tname1\t1",
		"chr1\t57000\t58000\tname1",
		"chr1\t57000\t58000",
		"chr1\t57000\t58000\tname1\t1\textra_info",
	];
	# Iterate through the bad BED lines, write each to a temporary file,
	# and create an instance of PeaksToGenes::BedTools to call the
	# PeaksToGenes::BedTools::check_bed_file subroutine to make sure that
	# it throws an error with each of these incorrectly formatted BED file.
	foreach my $bad_bed_line (@$bad_bed_lines) {
		open my $temp_out, ">", "$FindBin::Bin/temp.bed" or die 
		"Could not write to $FindBin::Bin/temp.bed";
		print $temp_out $bad_bed_line;
		close $temp_out;
		my $temp_bedtools = PeaksToGenes::BedTools->new(
			genome		=>	'hg19',
			name		=>	'testing1',
			schema		=>	$peaks_to_genes->schema,
			summits		=>	"$FindBin::Bin/temp.bed",
			index_files	=>	$genome_info,
		);
		isa_ok($temp_bedtools, 'PeaksToGenes::BedTools');
		can_ok($temp_bedtools, 'check_bed_file');
		eval { $temp_bedtools->check_bed_file };
		ok( $@, "The PeaksToGenes::BedTools::check_bed_file function correctly identified an error in the BED file");
		`rm $FindBin::Bin/temp.bed`;
	}
	# Test to make sure PeaksToGenes::BedTools::check_bed_file can properly
	# identify a correctly formatted BED file
	open my $temp_out, ">", "$FindBin::Bin/temp.bed" or die "Could not
	write to temporary BED file $!";
	print $temp_out join("\t", "chr1", 57000, 58000, "name1", 123);
	close $temp_out;
	my $temp_bedtools = PeaksToGenes::BedTools->new(
		genome		=>	'hg19',
		name		=>	'testing1',
		schema		=>	$peaks_to_genes->schema,
		summits		=>	"$FindBin::Bin/temp.bed",
		index_files	=>	$genome_info,
	);
	isa_ok($temp_bedtools, 'PeaksToGenes::BedTools');
	can_ok($temp_bedtools, 'check_bed_file');
	eval { $temp_bedtools->check_bed_file };
	ok( ! $@, "The PeaksToGenes::BedTools::check_bed_file function correctly identified a correctly formatted BED file");
	`rm $FindBin::Bin/temp.bed`;
	# Write new temporary BED format file
	open my $bed_out, ">", "$FindBin::Bin/temp.bed" or die "Could not
	write to temporary BED file";
	print $bed_out join("\n",
		join("\t", "chr6", "36644232", "36644327", "CDKN1A_TSS", "5"),
		join("\t", "chr17", "41277197", "41277554", "BRCA1_TSS", "123"),
		join("\t", "chr3", "181429686", "181429760", "SOX2_TSS", "5")
	), "\n";
	close $bed_out;
	# Create a new instance of PeaksToGenes::BedTools and check to see if
	# it can call the PeaksToGenes::BedTools::create_blank_index subroutine
	# and ensure that it can do this correctly.
	my $bedtools = PeaksToGenes::BedTools->new(
		genome		=>	'hg19',
		name		=>	'testing1',
		schema		=>	$peaks_to_genes->schema,
		summits		=>	"$FindBin::Bin/temp.bed",
		index_files	=>	$genome_info,
	);
	isa_ok($bedtools, 'PeaksToGenes::BedTools');
	can_ok($bedtools, 'check_bed_file');
	can_ok($bedtools, 'create_blank_index');
	my $test_blank_index = $bedtools->create_blank_index($genome_info);
	isa_ok($test_blank_index, 'HASH');
	# Check to make sure that the bedtools object can execute the
	# PeaksToGenes::BedTools::align_peaks subroutine, then execute the
	# subroutine and test the returned data
	can_ok($bedtools, 'align_peaks');
	my $test_indexed_peaks = $bedtools->align_peaks($test_blank_index);
	isa_ok($test_indexed_peaks, 'HASH');
	cmp_ok($test_indexed_peaks->{'NM_003106'}{'_1Kb_Upstream_Number_of_Peaks'},
		'==', 1, 'There is one peak in the SOX2 promoter/TSS region');
	cmp_ok($test_indexed_peaks->{'NM_003106'}{'_1Kb_Upstream_Interval_Size'},
		'==', 1000, 
		'The interval size for the SOX2 promoter/TSS region is 1Kb');
	cmp_ok($test_indexed_peaks->{'NM_024865'}{'_1Kb_Upstream_Number_of_Peaks'},
		'==', 0, 'There are no peaks in the NANOG promoter/TSS region');
	cmp_ok($test_indexed_peaks->{'NM_024865'}{'_1Kb_Upstream_Interval_Size'},
		'==', 0,
		'The interval size for the NANOG promoter/TSS region has not been measured'
	);
	cmp_ok($test_indexed_peaks->{'NM_003106'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 1, 
		'There is one peak in the SOX2 first decile of the gene body');
	cmp_ok($test_indexed_peaks->{'NM_024865'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 0, 
		'There are no peaks in the NANOG first decile of the gene body');
	# Using the already created instance of PeaksToGenes::BedTools, run the
	# PeaksToGenes::BedTools::annotate_peaks function and test the ability
	# of the PeaksToGenes::BedTools module to return a correctly formatted
	# Hash Ref of RefSeq transcripts annotated with user-defined genomic
	# positions
	can_ok($bedtools, 'annotate_peaks');
	my $indexed_peaks = $bedtools->annotate_peaks;
	isa_ok($indexed_peaks, 'HASH');
	cmp_ok($indexed_peaks->{'NM_003106'}{'_1Kb_Upstream_Number_of_Peaks'},
		'==', 1, 'There is one peak in the SOX2 promoter/TSS region');
	cmp_ok($indexed_peaks->{'NM_024865'}{'_1Kb_Upstream_Number_of_Peaks'},
		'==', 0, 'There are no peaks in the NANOG promoter/TSS region');
	cmp_ok($indexed_peaks->{'NM_003106'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 1, 
		'There is one peak in the SOX2 first decile of the gene body');
	cmp_ok($indexed_peaks->{'NM_024865'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 0, 
		'There are no peaks in the NANOG first decile of the gene body');
	# Create an instance of PeaksToGenes::Out to test the ability of each
	# function in PeaksToGenes::Out to parse the Hash Ref returned by
#	# PeaksToGenes::BedTools
#	my $test_out = PeaksToGenes::Out->new(
#		indexed_peaks	=>	$indexed_peaks,
#		schema			=>	$peaks_to_genes->schema,
#		name			=>	'testing1',
#		ordered_index	=>	$genome_info,
#		genome			=>	'hg19',
#	);
#	isa_ok($test_out, 'PeaksToGenes::Out');
}

done_testing;
