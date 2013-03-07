
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

package PeaksToGenes::Contrast::Aggregate 0.001;

use Moose;
use Carp;
use List::Util qw(sum);
use Data::Dumper;

has genomic_regions_structure	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has genomic_index	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef',
	required	=>	1,
);

sub create_table {
	my $self = shift;

	# Pre-declare a Array Ref to store the Array Ref tables for each data
	# type
	my $array_ref_of_aggregate_tables = [];

	# Pre-declare Array Refs to hold the row data
	my $header = ['Aggregate Source'];
	my $test_genes = ['Test Genes Sum'];
	my $test_genes_mean = ['Test Genes Mean'];
	my $test_genes_sems = ['Test Genes SEM'];
	my $background_genes = ['Background Genes Sum'];
	my $background_genes_mean = ['Background Genes Mean'];
	my $background_genes_sems = ['Background Genes SEM'];

	foreach my $genomic_location (@{$self->genomic_index}) {

		# Use the PeaksToGenes::Contrast::Aggregate::mean_and_sum
		# subroutine to extract the mean and sum from both the
		# background and test genes sets. Then add the values to the
		# row data
		my ($test_genes_sum, $test_genes_mean_val) = $self->mean_and_sum(
			$self->genomic_regions_structure->{test_genes}{$genomic_location}{number_of_peaks}
		);
		my ($background_genes_sum, $background_genes_mean_val) = $self->mean_and_sum(
			$self->genomic_regions_structure->{background_genes}{$genomic_location}{number_of_peaks}
		);
		my $test_genes_sem = $self->sem(
			$self->genomic_regions_structure->{test_genes}{$genomic_location}{number_of_peaks},
			$test_genes_mean_val
		);
		my $background_genes_sem = $self->sem(
			$self->genomic_regions_structure->{background_genes}{$genomic_location}{number_of_peaks},
			$background_genes_mean_val
		);

		push(@$test_genes, $test_genes_sum);
		push(@$test_genes_mean, $test_genes_mean_val);
		push(@$test_genes_sems, $test_genes_sem);
		push(@$background_genes, $background_genes_sum);
		push(@$background_genes_mean, $background_genes_mean_val);
		push(@$background_genes_sems, $background_genes_sem);

		# Copy the location into a temporary scalar, and remove the
		# leading underscore before adding it to the header line
		my $temp_header = $genomic_location;
		$temp_header =~ s/^_//;
		push(@$header, $temp_header);

	}

	# Add the row data to the main Array Ref in the Hash Ref
	push(@$array_ref_of_aggregate_tables,
		join("\n",
			join("\t", @$header),
			join("\t", @$test_genes),
			join("\t", @$background_genes),
			join("\t", @$test_genes_mean),
			join("\t", @$background_genes_mean),
			join("\t", @$test_genes_sems),
			join("\t", @$background_genes_sems),
		)
	);

	return $array_ref_of_aggregate_tables;
}

sub mean_and_sum {
	my ($self, $array) = @_;

	return ( sum(@$array), (sum(@$array) / @$array));
}

sub sem {
	my ($self, $array, $mean) = @_;

	# Pre-declare an Array Ref to hold the squared differences.
	my $squared_differences = [];

	foreach my $value ( @$array ) {
		push(@$squared_differences,
			( $value ** 2 ) - ( $mean ** 2 )
		);
	}

	my $stdev = sqrt (sum(@$squared_differences) / @$squared_differences);

	return ( $stdev / sqrt(@$array) );
}

1;
