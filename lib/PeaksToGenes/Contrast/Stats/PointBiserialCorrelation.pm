package PeaksToGenes::Contrast::Stats::PointBiserialCorrelation 0.001;

use Moose;
use Carp;
use Parallel::ForkManager;
use Data::Dumper;

has genomic_regions_structure	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

sub correlation_coefficient {
	my $self = shift;

	# Pre-define a Hash Ref to hold the results of each test
	my $test_results = {};

	# Create a new thread manager using the number of processors defined by
	# the user to be the maximum number of allowed threads
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be executed at the end of each thread, so that
	# the test results are stored in the test_results Hash Ref
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$test_results->{$data_structure->{'genomic_region'}}{$data_structure->{'type'}}
			= $data_structure->{'point_biserial'};
		}
	);

	# Iterate through the genomic_regions_structure and execute the tests,
	# running a new thread for each data type in each region
	foreach my $genomic_region ( keys
		%{$self->genomic_regions_structure->{'test_genes'}} )
	{
		foreach my $type ( keys
			%{$self->genomic_regions_structure->{'test_genes'}{$genomic_region}}
		) {

			# Begin a new thread if there is one available
			$pm->start and next;

			# Run the
			# PeaksToGenes::Contrast::Stats::PointBiserialCorrelation::extract_mean_and_number
			# subroutine to get the mean value and number of observations
			# for both the test genes and the background genes
			my ($test_mean, $test_number) =
			$self->extract_mean_and_number($self->genomic_regions_structure->{'test_genes'}{$genomic_region}{$type});
			my ($background_mean, $background_number) =
			$self->extract_mean_and_number($self->genomic_regions_structure->{'background_genes'}{$genomic_region}{$type});

			# If the number of values in either array is zero, end the
			# thread storing 'undetermined' as the value for the point
			# biserial correlation coefficient
			if ( ! $test_number || ! $background_number ) {
				$pm->finish(0, {
						genomic_region	=>	$genomic_region,
						type			=>	$type,
						point_biserial	=>	'undetermined',
					}
				);
			} else {

				# Determine the ratio of the total sample corresponding to the
				# test genes, and the ratio of the total sample corresponding
				# to the background genes
				my $test_proportion = $test_number / ($test_number +
					$background_number
				);
				my $background_proportion = $background_number / ($test_number +
					$background_number
				);

				# Calculate the standard deviation of all the observations
				# using the
				# PeaksToGenes::Contrast::Stats::PointBiserialCorrelation::standard_deviation
				# subroutine
				my $standard_deviation =
				$self->standard_deviation($self->genomic_regions_structure->{'test_genes'}{$genomic_region}{$type},
					$self->genomic_regions_structure->{'background_genes'}{$genomic_region}{$type}
				);

				# The point biserial correlation coefficient is calculate
				# by dividing the difference between the mean values by the
				# standard deviation, then multiplying this value by the
				# square root of the product of the proportions
				my $point_biserial_correlation_coefficient = (($test_mean -
						$background_mean) / $standard_deviation ) * ( sqrt(
						$test_proportion * $background_proportion )
				);

				$pm->finish(0, {
						genomic_region	=>	$genomic_region,
						type			=>	$type,
						point_biserial	=>
						$point_biserial_correlation_coefficient,
					}
				);
			}
		}
	}

	$pm->wait_all_children;

	return $test_results;

}

sub extract_mean_and_number {
	my ($self, $data_array) = @_;

	# Pre-define integer values for the mean value for this array, and the
	# number of observations in the array
	my $mean = 0;
	my $number = 0;

	# Iterate through the array, adding each value to the mean and
	# increasing the number by one for each value
	foreach my $data_value (@$data_array) {
		$mean += $data_value;
		$number++;
	}

	# Calculate the mean by dividing the sum of all the values in the array
	# (currently the value of mean) by the number of values in the array
	if ( $number ) {
		$mean = $mean / $number;
		return ($mean, $number);
	} else {
		# If there are no values in the array, return zeros to the main
		# subroutine
		return (0, 0);
	}
}

sub standard_deviation {
	my ($self, $array, $second_array) = @_;

	# Combine the two arrays (it does not matter which sample is which to
	# calculate the standard deviation)
	push(@$array, @$second_array);

	# Use the
	# PeaksToGenes::Contrast::Stats::PointBiserialCorrelation::extract_mean_and_number
	# subroutine to extract the total mean and total number of observations
	my ($mean, $number) = $self->extract_mean_and_number($array);

	# Pre-declare an integer value to hold the sum of the squared
	# differences
	my $sum_of_squared_differences = 0;

	# Iterate through the observed values, calculate the mean difference
	# and add it to the sum_of_squared_differences
	foreach my $observed_value (@$array) {
		$sum_of_squared_differences += (($observed_value - $mean) ** 2);
	}

	# Calculate the mean of the squared differences by dividing by the
	# total number of observations
	my $mean_of_squared_differences = $sum_of_squared_differences /
	$number;

	# The variance is then the square root of the mean of squared
	# differences. Return this value to the main subroutine
	return ( sqrt($mean_of_squared_differences));
}

1;
