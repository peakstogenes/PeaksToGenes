#
#===============================================================================
#
#         FILE: test_wilcoxon.t
#
#  DESCRIPTION: This script tests the functionality of my implementation of the
#               Wilcoxon Rank Sum test with p-value calculation under normal
#               approximation with correction for ties
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/18/2013 23:09:55
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;

use Test::More;

BEGIN {
    use_ok('Math::BigFloat');
    use Math::GSL::CDF qw/:all/;
    use Math::BigFloat  only =>  'GMP';
    use Sort::Rank qw(rank_sort rank_group);

    my $scores = [
        {   score   =>  900,    name    =>  'test_genes'    },
        {   score   =>  700,    name    =>  'test_genes'    },
        {   score   =>  800,    name    =>  'test_genes'    },
        {   score   =>  850,    name    =>  'test_genes'    },
        {   score   =>  770,    name    =>  'test_genes'    },
        {   score   =>  1000,    name    =>  'test_genes'    },
        {   score   =>  400,    name    =>  'test_genes'    },
        {   score   =>  400,    name    =>  'background_genes'    },
        {   score   =>  300,    name    =>  'background_genes'    },
        {   score   =>  1000,    name    =>  'background_genes'    },
        {   score   =>  200,    name    =>  'background_genes'    },
        {   score   =>  150,    name    =>  'background_genes'    },
        {   score   =>  0,    name    =>  'background_genes'    },
    ];

    my @sorted = rank_sort($scores);
    foreach my $value (@sorted) {
        print $value->[0], "\t", $value->[2]{name}, "\n";
    }

    # Run the 'calculate_observation_numbers' subroutine to determine N, n1 and
    # n2 for the given data. This subroutine returns three Math::BigFloat
    # objects and two strings:
    #   1. The total number of observations
    #   2. The total number of observations in the smaller group n1
    #   3. The name of the smaller group (n1) [STRING]
    #   4. The total number of observations in the larger group n2
    #   5. The name of the larger group (n2) [STRING]
    # In the case of tests where there are equal numbers of observations in each
    # group, the 'test_genes' group will be chosen as n1.
    sub calculate_observation_numbers   {
        my $scores_data = shift;

        # Calculate the total number of observations
        my $total_N = Math::BigFloat->new(scalar( @{$scores_data} ));

        # Pre-declare a Hash Ref to map the group names to observation values
        my $group_names = {
            test_genes          =>  Math::BigFloat->new(),
            background_genes    =>  Math::BigFloat->new(),
        };

        # Iterate through the unsorted data and calculate the number in each
        # group
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
            die "\n\nComparison test failed.\n\n";
        }
    }

    my ($total_N, $n1, $n1_name, $n2, $n2_name) = calculate_observation_numbers($scores);

    print join("\t",
        $total_N,
        $n1,
        $n1_name,
        $n2,
        $n2_name
    ), "\n";

    # Run the 'calculate_w_1' to get the test statistic W1 for n1. This
    # subroutine takes the following arguments:
    #   1. An Array Ref to the sorted data from rank_sort
    #   2. n1
    #   2. String that corresponds to which group n1 is
    # and returns W1 as a Math::BigFloat object
    sub calculate_w_1    {
        my $sorted_data = shift;
        my $group_1 = shift;
        my $group_1_name = shift;

        # Pre-declare a Math::BigFloat object to hold the sum of ranks for group
        # 1 W1
        my $w_1 = Math::BigFloat->new();

        # Iterate through the data in sorted_data, if the data is in group 1 add
        # the rank to w_1
        foreach my $value ( @{$sorted_data} ) {
            if ( $value->[2]{name} eq $group_1_name ) {
                $w_1->badd($value->[0]);
            }
        }

        return $w_1;
    }

    my $w1 = calculate_w_1(
        \@sorted,
        $n1,
        $n1_name
    );

    # Run the 'calculate_e_w_1' subroutine to get the expected value E(W1) for
    # W1. This subroutine takes two arguments:
    #   1. Big N
    #   2. n1
    # and returns E(W1) as a Math::BigFloat object
    sub calculate_e_w_1 {
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

    my $ew1 = calculate_e_w_1(
        $total_N,
        $n1
    );

    # Run the 'determine_v_w' subroutine to determine if there are ties
    # and therefore which value for V(W1) to return. This function takes the
    # following as arguments:
    #   1. Array ref of sorted data (from rank_sort)
    #   2. total_N
    #   3. n1
    #   4. n2
    # and returns a Math::BigFloat value for V(W1)
    sub determine_v_w   {
        my $sorted_data = shift;
        my $big_n = shift;
        my $group1 = shift;
        my $group2 = shift;

        # Pre-declare a Hash Ref to hold the number of observations at each rank
        my $obs_per_rank = {};

        # Pre-declare a Boolean false value to determine whether there are ties
        # or not
        my $ties_bool = 0;

        # Define the product of group1 and group2
        my $group_product = $group1->copy()->bmul($group2);

        # Iterate through the ranked data, and count how many times each
        # observation occurs
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
            # rank, calculate the correction function ti(ti-1)(ti+1) and add it
            # to the correction_val
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

    my $vw1 = determine_v_w(\@sorted, $total_N, $n1, $n2);

    # Run the 'calculate_z_score' subroutine to get the z-score for the current
    # data set. This subroutine takes W1, E(W1), and V(W1) as arguments and
    # returns the Z score as a Math::BigFloat object.
    sub calculate_z_score   {
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

    my $z = calculate_z_score(
        $w1, $ew1, $vw1
    );
    print "Z-score: ", $z, "\n";

    # Determine the P-value
    my $pval = 2 * (1 - gsl_cdf_ugaussian_P($z));
    print "P-value: ", $pval, "\n";
}

done_testing();
