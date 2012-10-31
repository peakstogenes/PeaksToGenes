package PeaksToGenes::Contrast::Stats 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Contrast::Stats::PointBiserialCorrelation;
use PeaksToGenes::Contrast::Stats::ANOVA;
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
	default		=>	1,
);

sub run_statistical_tests {
	my $self = shift;

	# Pre-declare a Hash Ref to hold the results of the statistical tests
	my $test_results = {};

	# If the Wilcoxon Rank-Sum test has been flagged for testing, run the
	# PeaksToGenes::Contrast::Stats::RankOrder::rank_order_genomic_regions
	# subroutine to return a structure of rank ordered values for each
	# data type at each relative genomic interval.
	if ( $self->statistical_tests->{'kruskal_wallis'} ) {

		my $kruskal_wallis = PeaksToGenes::Contrast::Stats::ANOVA->new(
			genomic_regions_structure	=>
			$self->genomic_regions_structure,
			processors					=>	$self->processors,
		);

		$test_results->{kruskal_wallis} =
		$kruskal_wallis->kruskal_wallis_anova;

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

		print "\n\nCalculating Point Biserial Correlation Coefficient\n\n";

		$test_results->{'point_biserial'} =
		$point_biserial->correlation_coefficient;
	}

	# If the ANOVA test has been flagged for testing, use the
	# PeaksToGenes::Contrast::Stats::ANOVA::fisher_anova subroutine to run
	# the test
	if ( $self->statistical_tests->{anova} ) {
		my $anova = PeaksToGenes::Contrast::Stats::ANOVA->new(
			genomic_regions_structure	=>
			$self->genomic_regions_structure,
			processors					=>	$self->processors,
		);

		print "\n\nCalculating Fisher-like ANOVA\n\n";

		$test_results->{'anova'} = $anova->fisher_anova;
	}


	# Return the test_results Hash Ref to the PeaksToGenes::Contrast
	# controller module
	return $test_results;
}

1;
