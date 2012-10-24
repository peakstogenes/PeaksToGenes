package PeaksToGenes::Contrast::Stats::Wilcoxon 0.001;

use Moose;
use Carp;
use PeaksToGenes::Contrast::Stats::StandardNormalTable;
use Parallel::ForkManager;
use Data::Dumper;

has rank_ordered_genomic_regions	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

sub rank_sum_test {
	my $self = shift;

	# Pre-declare a Hash Ref to store the test results
	my $test_results = {};

	# Create a new instance of Parallel::ForkManager based on the number of
	# processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be run on the completion of each thread, so
	# that the data from the Wilcoxon rank sum  test is stored in the
	# test_results hash
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$test_results->{$data_structure->{'genomic_region'}}{$data_structure->{'type'}}
			= $data_structure->{'rank_sum'};
		}
	);

	# Iterate through the rank_ordered_genomic_regions structure, and
	# perform the Wilcoxon rank sum test on the ordered arrays
	foreach my $genomic_region ( keys
		 %{$self->rank_ordered_genomic_regions} ) {

		 foreach my $type ( keys
			 %{$self->rank_ordered_genomic_regions->{$genomic_region}} ) {

			 # Start a new thread if available
			 $pm->start and next;

			 # Use the PeaksToGenes::Contrast::Stats::Wilcoxon::rank_sum
			 # subroutine to calculate the rank sum for the test and
			 # background genes, as well as the number in each group
			 my ($test_rank_sum, $background_rank_sum,
				 $number_of_test_genes, $number_of_background_genes) =
			 $self->rank_sum($self->rank_ordered_genomic_regions->{$genomic_region}{$type});

			 # Calculate the total number of observations
			 my $total_genes = $number_of_test_genes +
			 $number_of_background_genes;

			 # Calculate the test statistic
			 my $wilcoxon_test = (12 / ($total_genes * ($total_genes + 1) )
				 ) * 
				 (
					 ($number_of_test_genes * ((($test_rank_sum /
									 $number_of_test_genes) -
								 (($total_genes + 1) / 2)) ** 2)) + 
					 ($number_of_background_genes * ((($background_rank_sum
									 / $number_of_background_genes) -
								 (($total_genes + 1) / 2)) ** 2))
				 );
				 
			 # Because there may be many ties in the dataset, a correction
			 # factor must be calculated. Use the
			 # PeaksToGenes::Contrast::Stats::Wilcoxon::correction_factor
			 # subroutine to calculate the factor
			 my $correction_factor = 
			 $self->correction_factor($self->rank_ordered_genomic_regions->{$genomic_region}{$type},
				 $number_of_test_genes, $number_of_background_genes
			 );

			 my $corrected_wilcoxon_test = $wilcoxon_test / $correction_factor;

			 # With two degrees of freedom, approximate the p-value by
			 # equating the Wilcoxon test value to a chi-squared
			 # distribution using the
			 # PeaksToGenes::Contrast::Stats::Wilcoxon::approximate_pvalue
			 my $p_value = $self->approximate_pvalue($wilcoxon_test);
			 my $corrected_p_value =
			 $self->approximate_pvalue($corrected_wilcoxon_test);

			 $pm->finish(0, {
					 genomic_region	=>	$genomic_region,
					 type			=>	$type,
					 rank_sum		=>	{
						 test_rank_sum				=>	$test_rank_sum,
						 background_rank_sum		=>
							 $background_rank_sum,
						 p_value					=>	$p_value,
						 wilcoxon_test				=>	$wilcoxon_test,
						 correction_factor			=>	$correction_factor,
						 corrected_wilcoxon_test	=>
							 $corrected_wilcoxon_test,
						 corrected_p_value			=>	$corrected_p_value,
					 }
				 }
			 );
		 }
	 }

	 $pm->wait_all_children;

	 return $test_results;
}

sub rank_sum {
	my ($self, $rank_sum_array) = @_;

	# Pre-define scalar variables to hold the rank sum values for the test
	# and background genes
	my $test_rank_sum = 0;
	my $background_rank_sum = 0;

	# Pre-define scalar variables to hold the number of values in each
	# category
	my $number_of_test_genes = 0;
	my $number_of_background_genes = 0;

	foreach my $rank_array (@$rank_sum_array) {
		
		# If the rank_array is from the test genes, add the rank to the
		# test_rank_sum and increase the number_of_test_genes
		if ( $rank_array->[2]->{name} eq 'test' ) {
			$number_of_test_genes++;
			$test_rank_sum += $rank_array->[0];
		}

		# If the rank_array is from the background genes, add the rank to
		# the background_rank_sum and increase the
		# number_of_background_genes
		elsif ( $rank_array->[2]->{name} eq 'background' ) {
			$number_of_background_genes++;
			$background_rank_sum += $rank_array->[0];
		}

	}

	return ($test_rank_sum, $background_rank_sum, $number_of_test_genes,
		$number_of_background_genes);
}

sub correction_factor {
	my ($self, $rank_array, $number_of_test_genes,
		$number_of_background_genes) = @_;


	# Pre-declare a Hash Ref to hold the tie data
	my $ties = {};

	# Iterate through the rank_array and for each value which has a tie,
	# increase the number of ties. By default, each seen value will be set
	# to one, when a tie is seen that number if ties is increased by one.
	foreach my $rank_item (@$rank_array) {
		if ( $ties->{$rank_item->[0]} ) {
			$ties->{$rank_item->[0]}++;
		} else {
			$ties->{$rank_item->[0]} = 1;
		}
	}

	# Pre-declare an Array Ref to hold the number of ties per rank
	my $ties_per_rank = [];

	# Iterate through the ties Hash Ref, and store any values greater than
	# 2 (has a tie) in the ties_per_rank Array Ref
	foreach my $rank (keys %$ties) {
		push (@$ties_per_rank, $ties->{$rank}) if ( $ties->{$rank} >= 2 );
	}

	# Pre-declare a scalar integer for the correction factor
	my $correction_factor = 1;

	# Calculate the total number of observations in the test
	my $total_genes = $number_of_test_genes + $number_of_background_genes;

	# Only calculate the factor if there are any ties, otherwise 1 will be
	# returned
	if ( @$ties_per_rank ) {

		# Pre-define a scalar integer to hold the sum of the ties
		my $sum_of_ties = 0;
		foreach my $number_of_ties (@$ties_per_rank) {
			$sum_of_ties += (($number_of_ties ** 3) - $number_of_ties);
		}

		# Normalize by the total number of observations and subtract from
		# one
		$correction_factor -= ($sum_of_ties / (($total_genes ** 3) -
				$total_genes)
		);

	}

	return $correction_factor;
}

sub approximate_pvalue {
	my ($self, $wilcoxon_test) = @_;

	# Using estimates for one degree of freedom, return an approximate
	# p-value
	if ( $wilcoxon_test <= 0.004 ) {
		return 1;
	} elsif ( $wilcoxon_test < 0.02 ) {
		return 0.95;
	} elsif ( $wilcoxon_test < 0.06 ) {
		return 0.90;
	} elsif ( $wilcoxon_test < 0.15 ) {
		return 0.80;
	} elsif ( $wilcoxon_test < 0.46 ) {
		return 0.70;
	} elsif ( $wilcoxon_test < 1.07 ) {
		return 0.50;
	} elsif ( $wilcoxon_test < 1.64 ) {
		return 0.30;
	} elsif ( $wilcoxon_test < 2.71 ) {
		return 0.20;
	} elsif ( $wilcoxon_test < 3.84 ) {
		return 0.10;
	} elsif ( $wilcoxon_test < 6.64 ) {
		return 0.05;
	} elsif ( $wilcoxon_test < 10.83 ) {
		return 0.01;
	} else {
		return 0.001;
	}
}

1;
