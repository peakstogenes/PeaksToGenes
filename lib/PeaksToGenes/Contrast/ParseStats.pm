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

	# Pre-declare a Hash Ref to hold the Array Ref tables
	my $wilcoxon_hash_ref_of_tables = {};

	foreach my $table_type (qw(number_of_peaks peaks_information)) {

		# Pre-declare an Array Ref for each row
		my $header = ['Result Type' ];
		my $wilcoxon_u = ['Wilcoxon U statistic'];
		my $p_value = ['Maximum p-value'];
		my $neg_log_p_value = ['Negative log maximum p-value'];
		my $correction_factor = ['Correction factor T'];
		my $corrected_wilcoxon_u = ['T-corrected Wilcoxon U statistuc'];
		my $corrected_p_value = ['T-corrected maximum p-value'];
		my $neg_log_corrected_p_value = 
			['Negative log T-corrected maximum p-value'];
		my $background_rank_sum = ['Background genes rank sum'];
		my $test_rank_sum = ['Test genes rank sum'];


		foreach my $genomic_location (@{$self->genomic_index}) {

			# Copy the genomic location to a temporary scalar string,
			# and remove the leading underscore.
			my $temp_genomic_location = $genomic_location;
			$temp_genomic_location =~ s/^_//;

			push(@$header, $temp_genomic_location);
			push(@$wilcoxon_u,
				$results->{$genomic_location}{$table_type}{wilcoxon_test});
			push(@$p_value,
				$results->{$genomic_location}{$table_type}{p_value});
			push(@$neg_log_p_value,
				( -1 *
					log($results->{$genomic_location}{$table_type}{p_value})));
			push(@$correction_factor,
				$results->{$genomic_location}{$table_type}{correction_factor});
			push(@$corrected_wilcoxon_u,
				$results->{$genomic_location}{$table_type}{corrected_wilcoxon_test});
			push(@$corrected_p_value,
				$results->{$genomic_location}{$table_type}{corrected_p_value});
			push(@$neg_log_corrected_p_value,
				( -1 *
					log($results->{$genomic_location}{$table_type}{corrected_p_value})));
			push(@$background_rank_sum,
				$results->{$genomic_location}{$table_type}{background_rank_sum});
			push(@$test_rank_sum,
				$results->{$genomic_location}{$table_type}{test_rank_sum});
		}

		# Add the row data to the Array Ref in the main Hash Ref
		push(@{$wilcoxon_hash_ref_of_tables->{$table_type}},
			join("\n",
				join("\t", @$header),
				join("\t", @$wilcoxon_u),
				join("\t", @$p_value),
				join("\t", @$neg_log_p_value),
				join("\t", @$correction_factor),
				join("\t", @$corrected_wilcoxon_u),
				join("\t", @$corrected_p_value),
				join("\t", @$neg_log_corrected_p_value),
				join("\t", @$background_rank_sum),
				join("\t", @$test_rank_sum),
			)
		);
	}

	return $wilcoxon_hash_ref_of_tables;
}

sub parse_point_biserial {
	my ($self, $results) = @_;

	# Pre-declare a Hash Ref to hold the Array Ref tables
	my $point_biserial_hash_ref_of_tables = {};

	foreach my $table_type (qw(number_of_peaks peaks_information)) {

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
				$results->{$genomic_location}{$table_type}
			);

		}

		# Add the row data to the Array Ref in the main Hash Ref
		push(@{$point_biserial_hash_ref_of_tables->{$table_type}},
			join("\n",
				join("\t", @$header),
				join("\t", @$correlation_coeficcient)
			)
		);
	}

	return $point_biserial_hash_ref_of_tables;
}

sub parse_fisher_anova {
	my ($self, $results) = @_;

	# Pre-declare a Hash Ref to hold the Array Ref tables
	my $anova_hash_ref_of_tables = {};

	foreach my $table_type (qw(number_of_peaks peaks_information)) {

		# Pre-declare an Array Ref for each row
		my $header = ['Result Type' ];
		my $f_statistic = ['F statistic'];
		my $p_value = ['p-value'];
		my $neg_log_p_value = ['Negative log p-value'];
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
			if ( $results->{$genomic_location}{$table_type} 
				=~ /^F/) {
				$results->{$genomic_location}{$table_type} =~ s/,//;
				my ($f_stat_and_df, $p_value_string, $rest_of_stats) = split(/, /,
					$results->{$genomic_location}{$table_type}
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
				$p_value_num ? push(@$neg_log_p_value, (-1 *
						log($p_value_num))) : push(@$neg_log_p_value, 0);
			} else {
				# If there was no result from the ANOVA test, return undef
				push(@$f_statistic, 'undef');
				push(@$p_value, 'undef');
				push(@$neg_log_p_value, 'undef');
				push(@$denominator_degrees_of_freedom, 'undef');
				push(@$numerator_degrees_of_freedom, 'undef');
			}
		}

		# Add the row data to the Array Ref in the main Hash Ref
		push(@{$anova_hash_ref_of_tables->{$table_type}},
			join("\n",
				join("\t", @$header),
				join("\t", @$f_statistic),
				join("\t", @$p_value),
				join("\t", @$neg_log_p_value),
				join("\t", @$numerator_degrees_of_freedom),
				join("\t", @$denominator_degrees_of_freedom),
			)
		);
	}

	return $anova_hash_ref_of_tables;
}

1;
