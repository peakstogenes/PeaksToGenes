#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 07-annotate.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions
#  				of the PeaksToGenes::Annotate controller module which
#  				functions between the PeaksToGenes view module and the
#  				model PeaksToGenes modules.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/08/2012 04:56:09 PM
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
use PeaksToGenes::Annotate::Database;

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

	# Write new temporary BED format file, which is properly formatted
	open my $bed_out, ">", "$FindBin::Bin/temp.bed" or die "Could not
	write to temporary BED file";
	print $bed_out join("\n",
		join("\t", "chr6", "36644232", "36644327", "CDKN1A_TSS", "5"),
		join("\t", "chr17", "41277197", "41277554", "BRCA1_TSS", "123"),
		join("\t", "chr3", "181429686", "181429760", "SOX2_TSS", "5")
	), "\n";
	close $bed_out;

	# Create a new instance of PeaksToGenes::Annotate::BedTools and use it
	# to return a Hash Ref of annotated experimental intervals
	my $bedtools = PeaksToGenes::Annotate::BedTools->new(
		genome		=>	'hg19',
		name		=>	'testing1',
		schema		=>	$peaks_to_genes->schema,
		summits		=>	"$FindBin::Bin/temp.bed",
		index_files	=>	$genome_info,
	);
	my $indexed_peaks = $bedtools->annotate_peaks;
	isa_ok($indexed_peaks, 'HASH');
	# Test that the Hash Ref returned has the correct information
	cmp_ok($indexed_peaks->{'NM_007300'}{'_Gene_Body_0_to_10_Number_of_Peaks'},
		'==', 1, 'There is an experimental interval found in the first ' .
		'decile of BRCA1');
	ok( ! $indexed_peaks->{'NM_024865'}, 'There are no experimental '
		. 'intervals within 100Kb of the NANOG gene body');

	# Create an instance of PeaksToGenes::Annotate::Database to test the
	# ability to fetch the correct genome id, parse the row items into a
	# DBIx insert statement, and insert the parsed rows into the
	# PeaksToGenes database
	my $database = PeaksToGenes::Annotate::Database->new(
		indexed_peaks	=>	$indexed_peaks,
		schema			=>	$peaks_to_genes->schema,
		name			=>	'testing1',
		ordered_index	=>	$genome_info,
		genome			=>	'hg19',
	);
	can_ok($database, 'parse_and_store');
	$database->parse_and_store;
	# Search the transcript table for the transcript id corresponding to
	# NM_024865 and NM_007300
	my $brca1_id = $peaks_to_genes->schema->resultset('Transcript')->find(
		{
			transcript	=>	'NM_007300',
		}
	)->id;
	ok($brca1_id, 'The ID for BRCA1 has been found');
	my $nanog_id = $peaks_to_genes->schema->resultset('Transcript')->find(
		{
			transcript	=>	'NM_024865',
		}
	)->id;
	ok($nanog_id, 'The ID for NANOG has been found');

	# Search the PeaksToGenes database to ensure that the peaks have been
	# properly inserted
	my $experiment_id =
	$peaks_to_genes->schema->resultset('Experiment')->find(
		{
			experiment	=>	'testing1'
		}
	)->id;
	my $brca1_gene_body_result =
	$peaks_to_genes->schema->resultset('GeneBodyNumberOfPeaks')->find(
		{
			name	=>	$experiment_id,
			gene	=>	$brca1_id,
		}
	);

	cmp_ok( $brca1_gene_body_result->_gene_body_0_to_10_number_of_peaks,
		'>=', 0, 'The PeaksToGenes database has an interval defined in the'
		. ' first decile of BRCA1');
	ok( ! $brca1_gene_body_result->_gene_body_30_to_40_number_of_peaks,
		'The PeaksToGenes database does not have an interval defined in ' .
		'the third decile of BRCA1');

	# Remove the temporary BED format file
	`rm $FindBin::Bin/temp.bed`;

	# Call the external install_database.pl script to clear the database and
	# index files after testing is complete
	`$FindBin::Bin/../install_database.pl`;

}

done_testing;
