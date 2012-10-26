#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 000-all.t
#
#  DESCRIPTION: This Perl test script is designed to test the functions of
#  				the PeaksToGenes program
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
use PeaksToGenes::Contrast;
use PeaksToGenes::Contrast::Genes;
use PeaksToGenes::Contrast::GenomicRegions;
use PeaksToGenes::Contrast::Stats::ANOVA;
use PeaksToGenes::Contrast::ParseStats;
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

	# Create a new instance of PeaksToGenes::Contrast, specifying that all
	# statistical tests should be run
	my $contrast = PeaksToGenes::Contrast->new(
		schema					=>	$peaks_to_genes->schema,
		genome					=>	'hg18',
		name					=>	'brown_er',
		test_genes_fh			=>	't/0_to_3_Gene_List.txt',
		background_genes_fh		=>	't/0_to_12_Gene_List.txt',
		processors				=>	8,
		statistical_tests		=>	{
			wilcoxon		=>	1,
			point_biserial	=>	1,
			anova			=>	1,
		},
		contrast_name			=>	'testing_01',
	);

	# Run the PeaksToGenes::Contrast::test_and_contrast subroutine to run
	# the statistical tests, create the aggregate tables, parse the
	# statistical tests, and print the tables to file
	$contrast->test_and_contrast;

#	# Call the external install_database.pl script to clear the database and
#	# index files after testing
#	`$FindBin::Bin/../install_database.pl`;
}


done_testing;
