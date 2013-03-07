
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

package PeaksToGenes::Contrast::ParseStats 0.001;

use Moose;
use Carp;
use Data::Dumper;

has stats_results	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has genomic_index	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef',
	required	=>	1,
);


sub parse_stats {
	my $self = shift;
	
	# Run the PeaksToGenes::Contrast::ParseStats::lowercase_keys subroutine
	# to be able to access the results Hash Refs with the keys
	$self->lowercase_keys;

	# Pre-defined a Hash Ref that will hold the parsed Array Refs for each
	# statistical test
	my $parsed_array_refs = {};

	# Check the stats_results Hash Ref for each statistical test, calling
	# the cognate parsing subroutine to parse the contents of the test
	# results
	
	$parsed_array_refs->{'wilcoxon'} =
	$self->parse_wilcoxon($self->stats_results->{wilcoxon}) if
	($self->stats_results->{wilcoxon});
	
	$parsed_array_refs->{point_biserial} =
	$self->parse_point_biserial($self->stats_results->{point_biserial}) if
	($self->stats_results->{point_biserial});
	
	$parsed_array_refs->{anova} =
	$self->parse_fisher_anova($self->stats_results->{anova}) if
	($self->stats_results->{anova});

	return $parsed_array_refs;
}

sub lowercase_keys {
	my $self = shift;
	
	for (my $i = 0; $i < @{$self->genomic_index}; $i++) {
		$self->genomic_index->[$i] = lc($self->genomic_index->[$i]);
	}
}

sub parse_wilcoxon {
	my ($self, $results) = @_;

	# Pre-declare an Array Ref to hold the Array Ref tables
	my $wilcoxon_array_ref_of_tables = [];

	# Pre-declare an Array Ref for each row
	my $header = ['Result Type' ];
	my $wilcoxon_z_score = ['Wilcoxon Z-score'];
	my $p_value = ['p-value'];

	foreach my $genomic_location (@{$self->genomic_index}) {

		# Copy the genomic location to a temporary scalar string,
		# and remove the leading underscore.
		my $temp_genomic_location = $genomic_location;
		$temp_genomic_location =~ s/^_//;

		push(@$header, $temp_genomic_location);

		# Add the p-value
		push(@$p_value, $results->{$genomic_location}{p_value});

		# Add the Z-score
		push(@$wilcoxon_z_score,
			$results->{$genomic_location}{probability_normal_approx}{z}
		);
	}

	# Add the row data to the Array Ref in the main Hash Ref
	push(@$wilcoxon_array_ref_of_tables,
		join("\n",
			join("\t", @$header),
			join("\t", @$wilcoxon_z_score),
			join("\t", @$p_value),
		)
	);

	return $wilcoxon_array_ref_of_tables;
}

sub parse_point_biserial {
	my ($self, $results) = @_;

	# Pre-declare a Hash Ref to hold the Array Ref tables
	my $point_biserial_array_ref_of_tables = [];

	# Pre-declare an Array Ref for each row
	my $header = ['Result Type' ];
	my $correlation_coeficcient = ['Correlation coeficcient'];

	foreach my $genomic_location (@{$self->genomic_index}) {

		# Copy the genomic location to a temporary scalar string,
		# and remove the leading underscore.
		my $temp_genomic_location = $genomic_location;
		$temp_genomic_location =~ s/^_//;

		push(@$header, $temp_genomic_location);
		push(@$correlation_coeficcient,
			$results->{$genomic_location}
		);

	}

	# Add the row data to the Array Ref in the main Hash Ref
	push(@$point_biserial_array_ref_of_tables,
		join("\n",
			join("\t", @$header),
			join("\t", @$correlation_coeficcient)
		)
	);

	return $point_biserial_array_ref_of_tables;
}

sub parse_fisher_anova {
	my ($self, $results) = @_;

	# Pre-declare a Hash Ref to hold the Array Ref tables
	my $anova_array_ref_of_tables = [];

	# Pre-declare an Array Ref for each row
	my $header = ['Result Type' ];
	my $f_statistic = ['F statistic'];
	my $p_value = ['p-value'];
	my $numerator_degrees_of_freedom = 
		['Numerator degrees of freedom'];
	my $denominator_degrees_of_freedom = 
		['Denominator_degrees_of_freedom'];

	foreach my $genomic_location (@{$self->genomic_index}) {

		# Copy the genomic location to a temporary scalar string,
		# and remove the leading underscore.
		my $temp_genomic_location = $genomic_location;
		$temp_genomic_location =~ s/^_//;

		push(@$header, $temp_genomic_location);

		# This section contains a series of regular expression, and
		# split functions to extract the statistical information held
		# in a string from Statistics::Test::ANOVA.
		if ( $results->{$genomic_location}
			=~ /^F/) {
			$results->{$genomic_location} =~ s/,//;
			my ($f_stat_and_df, $p_value_string, $rest_of_stats) = split(/, /,
				$results->{$genomic_location}
			);
			my ($df, $f_stat_num) = split(/ = /, $f_stat_and_df);
			push(@$f_statistic, $f_stat_num);
			$df =~ s/\(//g;
			$df =~ s/\)//g;
			$df =~ s/F//g;
			my ($numerator, $denominator) = split(/ /, $df);
			push(@$numerator_degrees_of_freedom, $numerator);
			push(@$denominator_degrees_of_freedom, $denominator);
			my ($p_string, $p_value_num) = split(/ = /,
				$p_value_string);
			push(@$p_value, $p_value_num);
		} else {

			# If there was no result from the ANOVA test, return undef
			push(@$f_statistic, 'undef');
			push(@$p_value, 'undef');
			push(@$denominator_degrees_of_freedom, 'undef');
			push(@$numerator_degrees_of_freedom, 'undef');
		}
	}

	# Add the row data to the Array Ref in the main Hash Ref
	push(@$anova_array_ref_of_tables,
		join("\n",
			join("\t", @$header),
			join("\t", @$f_statistic),
			join("\t", @$p_value),
			join("\t", @$numerator_degrees_of_freedom),
			join("\t", @$denominator_degrees_of_freedom),
		)
	);

	return $anova_array_ref_of_tables;
}

1;
