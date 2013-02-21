#!/usr/bin/perl


# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.


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
