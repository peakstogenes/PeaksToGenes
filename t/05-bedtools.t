#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 05-bedtools.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions of 
#  				PeaksToGenes::Annotate::BedTools.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/08/2012 03:13:44 PM
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
use PeaksToGenes::Annotate::BedTools;

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

	# Create an instance of PeaksToGenes::Annotate::FileStructure and
	# return the ordered index of genomic index file string locations
	my $file_structure = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$peaks_to_genes->schema,
		genome	=>	'hg19',
		name	=>	'testing',
	);
	my $genome_info = $file_structure->test_and_extract;
	cmp_ok(@$genome_info, '==', 214, 'The ordered index of genomic files' .
		' has the correct number of files.');

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
	# and create an instance of PeaksToGenes::Annotate::BedTools to call the
	# PeaksToGenes::Annotate::BedTools::check_bed_file subroutine to make
	# sure that it throws an error with each of these incorrectly formatted
	# BED file.
	foreach my $bad_bed_line (@$bad_bed_lines) {
		open my $temp_out, ">", "$FindBin::Bin/temp.bed" or die 
		"Could not write to $FindBin::Bin/temp.bed";
		print $temp_out $bad_bed_line;
		close $temp_out;
		my $temp_bedtools = PeaksToGenes::Annotate::BedTools->new(
			genome		=>	'hg19',
			name		=>	'testing1',
			schema		=>	$peaks_to_genes->schema,
			summits		=>	"$FindBin::Bin/temp.bed",
			index_files	=>	$genome_info,
		);
		isa_ok($temp_bedtools, 'PeaksToGenes::Annotate::BedTools');
		can_ok($temp_bedtools, 'check_bed_file');
		eval { $temp_bedtools->check_bed_file };
		ok( $@, "The PeaksToGenes::BedTools::check_bed_file function " .
			"correctly identified an error in the BED file");
		`rm $FindBin::Bin/temp.bed`;
	}

	# Write new temporary BED format file, which is properly formatted
	open my $bed_out, ">", "$FindBin::Bin/temp.bed" or die "Could not
	write to temporary BED file";
	print $bed_out join("\n",
		join("\t", "chr6", "36644232", "36644327", "CDKN1A_TSS", "5"),
		join("\t", "chr17", "41277197", "41277554", "BRCA1_TSS", "123"),
		join("\t", "chr3", "181429686", "181429760", "SOX2_TSS", "5")
	), "\n";
	close $bed_out;

	# Create a new instance of PeaksToGenes::Annotate::BedTools and test
	# whether it can correctly identify a properly formatted BED file
	my $temp_bedtools = PeaksToGenes::Annotate::BedTools->new(
		genome		=>	'hg19',
		name		=>	'testing1',
		schema		=>	$peaks_to_genes->schema,
		summits		=>	"$FindBin::Bin/temp.bed",
		index_files	=>	$genome_info,
		processors	=>	8,
	);
	isa_ok($temp_bedtools, 'PeaksToGenes::Annotate::BedTools');
	can_ok($temp_bedtools, 'check_bed_file');
	eval { $temp_bedtools->check_bed_file };
	ok( ! $@, "The PeaksToGenes::BedTools::check_bed_file function " .
		"correctly identified a correctly formatted BED file");

	# Test the ability of the PeaksToGenes::Annotate::BedTools::align_peaks
	# subroutine to properly align the experimental intervals to the
	# user-defined genome
	can_ok($temp_bedtools, 'align_peaks');
	my $temp_indexed_peaks = $temp_bedtools->align_peaks;
	isa_ok($temp_indexed_peaks, 'HASH');
	# Test that the Hash Ref returned has the correct information
	cmp_ok($temp_indexed_peaks->{'NM_007300'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 1, 'There is an experimental interval found in the first ' .
		'decile of BRCA1');
	ok( ! $temp_indexed_peaks->{'NM_024865'}, 'There are no experimental '
		. 'intervals within 100Kb of the NANOG gene body');

	# Create a new instance of PeaksToGenes::Annotate::BedTools to test the
	# PeaksToGenes::Annotate::BedTools::annotate_peaks subroutine which
	# pasts together all of the previously tested functions
	my $bedtools = PeaksToGenes::Annotate::BedTools->new(
		genome		=>	'hg19',
		name		=>	'testing1',
		schema		=>	$peaks_to_genes->schema,
		summits		=>	"$FindBin::Bin/temp.bed",
		index_files	=>	$genome_info,
		processors	=>	8,
	);
	my $indexed_peaks = $bedtools->annotate_peaks;
	isa_ok($indexed_peaks, 'HASH');
	# Test that the Hash Ref returned has the correct information
	cmp_ok($indexed_peaks->{'NM_007300'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 1, 'There is an experimental interval found in the first ' .
		'decile of BRCA1');
	ok( ! $indexed_peaks->{'NM_024865'}, 'There are no experimental '
		. 'intervals within 100Kb of the NANOG gene body');

	`rm $FindBin::Bin/temp.bed`;

	# Call the external install_database.pl script to clear the database and
	# index files after testing is complete
	`$FindBin::Bin/../install_database.pl`;
}

done_testing;
