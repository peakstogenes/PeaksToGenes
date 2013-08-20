
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
use Math::BigFloat  only =>  'GMP';
use Math::GSL::SF qw/:all/;
use Sort::Rank qw(rank_sort rank_group);
use Parallel::ForkManager;
use Data::Dumper;

with 'PeaksToGenes::Database';

=head2 peaks_to_genes_rank_sum_test

This subroutine is passed a Hash Ref of binding data and the number of
processors to be used.

=cut

sub peaks_to_genes_rank_sum_test {
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

            # Make sure the correct information has been returned
            if ( $data_structure->{location} && 
                defined $data_structure->{z_score} && 
                defined $data_structure->{p_value} ) {
                $results->{$data_structure->{location}}{z_score} =
                $data_structure->{z_score};
                $results->{$data_structure->{location}}{p_value} =
                $data_structure->{p_value};
            }
        }
    );

    # Iterate through the relative genomic regions defined in the data_hash
    foreach my $genomic_location ( keys %{$data_hash} ) {

        # Start a new thread if one is available
        $pm->start and next;

        # Pre-declare an Array Ref to hold the data formatted for Sort::Rank
        my $scores_array = [];

        # Iterate through the data types
        foreach my $data_type ( keys %{$data_hash->{$genomic_location}} ) {

            # Iterate through the enrichment values, add an entry in the scores
            # Array Ref for each one
            foreach my $data_value (
                @{$data_hash->{$genomic_location}{$data_type}} ) {

                # Make sure there was a value
                if ( defined $data_value ) {
                    # Add the score and data type as a Hash Ref
                    push(@{$scores_array},
                        {
                            score   =>  $data_value,
                            name    =>  $data_type,
                        }
                    );
                }
            }
        }

        # Run the 'wilcoxon_rank_sum' subroutine, which returns the Z score and
        # the normal approximation of the p-value
        my ($z_score, $approximate_norm_p) =
        $self->wilcoxon_rank_sum($scores_array);

        # End the thread and return the data
        $pm->finish(0,
            {
                location    =>  $genomic_location,
                z_score     =>  $z_score->bstr(),
                p_value     =>  $approximate_norm_p->bstr(),
            }
        );
    }

#            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
#                $data_structure) = @_;
#            if ( $data_structure && $data_structure->{genomic_region} &&
#                $data_structure->{wilcoxon} ) {
#                $results->{$data_structure->{genomic_region}} = {
#                    rank_sum_1          =>
#                    $data_structure->{wilcoxon}{rank_sum_1},
#                    rank_sum_2          =>
#                    $data_structure->{wilcoxon}{rank_sum_2},
#                    rank_sum_1_expected         =>
#                    $data_structure->{wilcoxon}{rank_sum_1_expected},
#                    rank_sum_2_expected         =>
#                    $data_structure->{wilcoxon}{rank_sum_2_expected},
#                    probability_normal_approx   =>
#                    $data_structure->{wilcoxon}{probability_normal_approx},
#                    p_value                     =>
#                    $data_structure->{p_value}
#                }
#            }
#        }
#    );

#    foreach my $genomic_region ( keys %{$data_hash} ) {
#
#        # If there is a thread available, start a new one
#        $pm->start and next;
#
#        # Create a new instance of Statistics::ANOVA
#        my $wilcoxon = Statistics::Test::WilcoxonRankSum->new();
#
#        # Load the data into the wilcoxon object
#        $wilcoxon->load_data(
#            $data_hash->{$genomic_region}{test_genes},
#            $data_hash->{$genomic_region}{background_genes},
#        );
#
#        # Get the z-score using the probability_normal_approx method
#        $wilcoxon->probability_normal_approx;
#
#        # Create a new instance of Statistics::Zed to convert the z-score into a
#        # p-value
#        my $zed = Statistics::Zed->new();
#        my $stat = $zed->z2p(
#            value   =>  $wilcoxon->as_hash->{probability_normal_approx}{z}
#        );
#
#        $pm->finish(0, 
#            {
#                genomic_region      =>  $genomic_region,
#                wilcoxon            =>  $wilcoxon->as_hash,
#                p_value             =>  $stat
#            }
#        );
#    }

    # Ensure that all of the threads have finished
    $pm->wait_all_children;

    return $results;
}

=head2 wilcoxon_rank_sum

This subroutine is passed a data structure that is an Array Ref of Hash Refs.
Each Hash Ref is in the form of score => ###, name =>
['test_genes'|'background_genes']. This subroutine ranks the data, and then runs
the Wilcoxon Rank Sum Test. To determine the p-value a normal approximation is
used, which is corrected when ties are present. A cumulative distribution
function is used to convert the Z-score into a two-sided p-value. This
subroutine returns the Z score and the normal approximation of the p-value.

=cut

sub wilcoxon_rank_sum   {
    my $self = shift;
    my $scores = shift;

    # Run _calculate_observation_numbers to get N, n1, n1-name, n2, and n2-name
    my ($total_N, $n1, $n1_name, $n2, $n2_name) =
    $self->_calculate_observation_numbers($scores);

    # Run _rank_sort_binding_data to get a data structure that sorts the binding
    # values by rank
    my $sorted = $self->_rank_sort_binding_data($scores);

    # Run _calculate_w_1 to get the test statistic (W1) for n1.
    my $w1 = $self->_calculate_w_1(
        $sorted,
        $n1,
        $n1_name
    );

    # Run _calculate_e_w_1 to get the expected value for n1: E(W1)
    my $ew1 = $self->_calculate_e_w_1(
        $total_N,
        $n1
    );

    # Run _calculate_v_w to get the variance V(W1) that is corrected when there
    # are ties in the dataset
    my $vw1 = $self->_calculate_v_w(
        $sorted,
        $total_N,
        $n1,
        $n2
    );

    # Run the '_calculate_z_score' subroutine to get the Z score for the data
    my $z = $self->_calculate_z_score(
        $w1, $ew1, $vw1
    );

    # Run the '_approximate_normal_p_value' subroutine to get the two-sided
    # p-value from a gaussian normal distribution.
    my $pval = $self->_approximate_normal_p_value($z);

    # Return the Z score and the p-value
    return ( $z, $pval );
}

=head2 _calculate_observation_numbers

This private subroutine is run to determine N, n1, and n2 for the given data
set. This subroutine returns three Math::BigFloat objects and two strings:

    1. The total number of observations (N).
    2. The total number of observations in the smaller group (n1).
    3. The name of the smaller group (n1) [STRING].
    4. The total number of observations in the larger group (n2).
    5. The name of the larger group (n2) [STRING].

In the case of tests where there are equal numbers of observations in each
group, the 'test_genes' group will be chosen as n1.

=cut

sub _calculate_observation_numbers  {
    my $self = shift;
    my $scores_data = shift;

    # Calculate the total number of observations
    my $total_N = Math::BigFloat->new(scalar( @{$scores_data} ));

    # Pre-declare a Hash Ref to map the group names to observation values
    my $group_names = {
        test_genes          =>  Math::BigFloat->new(),
        background_genes    =>  Math::BigFloat->new(),
    };

    # Iterate through the unsorted data and calculate the number in each group
    foreach my $value_set ( @{$scores_data} ) {
        $group_names->{$value_set->{name}}->binc();
    }

    # Compare the sizes of each group
    my $comparison_test = $group_names->{background_genes}->bcmp(
        $group_names->{test_genes}
    );

    # Make sure a defined value is returned
    if ( defined $comparison_test ) {

        # If the background_genes list was shorter return this data as n_1
        if ( $comparison_test == -1 ) {
            return ( 
                $total_N, 
                $group_names->{background_genes},
                'background_genes',
                $group_names->{test_genes},
                'test_genes',
            );
        } else {
            # Otherwise return the test_genes as n_1
            return ( 
                $total_N, 
                $group_names->{test_genes},
                'test_genes',
                $group_names->{background_genes},
                'background_genes',
            );
        }
    } else {
        croak "\n\nComparison test failed.\n\n";
    }
}

=head2 _rank_sort_binding_data

This subroutine uses Sort::Rank to rank the binding data and returns a sorted
Array Ref of binding data sorted by ranks.

=cut

sub _rank_sort_binding_data {
    my $self = shift;
    my $scores_data = shift;
    my @sorted_data = rank_sort($scores_data);
    return (\@sorted_data);
}

=head2 _calculate_w_1

This private subroutine is run to calculate the test statistic (W1) for the
group n1. This subroutine takes the following arguments:

    1. An Array Ref of the sorted data from rank_sort
    2. n1
    3, A string that corresponds to the source of the data in n1

and returns a Math::BigFloat object.

=cut

sub _calculate_w_1  {
    my $self = shift;
    my $sorted_data = shift;
    my $group_1 = shift;
    my $group_1_name = shift;

    # Pre-declare a Math::BigFloat object to hold the sum of ranks for group 1
    # W1
    my $w_1 = Math::BigFloat->new();

    # Iterate through the data in sorted_data, if the data is in group 1 add the
    # rank to w_1
    foreach my $value ( @{$sorted_data} ) {
        if ( $value->[2]{name} eq $group_1_name ) {
            $w_1->badd($value->[0]);
        }
    }

    return $w_1;
}

=head2 _calculate_e_w_1

This private subroutine calculates the expected rank sum value for W1 [E(W1)]
given H0 that the data come from the same distribution. This subroutine takes
two arguments:

    1. Big N
    2. n1

and returns E(W1) as a Math::BigFloat object.

=cut

sub _calculate_e_w_1    {
    my $self = shift;
    my $big_N = shift;
    my $group1_total = shift;

    # Define a Math::BigFloat object to hold E(W1)
    my $e_w_1 = Math::BigFloat->new(
        $big_N->copy()->badd(1)
    );

    # Multiply by n1 total
    $e_w_1->bmul($group1_total);

    # Divide by 2
    $e_w_1->bdiv(2);

    return $e_w_1;
}

=head2 _calculate_v_w

This subroutine determines wheter or not there are ties in the given dataset. If
there are ties, this subroutine calculates V(W1) with a correction for the
number of ties in the data. Otherwise, the normal variance for V(W1) is
returned. This function takes the following as arguments:

    1. Array Ref of sorted data (from rank_sort)
    2. big_N
    3. n1
    4. n2

and returns a Math::BigFloat value for V(W1).

=cut

sub _calculate_v_w  {
    my $self = shift;
    my $sorted_data = shift;
    my $big_n = shift;
    my $group1 = shift;
    my $group2 = shift;

    # Pre-declare a Hash Ref to hold the number of observations at each rank
    my $obs_per_rank = {};

    # Pre-declare a Boolean false value to determine whether there are ties or
    # not
    my $ties_bool = 0;

    # Define the product of group1 and group2
    my $group_product = $group1->copy()->bmul($group2);

    # Iterate through the ranked data, and count how many times each observation
    # occurs
    foreach my $rank_set ( @{$sorted_data} ) {
        if ( defined ( $obs_per_rank->{$rank_set->[0]} ) ) {
            $obs_per_rank->{$rank_set->[0]}->binc();
            # Set the ties_bool to true
            $ties_bool = 1;
        } else {
            $obs_per_rank->{$rank_set->[0]} = Math::BigFloat->new(1);
        }
    }

    # Based on whether or not there are ties, calculate V(W1)
    if ( $ties_bool ) {

        # Pre-declare a float to hold the value for the correction value
        my $correction_val = Math::BigFloat->new();

        # Iterate through the obs_per_rank Hash Ref. If there are ties at a
        # rank, calculate the correction function ti(ti-1)(ti+1) and add it to
        # the correction_val
        foreach my $rank ( keys %{$obs_per_rank} ) {
            if ( $obs_per_rank->{$rank} > 1 ) {
                $correction_val->badd(
                    (
                        $obs_per_rank->{$rank} * 
                        ( $obs_per_rank->{$rank} - 1 ) * 
                        ( $obs_per_rank->{$rank} + 1 )
                    )
                );
            }
        }

        # Pre-define a Math::BigFloat for V(W1) which will be big_N plus 1
        my $v_w1 = Math::BigFloat->new(
            $big_n->copy()->badd(1)
        );

        # Multiply by the group product
        $v_w1->bmul($group_product);

        # Divide by 12
        $v_w1->bdiv(12);

        # Multiply the correction value by the product
        $correction_val->bmul($group_product);

        # Divide the correction value by 12 times big_n times big_n minus 1 
        $correction_val->bdiv(
            $big_n->copy()->bsub(1)->bmul(
                $big_n->copy()->bmul(12)
            )
        );

        # Subtract the correction value from v_w1
        $v_w1->bsub($correction_val);

        return $v_w1;
    } else {
        # Pre-define a Math::BigFloat for V(W1) which will be big_N plus 1
        my $v_w1 = Math::BigFloat->new(
            $big_n->copy()->badd(1)
        );

        # Multiply by the group product
        $v_w1->bmul($group_product);

        # Divide by 12
        $v_w1->bdiv(12);

        return $v_w1;
    }
}

=head2 _calculate_z_score

This private subroutine calculates the Z score for the current data set. This
subroutine takes W1, E(W1), and V(W1) as arguments and returns the Z score as a
Math::BigFloat object.

=cut

sub _calculate_z_score  {
    my $self = shift;
    my $w_1 = shift;
    my $e_w_1 = shift;
    my $v_w_1 = shift;

    # Define a Math::BigFloat object for Z
    my $z_score = Math::BigFloat->new(
        $w_1->copy()->bsub($e_w_1)
    );

    # Divide by the square root of V(W1)
    $z_score->bdiv(
        $v_w_1->copy()->bsqrt()
    );

    return $z_score;
}

=head2 _approximate_normal_p_value

This private subroutine is passed a Z score and returns the approximate normal
p-value using a Gaussian cumulative density function. The p-value returned is a
two-sided p-value as a Math::BigFloat object.

=cut

sub _approximate_normal_p_value {
    my $self = shift;
    my $z_score = shift;
#    my $p = Math::BigFloat->new(2);
#    $p->bmul((1 - gsl_cdf_ugaussian_P($z_score->copy()->babs())));
    my $root_2 = Math::BigFloat->new(2);
    $root_2->bsqrt();
    my $value = Math::BigFloat->new(
        $z_score->copy()->babs()
    );
    $value->bdiv($root_2);
    my $p = Math::BigFloat->new(
        gsl_sf_erfc($value)
    );
    return $p;
}

1;
