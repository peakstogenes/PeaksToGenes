package PeaksToGenes::Contrast::Stats::Wilcoxon 0.001;

use Moose;
use Carp;
use Statistics::Test::WilcoxonRankSum;
use Parallel::ForkManager;
use Data::Dumper;

has genomic_regions_structure	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

sub rank_sum_test {
	my $self = shift;

	# Pre-declare a Hash Ref to store the test results
	my $test_results = {};

	# Copy the genomic_regions_structure into a scalar Hash Ref for
	# slightly easier access
	my $genomic_regions_structure = $self->genomic_regions_structure;

	# Define the maximum number of processes that can be running in
	# parallel
	my $max_procs = 50;

	# Create a new instance of Parallel::ForkManager
	my $pm = new Parallel::ForkManager($max_procs);

	# Iterate through the genomic_regions_structure, for each region, a
	# rank sum test will be performed comparing the information extracted
	# from the test genes compared to the background genes.
	foreach my $genomic_region (keys
		%{$genomic_regions_structure->{'test_genes'}} ) {

		# Run the test_arrays subroutine to determine if either dataset
		# contains all zeros, in which case a Wilcoxon test can not be run
		my $test_genes_valid_wilcoxon =
		$self->test_arrays($genomic_regions_structure->{'test_genes'}{$genomic_region}{'peaks_information'});
		my $background_genes_valid_wilcoxon =
		$self->test_arrays($genomic_regions_structure->{'background_genes'}{$genomic_region}{'peaks_information'});
		$pm->start and next;
		if ( $test_genes_valid_wilcoxon && $background_genes_valid_wilcoxon
			) {
			# Create an instance of Statistics::Test::WilcoxonRankSum for the
			# peak scores test. Pre-define the exact_upto value to the combined
			# size of the lists up for comparison.
			my $peak_scores_wilcoxon = Statistics::Test::WilcoxonRankSum->new(
				{
					exact_upto	=>
					(@{$genomic_regions_structure->{'test_genes'}{$genomic_region}{'peaks_information'}}
						+
						@{$genomic_regions_structure->{'background_genes'}{$genomic_region}{'peaks_information'}})
				}
			);
			$peak_scores_wilcoxon->load_data(
				$genomic_regions_structure->{'test_genes'}{$genomic_region}{'peaks_information'},
				$genomic_regions_structure->{'background_genes'}{$genomic_region}{'peaks_information'}
			);

			# Run the test and store the results of the Wilcoxon test in the
			# test_results Hash Ref
			$test_results->{$genomic_region}{'peaks_information'} = {
				probability			=>	$peak_scores_wilcoxon->probability_exact,
				test_obs_exp		=>
				$peak_scores_wilcoxon->rank_sum_for(1),
				background_obs_exp	=>	
				$peak_scores_wilcoxon->rank_sum_for(2),
			};
		} else {
			$test_results->{$genomic_region}{'peaks_information'} = {
				probability			=>	1,
				test_obs_exp		=>	$test_genes_valid_wilcoxon,
				background_obs_exp	=>	$background_genes_valid_wilcoxon,
			};
		}
		$pm->finish;
	}
	$pm->wait_all_children;

	# Return the test_results Hash Ref to the PeaksToGenes::Contrast::Stats
	# controller
	return $test_results;

}

sub test_arrays {
	my ($self, $array) = @_;
	
	# Pre-define a boolean false value for the status of the array
	# containing values other than zero
	my $valid_wilcoxon_array = 0;
	# Iterate through the array, if a value is not equal to zero, set the
	# Boolean valid_wilcoxon_array to true
	foreach my $value (@$array) {
		if ( $value && $value != 0 ) {
			$valid_wilcoxon_array = 1;
		}
	}
	return $valid_wilcoxon_array;
}

1;
