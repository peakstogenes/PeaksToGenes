package PeaksToGenes::Contrast::Stats 0.001;

use Moose;
use Carp;
use PeaksToGenes::Contrast::Stats::RankOrder;
use PeaksToGenes::Contrast::Stats::Wilcoxon;
use PeaksToGenes::Contrast::Stats::PointBiserialCorrelation;
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

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	sub {
		return 1;
	}
);

sub run_statistical_tests {
	my $self = shift;

	# Pre-declare a Hash Ref to hold the results of the statistical tests
	my $test_results = {};

	# If the Wilcoxon Rank-Sum test has been flagged for testing, run the
	# PeaksToGenes::Contrast::Stats::RankOrder::rank_order_genomic_regions
	# subroutine to return a structure of rank ordered values for each
	# data type at each relative genomic interval.
	my $rank_ordered_genomic_regions = {};
	if ( $self->statistical_tests->{'wilcoxon'} ) {
		my $rank_order = PeaksToGenes::Contrast::Stats::RankOrder->new(
			processors					=>	$self->processors,
			genomic_regions_structure	=>
			$self->genomic_regions_structure,
		);
		$rank_ordered_genomic_regions =
		$rank_order->rank_order_genomic_regions;
	}

	# If the Wilcoxon Rank-Sum test has been flagged for testing, run the
	# test using PeaksToGenes::Contrast::Stats::Wilcoxon and run the
	# PeaksToGenes::Contrast::Stats::Wilcoxon::rank_sum_test subroutine to
	# return a Hash Ref of P-values for each genomic interval.
	if ($self->statistical_tests->{'wilcoxon'}) {
		my $wilcoxon = PeaksToGenes::Contrast::Stats::Wilcoxon->new(
			rank_ordered_genomic_regions	=>
			$rank_ordered_genomic_regions,
			processors						=>	$self->processors
		);

		# Add the results to the test_results Hash Ref
		$test_results->{'wilcoxon'} = $wilcoxon->rank_sum_test;
	}

	# If the Point Biserial Correlation test has been flagged for testing,
	# use
	# PeaksToGenes::Contrast::Stats::PointBiserialCorrelation::correlation_coefficient
	# to run the test
	if ( $self->statistical_tests->{point_biserial} ) {
		my $point_biserial =
		PeaksToGenes::Contrast::Stats::PointBiserialCorrelation->new(
			genomic_regions_structure	=>
			$self->genomic_regions_structure,
			processors					=>	$self->processors,
		);
		$test_results->{'point_biserial'} =
		$point_biserial->correlation_coefficient;
	}


	# Return the test_results Hash Ref to the PeaksToGenes::Contrast
	# controller module
	return $test_results;
}

1;
