
# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.

package PeaksToGenes::Contrast::Stats::Wilcoxon 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Statistics::Test::WilcoxonRankSum;
use Statistics::Zed;
use Parallel::ForkManager;
use Data::Dumper;

with 'PeaksToGenes::Database';
 
=head2 rank_sum_test

This subroutine is passed a Hash Ref of binding data and the number of
processors to be used.

=cut

sub rank_sum_test {
    my $self = shift;
    my $data_hash = shift;
    my $processors = shift;

    # Define a Hash Ref to hold the results of the test
    my $results = {};

    # Create a new instance of Parallel::ForkManager with the maximum
    # number of threads being the number of processors defined by the user
    my $pm = Parallel::ForkManager->new($processors);

    # Define a subroutine to be executed at the end of each thread so that
    # the results of the test are stored in the Hash Ref
    $pm->run_on_finish(
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
                $data_structure) = @_;
            if ( $data_structure && $data_structure->{genomic_region} &&
                $data_structure->{wilcoxon} ) {
                $results->{$data_structure->{genomic_region}} = {
                    rank_sum_1          =>
                    $data_structure->{wilcoxon}{rank_sum_1},
                    rank_sum_2          =>
                    $data_structure->{wilcoxon}{rank_sum_2},
                    rank_sum_1_expected         =>
                    $data_structure->{wilcoxon}{rank_sum_1_expected},
                    rank_sum_2_expected         =>
                    $data_structure->{wilcoxon}{rank_sum_2_expected},
                    probability_normal_approx   =>
                    $data_structure->{wilcoxon}{probability_normal_approx},
                    p_value                     =>
                    $data_structure->{p_value}
                }
            }
        }
    );

    foreach my $genomic_region ( keys %{$data_hash} ) {

        # If there is a thread available, start a new one
        $pm->start and next;

        # Create a new instance of Statistics::ANOVA
        my $wilcoxon = Statistics::Test::WilcoxonRankSum->new();

        # Load the data into the wilcoxon object
        $wilcoxon->load_data(
            $data_hash->{$genomic_region}{test_genes},
            $data_hash->{$genomic_region}{background_genes},
        );

        # Get the z-score using the probability_normal_approx method
        $wilcoxon->probability_normal_approx;

        # Create a new instance of Statistics::Zed to convert the z-score into a
        # p-value
        my $zed = Statistics::Zed->new();
        my $stat = $zed->z2p(
            value   =>  $wilcoxon->as_hash->{probability_normal_approx}{z}
        );

        $pm->finish(0, 
            {
                genomic_region      =>  $genomic_region,
                wilcoxon            =>  $wilcoxon->as_hash,
                p_value             =>  $stat
            }
        );
    }

    # Ensure that all of the threads have finished
    $pm->wait_all_children;

    return $results;
}

1;
