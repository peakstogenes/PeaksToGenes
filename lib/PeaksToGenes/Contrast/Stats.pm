package PeaksToGenes::Contrast::Stats 0.001;

use Moose;
use Carp;
use Data::Dumper;
 
has genomic_regions_structure	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[HashRef[HashRef[ArrayRef[Num]]]]',
	required	=>	1,
);

has statistical_tests	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[Bool]',
	required	=>	1,
);

sub run_statistical_tests {
	my $self = shift;

	# Pre-declare a Hash Ref to hold the results of the statistical tests
	my $test_results = {};

	# If the Wilcoxon Rank-Sum test has been flagged for testing, run the
	# test using PeaksToGenes::Contrast::Stats::Wilcoxon and run the
	# PeaksToGenes::Contrast::Stats::Wilcoxon::rank_sum_test subroutine to
	# return a Hash Ref of P-values for each genomic interval.
	if ($self->statistical_tests->{'wilcoxon'}) {
		my $wilcoxon = PeaksToGenes::Contrast::Stats::Wilcoxon->new(
			genonic_regions_structure	=>
			$self->genomic_regions_structure,
		);

		# Add the results to the test_results Hash Ref
		$test_results->{'wilcoxon'} = $wilcoxon->rank_sum_test;
	}


	# Return the test_results Hash Ref to the PeaksToGenes::Contrast
	# controller module
	return $test_results;
}

1;
