package PeaksToGenes::Contrast::Stats::Wilcoxon 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Statistics::Test::WilcoxonRankSum;
use Statistics::Zed;
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
	default		=>	1,
);

sub rank_sum_test {
	my $self = shift;

	# Define a Hash Ref to hold the results of the test
	my $test_results = {};

	# Create a new instance of Parallel::ForkManager with the maximum
	# number of threads being the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be executed at the end of each thread so that
	# the results of the test are stored in the Hash Ref
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			if ( $data_structure && $data_structure->{genomic_region} &&
				$data_structure->{wilcoxon} ) {
				$test_results->{$data_structure->{genomic_region}} = {
					rank_sum_1			=>
					$data_structure->{wilcoxon}{rank_sum_1},
					rank_sum_2			=>
					$data_structure->{wilcoxon}{rank_sum_2},
					rank_sum_1_expected			=>
					$data_structure->{wilcoxon}{rank_sum_1_expected},
					rank_sum_2_expected			=>
					$data_structure->{wilcoxon}{rank_sum_2_expected},
					probability_normal_approx	=>
					$data_structure->{wilcoxon}{probability_normal_approx},
					p_value						=>
					$data_structure->{p_value}
				}
			}
		}
	);

	foreach my $genomic_region ( keys
		%{$self->genomic_regions_structure->{'test_genes'}} ) {

			# If there is a thread available, start a new one
			$pm->start and next;

			# Create a new instance of Statistics::ANOVA
			my $wilcoxon = Statistics::Test::WilcoxonRankSum->new();

			# Load the data into the wilcoxon object
			$wilcoxon->load_data(
				$self->genomic_regions_structure->{'test_genes'}{$genomic_region}{number_of_peaks},
				$self->genomic_regions_structure->{'background_genes'}{$genomic_region}{number_of_peaks},
			);

			$wilcoxon->probability_normal_approx;

			my $zed = Statistics::Zed->new();
			my $stat = $zed->z2p(
				value	=>	$wilcoxon->as_hash->{probability_normal_approx}{z}
			);

			$pm->finish(0, 
				{
					genomic_region		=>	$genomic_region,
					wilcoxon			=>	$wilcoxon->as_hash,
					'p_value'			=>	$stat
				}
			);
	}

	# Ensure that all of the threads have finished
	$pm->wait_all_children;

	return $test_results;
}

1;
