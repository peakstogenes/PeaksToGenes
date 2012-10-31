#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 02-update_ucsc.t
#
#  DESCRIPTION: This is the test script to ensure that dynamic database
#  				update through interaction with the UCSC MySQL server and
#  				parsing of genomic coordinates is working properly.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/03/2012 08:26:14 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Update::UCSC;

BEGIN {

	# Call the external install_database.pl script to clear the database and
	# index files before testing
	`$FindBin::Bin/../install_database.pl`;

	# Create a PeaksToGenes::Update::UCSC object
	my $update = PeaksToGenes::Update::UCSC->new(
			genome	=>	'hg19',
	);
	# Test to make sure that update is a PeaksToGenes::Update::UCSC object
	isa_ok($update, 'PeaksToGenes::Update::UCSC');
	# Fetch the chromosome sizes from UCSC, test to make sure that is is a
	# Hash Ref
	can_ok($update, 'chromosome_sizes');
	my $chromosome_sizes = $update->chromosome_sizes;
	isa_ok($chromosome_sizes, 'HASH', 
		'The object returned by the chromosome_sizes subroutine');
	# Extract chromosome 1, and test to make sure it is the correct length
	my $chromosome_1_size = {
		'chr1'	=>	$chromosome_sizes->{chr1}
	};
	cmp_ok($chromosome_1_size->{chr1}, '==', 249250621, 
		"Human chromosome 1 is 249250621 bases long");
	# Test to make sure the
	# PeaksToGenes::Update::UCSC::write_chromosome_sizes subroutine can be
	# called and correctly write the coordinates to file
	can_ok($update, 'write_chromosome_sizes');
	$update->write_chromosome_sizes;
	ok( -r
		"$FindBin::Bin/../static/hg19_Index/chromosome_sizes_file/hg19_chromosome_sizes_file",
	'PeaksToGenes::Update::UCSC::write_chromosome_sizes wrote the chromosome sizes to file');
	open my $chr_file, "<",
		"$FindBin::Bin/../static/hg19_Index/chromosome_sizes_file/hg19_chromosome_sizes_file";
	my @chromosome_size_lines = <$chr_file>;
	ok(grep(qr/^chr1\t249250621\n$/, @chromosome_size_lines), 'The coordinates for chromosome 1 are correctly writte to file');
	# Test to make sure the file_names subroutine can be called
	can_ok($update, 'file_names');
	my $file_strings = $update->file_names;
	isa_ok($file_strings, 'ARRAY', 'The file_names subroutine return');
	# Test to make sure the get_gene_body_coordinates subroutine can be
	# called
	can_ok($update, 'get_gene_body_coordinates');
	my $refseq = $update->get_gene_body_coordinates;
	# Test to make sure that a Hash Ref is returned by the
	# get_gene_body_coordinates subroutine
	isa_ok($refseq, 'HASH',
		'The object returned by the get_gene_body_coordinates subroutine');
	# Extract the genomic coordinates for two genes on chromosome 1, FOXJ3
	# isoform 1 NM_014947, which is on the negative strand and PBX1,
	# transcript variant 3 NM_001204963, which is on the positive strand.
	my $test_refseq = {
		'NM_014947'		=>	$refseq->{'NM_014947'},
		'NM_001204963'	=>	$refseq->{'NM_001204963'},
	};
	# Test to make sure the gene body coordinates were correctly fetched
	# from UCSC
	cmp_ok($test_refseq->{'NM_014947'}{'name'}, 'eq', 'NM_014947', 
		'The FOXJ3 gene was fetched from UCSC');
	cmp_ok($test_refseq->{'NM_001204963'}{'name'}, 'eq', 'NM_001204963',
		'The PBX1 gene was fetched from UCSC');
	# Test to make sure the empty_genomic_coordinates subroutine can be
	# called
	can_ok($update, 'empty_genomic_coordinates');
	my $genomic_coordinates = $update->empty_genomic_coordinates;
	isa_ok($genomic_coordinates, 'HASH', 'The return from empty_genomic_coordinates');
	# Test to make sure the upstream and downstream coordinates can be
	# defined for genes on both the positive and negative strands.
	can_ok($update, 'get_upstream_and_downstream_coordinates');
	$genomic_coordinates =
	$update->get_upstream_and_downstream_coordinates($test_refseq->{NM_014947},
		$chromosome_sizes, $genomic_coordinates
	);
	isa_ok($genomic_coordinates->{'Upstream'}, 'HASH', 
		'After calling get_upstream_and_downstream_coordinates genomic_coordinates still');
	isa_ok($genomic_coordinates->{'Upstream'}{42}, 'ARRAY',
		'The upstream and downstream coordinate');
	$genomic_coordinates =
	$update->get_upstream_and_downstream_coordinates($test_refseq->{NM_001204963},
		$chromosome_sizes, $genomic_coordinates
	);
	my $test_upstream_lines = $genomic_coordinates->{'Upstream'}{42};
	foreach my $test_upstream_line (@$test_upstream_lines) {
		my ($chr, $start, $stop, $accession) = split(/\t/,
			$test_upstream_line);
		cmp_ok($stop, '>', $start, 
			"The end position for $accession at 43Kb upstream is greater than the start position");
		cmp_ok(($stop-$start + 1), '==', 1000, 
			"The genomic interval size for $accession at 43Kb upstream is 1000bp");
	}
	# Test to make sure the get_utrs_exon_and_introns subroutine can be
	# called
	can_ok($update, 'get_utrs_exon_and_introns');
	$genomic_coordinates =
	$update->get_utrs_exon_and_introns($test_refseq->{NM_014947},
		$genomic_coordinates);
	$update->get_utrs_exon_and_introns($test_refseq->{NM_001204963},
		$genomic_coordinates);
	# Test to make sure the utr, exon and intron coordinates are correct in
	# that the end coordinate is larger than the start coordinate
	foreach my $coordinate_type ('three_prime_utr_coordinates',
			'five_prime_utr_coordinates', 'intron_coordinates',
			'exon_coordinates') {
			foreach my $test_line
			(@{$genomic_coordinates->{$coordinate_type}}) {
				my ($chr, $start, $stop, $accession) = split(/\t/,
					$test_line);
				cmp_ok($stop, '>', $start, "The end coordinate is larger than the start coordinate for the $coordinate_type for $accession");
			}
	}
	# Test to make sure the get_decile_coordinates subroutine can be called
	can_ok($update, 'get_decile_coordinates');
	$genomic_coordinates =
	$update->get_decile_coordinates($test_refseq->{NM_014947},
		$genomic_coordinates);
	$genomic_coordinates =
	$update->get_decile_coordinates($test_refseq->{NM_001204963},
		$genomic_coordinates);
	# Test to make sure that the decile coordinates are calculated
	# correctly in that the end position is greater than the start position
	# and that the first 9 deciles are equal in length
	my $NM_014947_decile_length = 15869;
	my $NM_001204963_decile_length = 29245;
	for (my $decile = 1; $decile < 10; $decile++) {
		my $test_decile_lines =
		$genomic_coordinates->{'decile_coordinates'}{$decile};
		foreach my $test_decile_line (@$test_decile_lines) {
			my ($chr, $start, $stop, $accession) = split(/\t/,
				$test_decile_line);
			cmp_ok($stop, '>', $start, "The end coordinates are greater than the start coordinates for decile number $decile for the $accession transcript");
			if ( $accession eq 'NM_014947') {
				cmp_ok(($stop-$start), '==', $NM_014947_decile_length, 
					"The decile number $decile for the $accession transcript is the correct length");
			} elsif ( $accession eq 'NM_001204963') {
				cmp_ok(($stop-$start), '==', $NM_001204963_decile_length, 
					"The decile number $decile for the $accession transcript is the correct length");
			}
		}
	}
	can_ok($update, 'print_genomic_coordinates');
	$update->print_genomic_coordinates($file_strings, $genomic_coordinates);
	# Make sure that the files have been created and can be read by Perl
	foreach my $file_string (@$file_strings) {
		ok( -r $file_string, "File string $file_string is readable");
	}
	# Create a new instance of PeaksToGenes::Update::UCSC and make the
	# full call, and test to ensure that an Array Ref is returned
	my $full_update = PeaksToGenes::Update::UCSC->new(
		genome	=>	'hg19',
	);
	isa_ok($full_update, 'PeaksToGenes::Update::UCSC');
	my ($base_files, $chromosome_sizes_fh) = $full_update->fetch_tables;
	isa_ok($base_files, 'ARRAY', 'The return from the full call to PeaksToGenes::Update::UCSC->fetch_tables returns');
	cmp_ok(@$base_files, '==', 214, 'There are 214 files listed in the return from the full call to PeaksToGenes::Update::UCSC->fetch_tables');
	ok(-r $chromosome_sizes_fh, "The file string returned for the chromosome sizes is readable");

	# Call the external install_database.pl script to clear the database and
	# index files before testing
	`$FindBin::Bin/../install_database.pl`;
}

done_testing;
