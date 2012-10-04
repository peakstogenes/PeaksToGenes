#!/usr/bin/perl
#
#===============================================================================
#
#         FILE: 01-required.t
#
#  DESCRIPTION: This test script tests the implementation of required
#  				programs needed for the execution of PeaksToGenes
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/04/2012 07:29:54 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use Test::More tests => 12;                      # last test to print

use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;
use File::Which;

BEGIN {
	# Test to make sure that BedTools is installed
	my $intersect_bed_path = which('intersectBed');
	like($intersect_bed_path, qr/intersectBed/, 'intersectBed is found in the $PATH');
	# Test to make sure that intersectBed can be executed by Perl
	ok( -X -x $intersect_bed_path, 'intersectBed is executable');
	# Test to make sure that Sqlite3 is installed
	my $sqlite_path = which('sqlite3');
	like($sqlite_path, qr/sqlite3/, 'Sqlite3 is found in the $PATH');
	# Test to make sure that Sqlite3 can be executed by Perl
	ok( -X -x $sqlite_path, 'Sqlite3 is executable');
	# Test to make sure that MySQL is installed
	my $mysql_path = which('mysql');
	like($mysql_path, qr/mysql/, 'MySQL is found in the $PATH');
	# Test to make sure that MySQL in executable
	ok( -X -x $mysql_path, 'MySQL is executable');
	# Execute an external Perl script 'install_database.pl' to reset the
	# PeaksToGenes database and remove any existing indexes written to file
	`$FindBin::Bin/../install_database.pl`;
	# Create a PeaksToGenes object
	my $peaks_to_genes = PeaksToGenes->new(
		genome	=>	'hg19',
	);
	# Test to make sure the peaks_to_genes object is a PeaksToGenes object
	isa_ok($peaks_to_genes, 'PeaksToGenes');
	# Test to make sure the peaks_to_genes object can perform the schema
	# function and that the schema function returns a
	# DBIx::Class::ResultSet
	can_ok($peaks_to_genes, 'schema');
	my $schema = $peaks_to_genes->schema;
	isa_ok($schema, 'PeaksToGenes::Schema');
	# Test to make sure the schema can return an AvailableGenome result set
	can_ok($schema, 'resultset');
	my $available_genome_results_set =
	$schema->resultset('AvailableGenome');
	isa_ok($available_genome_results_set, 'DBIx::Class::ResultSet');
	# Test to make sure the schema can return an Annotatedpeak result set
	my $annotated_peak_result_set = $schema->resultset('Annotatedpeak');
	isa_ok($annotated_peak_result_set, 'DBIx::Class::ResultSet');
}
