#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 03-update.t
#
#  DESCRIPTION: This Perl test script is run to test the ability of the
#  				PeaksToGenes::Update module to parse the list of file
#  				strings returned by PeaksToGenes::Update::UCSC and insert
#  				the strings into the PeaksToGenes database.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/04/2012 08:59:00 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;
use PeaksToGenes::Update;
use PeaksToGenes::Update::UCSC;
use Data::Dumper;

BEGIN {

	# Make a call to the external Perl script to reset the database
	`$FindBin::Bin/../install_database.pl`;

	# Create an instance of PeaksToGenes and run the PeaksToGenes::schema
	# function to return a PeaksToGenes::Schema object
	my $peaks_to_genes = PeaksToGenes->new(
		genome	=>	'hg19',
	);
	my $schema = $peaks_to_genes->schema;

	# Create a PeaksToGenes::Update object and test to make sure it has
	# been created correctly.
	my $test_update = PeaksToGenes::Update->new(
		genome	=>	'hg19',
		schema	=>	$schema,
	);
	isa_ok($test_update, 'PeaksToGenes::Update');

	# Create an instance of PeaksToGenes::Update::UCSC and run the
	# PeaksToGenes::Update::UCSC::fetch_tables function to return a list of
	# index file names
	my $ucsc_update = PeaksToGenes::Update::UCSC->new(
		genome	=>	'hg19',
	);
	my ($base_files, $chromosome_sizes_fh) = $ucsc_update->fetch_tables;

	# Test to make sure $test_update can run the create_statement function
	can_ok($test_update, 'create_statement');

	# Test to make sure PeaksToGenes::Update::create_statement returns a
	# correctly formatted insert statement
	my $available_genomes_insert =
	$test_update->create_statement($base_files);

	# Define a Hash Ref to store the names of valid columns in the
	# AvailableGenomes table
	my $valid_columns = {
		'genome'	=>	1,
		'_100kb_upstream_peaks_file'	=>	1,
		'_99kb_upstream_peaks_file'	=>	1,
		'_98kb_upstream_peaks_file'	=>	1,
		'_97kb_upstream_peaks_file'	=>	1,
		'_96kb_upstream_peaks_file'	=>	1,
		'_95kb_upstream_peaks_file'	=>	1,
		'_94kb_upstream_peaks_file'	=>	1,
		'_93kb_upstream_peaks_file'	=>	1,
		'_92kb_upstream_peaks_file'	=>	1,
		'_91kb_upstream_peaks_file'	=>	1,
		'_90kb_upstream_peaks_file'	=>	1,
		'_89kb_upstream_peaks_file'	=>	1,
		'_88kb_upstream_peaks_file'	=>	1,
		'_87kb_upstream_peaks_file'	=>	1,
		'_86kb_upstream_peaks_file'	=>	1,
		'_85kb_upstream_peaks_file'	=>	1,
		'_84kb_upstream_peaks_file'	=>	1,
		'_83kb_upstream_peaks_file'	=>	1,
		'_82kb_upstream_peaks_file'	=>	1,
		'_81kb_upstream_peaks_file'	=>	1,
		'_80kb_upstream_peaks_file'	=>	1,
		'_79kb_upstream_peaks_file'	=>	1,
		'_78kb_upstream_peaks_file'	=>	1,
		'_77kb_upstream_peaks_file'	=>	1,
		'_76kb_upstream_peaks_file'	=>	1,
		'_75kb_upstream_peaks_file'	=>	1,
		'_74kb_upstream_peaks_file'	=>	1,
		'_73kb_upstream_peaks_file'	=>	1,
		'_72kb_upstream_peaks_file'	=>	1,
		'_71kb_upstream_peaks_file'	=>	1,
		'_70kb_upstream_peaks_file'	=>	1,
		'_69kb_upstream_peaks_file'	=>	1,
		'_68kb_upstream_peaks_file'	=>	1,
		'_67kb_upstream_peaks_file'	=>	1,
		'_66kb_upstream_peaks_file'	=>	1,
		'_65kb_upstream_peaks_file'	=>	1,
		'_64kb_upstream_peaks_file'	=>	1,
		'_63kb_upstream_peaks_file'	=>	1,
		'_62kb_upstream_peaks_file'	=>	1,
		'_61kb_upstream_peaks_file'	=>	1,
		'_60kb_upstream_peaks_file'	=>	1,
		'_59kb_upstream_peaks_file'	=>	1,
		'_58kb_upstream_peaks_file'	=>	1,
		'_57kb_upstream_peaks_file'	=>	1,
		'_56kb_upstream_peaks_file'	=>	1,
		'_55kb_upstream_peaks_file'	=>	1,
		'_54kb_upstream_peaks_file'	=>	1,
		'_53kb_upstream_peaks_file'	=>	1,
		'_52kb_upstream_peaks_file'	=>	1,
		'_51kb_upstream_peaks_file'	=>	1,
		'_50kb_upstream_peaks_file'	=>	1,
		'_49kb_upstream_peaks_file'	=>	1,
		'_48kb_upstream_peaks_file'	=>	1,
		'_47kb_upstream_peaks_file'	=>	1,
		'_46kb_upstream_peaks_file'	=>	1,
		'_45kb_upstream_peaks_file'	=>	1,
		'_44kb_upstream_peaks_file'	=>	1,
		'_43kb_upstream_peaks_file'	=>	1,
		'_42kb_upstream_peaks_file'	=>	1,
		'_41kb_upstream_peaks_file'	=>	1,
		'_40kb_upstream_peaks_file'	=>	1,
		'_39kb_upstream_peaks_file'	=>	1,
		'_38kb_upstream_peaks_file'	=>	1,
		'_37kb_upstream_peaks_file'	=>	1,
		'_36kb_upstream_peaks_file'	=>	1,
		'_35kb_upstream_peaks_file'	=>	1,
		'_34kb_upstream_peaks_file'	=>	1,
		'_33kb_upstream_peaks_file'	=>	1,
		'_32kb_upstream_peaks_file'	=>	1,
		'_31kb_upstream_peaks_file'	=>	1,
		'_30kb_upstream_peaks_file'	=>	1,
		'_29kb_upstream_peaks_file'	=>	1,
		'_28kb_upstream_peaks_file'	=>	1,
		'_27kb_upstream_peaks_file'	=>	1,
		'_26kb_upstream_peaks_file'	=>	1,
		'_25kb_upstream_peaks_file'	=>	1,
		'_24kb_upstream_peaks_file'	=>	1,
		'_23kb_upstream_peaks_file'	=>	1,
		'_22kb_upstream_peaks_file'	=>	1,
		'_21kb_upstream_peaks_file'	=>	1,
		'_20kb_upstream_peaks_file'	=>	1,
		'_19kb_upstream_peaks_file'	=>	1,
		'_18kb_upstream_peaks_file'	=>	1,
		'_17kb_upstream_peaks_file'	=>	1,
		'_16kb_upstream_peaks_file'	=>	1,
		'_15kb_upstream_peaks_file'	=>	1,
		'_14kb_upstream_peaks_file'	=>	1,
		'_13kb_upstream_peaks_file'	=>	1,
		'_12kb_upstream_peaks_file'	=>	1,
		'_11kb_upstream_peaks_file'	=>	1,
		'_10kb_upstream_peaks_file'	=>	1,
		'_9kb_upstream_peaks_file'	=>	1,
		'_8kb_upstream_peaks_file'	=>	1,
		'_7kb_upstream_peaks_file'	=>	1,
		'_6kb_upstream_peaks_file'	=>	1,
		'_5kb_upstream_peaks_file'	=>	1,
		'_4kb_upstream_peaks_file'	=>	1,
		'_3kb_upstream_peaks_file'	=>	1,
		'_2kb_upstream_peaks_file'	=>	1,
		'_1kb_upstream_peaks_file'	=>	1,
		'_5prime_utr_peaks_file'	=>	1,
		'_exons_peaks_file'	=>	1,
		'_introns_peaks_file'	=>	1,
		'_3prime_utr_peaks_file'	=>	1,
		'_gene_body_0_to_10_peaks_file'	=>	1,
		'_gene_body_10_to_20_peaks_file'	=>	1,
		'_gene_body_20_to_30_peaks_file'	=>	1,
		'_gene_body_30_to_40_peaks_file'	=>	1,
		'_gene_body_40_to_50_peaks_file'	=>	1,
		'_gene_body_50_to_60_peaks_file'	=>	1,
		'_gene_body_60_to_70_peaks_file'	=>	1,
		'_gene_body_70_to_80_peaks_file'	=>	1,
		'_gene_body_80_to_90_peaks_file'	=>	1,
		'_gene_body_90_to_100_peaks_file'	=>	1,
		'_1kb_downstream_peaks_file'	=>	1,
		'_2kb_downstream_peaks_file'	=>	1,
		'_3kb_downstream_peaks_file'	=>	1,
		'_4kb_downstream_peaks_file'	=>	1,
		'_5kb_downstream_peaks_file'	=>	1,
		'_6kb_downstream_peaks_file'	=>	1,
		'_7kb_downstream_peaks_file'	=>	1,
		'_8kb_downstream_peaks_file'	=>	1,
		'_9kb_downstream_peaks_file'	=>	1,
		'_10kb_downstream_peaks_file'	=>	1,
		'_11kb_downstream_peaks_file'	=>	1,
		'_12kb_downstream_peaks_file'	=>	1,
		'_13kb_downstream_peaks_file'	=>	1,
		'_14kb_downstream_peaks_file'	=>	1,
		'_15kb_downstream_peaks_file'	=>	1,
		'_16kb_downstream_peaks_file'	=>	1,
		'_17kb_downstream_peaks_file'	=>	1,
		'_18kb_downstream_peaks_file'	=>	1,
		'_19kb_downstream_peaks_file'	=>	1,
		'_20kb_downstream_peaks_file'	=>	1,
		'_21kb_downstream_peaks_file'	=>	1,
		'_22kb_downstream_peaks_file'	=>	1,
		'_23kb_downstream_peaks_file'	=>	1,
		'_24kb_downstream_peaks_file'	=>	1,
		'_25kb_downstream_peaks_file'	=>	1,
		'_26kb_downstream_peaks_file'	=>	1,
		'_27kb_downstream_peaks_file'	=>	1,
		'_28kb_downstream_peaks_file'	=>	1,
		'_29kb_downstream_peaks_file'	=>	1,
		'_30kb_downstream_peaks_file'	=>	1,
		'_31kb_downstream_peaks_file'	=>	1,
		'_32kb_downstream_peaks_file'	=>	1,
		'_33kb_downstream_peaks_file'	=>	1,
		'_34kb_downstream_peaks_file'	=>	1,
		'_35kb_downstream_peaks_file'	=>	1,
		'_36kb_downstream_peaks_file'	=>	1,
		'_37kb_downstream_peaks_file'	=>	1,
		'_38kb_downstream_peaks_file'	=>	1,
		'_39kb_downstream_peaks_file'	=>	1,
		'_40kb_downstream_peaks_file'	=>	1,
		'_41kb_downstream_peaks_file'	=>	1,
		'_42kb_downstream_peaks_file'	=>	1,
		'_43kb_downstream_peaks_file'	=>	1,
		'_44kb_downstream_peaks_file'	=>	1,
		'_45kb_downstream_peaks_file'	=>	1,
		'_46kb_downstream_peaks_file'	=>	1,
		'_47kb_downstream_peaks_file'	=>	1,
		'_48kb_downstream_peaks_file'	=>	1,
		'_49kb_downstream_peaks_file'	=>	1,
		'_50kb_downstream_peaks_file'	=>	1,
		'_51kb_downstream_peaks_file'	=>	1,
		'_52kb_downstream_peaks_file'	=>	1,
		'_53kb_downstream_peaks_file'	=>	1,
		'_54kb_downstream_peaks_file'	=>	1,
		'_55kb_downstream_peaks_file'	=>	1,
		'_56kb_downstream_peaks_file'	=>	1,
		'_57kb_downstream_peaks_file'	=>	1,
		'_58kb_downstream_peaks_file'	=>	1,
		'_59kb_downstream_peaks_file'	=>	1,
		'_60kb_downstream_peaks_file'	=>	1,
		'_61kb_downstream_peaks_file'	=>	1,
		'_62kb_downstream_peaks_file'	=>	1,
		'_63kb_downstream_peaks_file'	=>	1,
		'_64kb_downstream_peaks_file'	=>	1,
		'_65kb_downstream_peaks_file'	=>	1,
		'_66kb_downstream_peaks_file'	=>	1,
		'_67kb_downstream_peaks_file'	=>	1,
		'_68kb_downstream_peaks_file'	=>	1,
		'_69kb_downstream_peaks_file'	=>	1,
		'_70kb_downstream_peaks_file'	=>	1,
		'_71kb_downstream_peaks_file'	=>	1,
		'_72kb_downstream_peaks_file'	=>	1,
		'_73kb_downstream_peaks_file'	=>	1,
		'_74kb_downstream_peaks_file'	=>	1,
		'_75kb_downstream_peaks_file'	=>	1,
		'_76kb_downstream_peaks_file'	=>	1,
		'_77kb_downstream_peaks_file'	=>	1,
		'_78kb_downstream_peaks_file'	=>	1,
		'_79kb_downstream_peaks_file'	=>	1,
		'_80kb_downstream_peaks_file'	=>	1,
		'_81kb_downstream_peaks_file'	=>	1,
		'_82kb_downstream_peaks_file'	=>	1,
		'_83kb_downstream_peaks_file'	=>	1,
		'_84kb_downstream_peaks_file'	=>	1,
		'_85kb_downstream_peaks_file'	=>	1,
		'_86kb_downstream_peaks_file'	=>	1,
		'_87kb_downstream_peaks_file'	=>	1,
		'_88kb_downstream_peaks_file'	=>	1,
		'_89kb_downstream_peaks_file'	=>	1,
		'_90kb_downstream_peaks_file'	=>	1,
		'_91kb_downstream_peaks_file'	=>	1,
		'_92kb_downstream_peaks_file'	=>	1,
		'_93kb_downstream_peaks_file'	=>	1,
		'_94kb_downstream_peaks_file'	=>	1,
		'_95kb_downstream_peaks_file'	=>	1,
		'_96kb_downstream_peaks_file'	=>	1,
		'_97kb_downstream_peaks_file'	=>	1,
		'_98kb_downstream_peaks_file'	=>	1,
		'_99kb_downstream_peaks_file'	=>	1,
		'_100kb_downstream_peaks_file'	=>	1,
	};
	foreach my $column (keys %{$available_genomes_insert}) {
		cmp_ok($valid_columns->{$column}, '==', 1, 
			'The column is valid')
		|| print "$column is not valid\n";
	}

	# Test to make sure the database is empty
	cmp_ok($schema->resultset('AvailableGenome')->all, '==', 0, 'The database is empty');

	# Test to make sure the test_update object can perform the
	# PeaksToGenes::Update::update_database function
	can_ok($test_update, 'update_database');

	$test_update->update_database($available_genomes_insert,
		$chromosome_sizes_fh);
	# Test to make sure a line has been added to the database.
	cmp_ok($schema->resultset('AvailableGenome')->all, '==', 1, 'The database has been updated');

	# Test to make sure that the chromosome sizes file has been added
	my $chromosome_sizes_database_fh =
	$schema->resultset('ChromosomeSize')->find(
		{
			genome_id	=>	1
		}
	)->chromosome_sizes_file;
	ok( -r $chromosome_sizes_database_fh, 
		'The file entered in the database for the chromosome sizes is readable');

	# Reset the database again
	`$FindBin::Bin/../install_database.pl`;

	# Create a new instance of PeaksToGenes::Update in order to test the
	# PeaksToGenes::Update::update function
	my $full_update = PeaksToGenes::Update->new(
		genome	=>	'mm9',
		schema	=>	$schema,
	);

	# Test to make sure the database is empty
	cmp_ok($schema->resultset('AvailableGenome')->all, '==', 0, 'The database is empty');
	$full_update->update;

	# Test to make sure a line has been added to the database.
	cmp_ok($schema->resultset('AvailableGenome')->all, '==', 1, 'The database has been updated');

	# Reset the database
	`$FindBin::Bin/../install_database.pl`;
}

done_testing;
