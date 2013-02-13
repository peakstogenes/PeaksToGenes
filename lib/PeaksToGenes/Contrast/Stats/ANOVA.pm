package PeaksToGenes::Contrast::Stats::ANOVA 0.001;

use Moose;
use Carp;
use Parallel::ForkManager;
use Statistics::ANOVA;
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

sub fisher_anova {
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
				$data_structure->{anova} ) {
				$test_results->{$data_structure->{genomic_region}} =
				$data_structure->{anova};
			}
		}
	);

	# Iterate through the genomic regions structure, and perform the
	# Fisher-esque ANOVA test comparing the test genes to the background
	# genes
	foreach my $genomic_region ( keys
		%{$self->genomic_regions_structure->{'test_genes'}} ) {

			# If there is a thread available, start a new one
			$pm->start and next;

			# Create a new instance of Statistics::ANOVA
			my $anova = Statistics::ANOVA->new();

			# Load the data into the ANOVA object
			$anova->load(
				{
					'test_genes'		=>
					$self->genomic_regions_structure->{'test_genes'}{$genomic_region}{number_of_peaks},
					'background_genes'	=>
					$self->genomic_regions_structure->{'background_genes'}{$genomic_region}{number_of_peaks},
				}
			);

			$anova->anova(
				independent	=>	1,
				parametric	=>	1,
				alpha		=>	0.05,
				ordinal		=>	0,
			);

			$pm->finish(0, 
				{
					genomic_region		=>	$genomic_region,
					anova				=>	$anova->string(
						precision_p 	=>	10, 
						precision_s 	=>	10,
						mse				=>	1, 
						eta_squared		=>	1, 
						omega_squared	=> 	1,
					),
				}
			);
	}

	# Ensure that all of the threads have finished
	$pm->wait_all_children;

	return $test_results;
}

1;
