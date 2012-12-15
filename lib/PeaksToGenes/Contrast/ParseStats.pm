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
	
	$parsed_array_refs->{'kruskal_wallis'} =
	$self->parse_kruskal_wallis($self->stats_results->{kruskal_wallis}) if
	($self->stats_results->{kruskal_wallis});
	
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

sub parse_kruskal_wallis {
	my ($self, $results) = @_;

	# Pre-declare an Array Ref to hold the Array Ref tables
	my $kruskal_wallis_array_ref_of_tables = [];

	# Pre-declare an Array Ref for each row
	my $header = ['Result Type' ];
	my $kruskal_wallis_h = ['Kruskal-Wallis H statistic'];
	my $p_value = ['p-value'];

	foreach my $genomic_location (@{$self->genomic_index}) {

		# Copy the genomic location to a temporary scalar string,
		# and remove the leading underscore.
		my $temp_genomic_location = $genomic_location;
		$temp_genomic_location =~ s/^_//;

		push(@$header, $temp_genomic_location);

		# Parse the string contained in the Kruskal-Wallis result
		my ($h_string, $p_string) = split(/, /,
			$results->{$genomic_location}
		);

		my ($h_leader, $h_value) = split(/ = /, $h_string);
		my ($p_leader, $p_val) = split(/ = /, $p_string);

		push(@$kruskal_wallis_h, $h_value);
		push(@$p_value, $p_val);
	}

	# Add the row data to the Array Ref in the main Hash Ref
	push(@$kruskal_wallis_array_ref_of_tables,
		join("\n",
			join("\t", @$header),
			join("\t", @$kruskal_wallis_h),
			join("\t", @$p_value),
		)
	);

	return $kruskal_wallis_array_ref_of_tables;
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
