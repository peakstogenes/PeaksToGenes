
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

package PeaksToGenes::Contrast::Stats 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

with 'PeaksToGenes::Contrast::Stats::PointBiserialCorrelation';
with 'PeaksToGenes::Contrast::Stats::ANOVA';
with 'PeaksToGenes::Contrast::Stats::Wilcoxon';

=head2 run_statistical_tests

This is the main subroutine called by PeaksToGenes::Contrast, which takes a Hash
Ref of binding data that is indexed by relative genomic location and gene list
type, a Hash Ref of Boolean values that defines which (if any) statistical tests
will be run, and an integer value for the number of processors to be used. This
subroutine returns a Hash Ref of the results of the tests that are run. By
default, the sum, mean, and standard deviation values for both gene lists at
each relative genomic location is the only test run.

=cut

sub run_statistical_tests {
    my $self = shift;
    my $binding_hash = shift;
    my $statistical_test_hash = shift;
    my $processors = shift;

    # Pre-declare a Hash Ref to hold the results of the statistical tests
    my $test_results = {};

    # If the Wilcoxon (Mann-Whitney) test has been set to run, run the
    # Wilcoxon Rank-Sum test by running the rank_sum_test consumed by
    # PeaksToGenes::Contrast::Stats::Wilcoxon
    if ( $statistical_test_hash->{wilcoxon} ) {

        $test_results->{wilcoxon} = $self->rank_sum_test(
            $binding_hash,
            $processors
        );
    }

    # If the Point Biserial Correlation test has been flagged for testing,
    # use
    # PeaksToGenes::Contrast::Stats::PointBiserialCorrelation::correlation_coefficient
    # to run the test
    if ( $statistical_test_hash->{point_biserial} ) {

        $test_results->{'point_biserial'} = $self->correlation_coefficient(
            $binding_hash,
            $processors
        );
    }

    # If the ANOVA test has been flagged for testing, use the
    # PeaksToGenes::Contrast::Stats::ANOVA::fisher_anova subroutine to run
    # the test
    if ( $statistical_test_hash->{anova} ) {

        $test_results->{'anova'} = $self->fisher_anova(
            $binding_hash,
            $processors
        );
    }

    return $test_results;
}

1;
