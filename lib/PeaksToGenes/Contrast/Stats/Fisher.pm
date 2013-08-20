
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

package PeaksToGenes::Contrast::Stats::Fisher 0.001;

use Moose::Role;
use Carp;
use Math::BigFloat  only =>  'GMP';
use FindBin;
use lib "$FindBin::Bin/../lib";
use Parallel::ForkManager;
use Data::Dumper;

=head2 peaks_to_genes_fishers_exact_test

This subroutine is the main subroutine called by PeaksToGenes::Contrast::Stats.
This subroutine controls the data flow so that the binding data is parsed into a
2x2 contingency table and then the Fisher's exact test is run. This subroutine
returns a Hash Ref p-values indexed by relative genomic location.

=cut

sub peaks_to_genes_fishers_exact_test {
    my $self = shift;
    my $data_hash = shift;
    my $processors = shift;
    my $fisher_threshold = shift;

    # Define a Hash Ref to hold the results of the test
    my $test_results = {};

    # Create a new instance of Parallel::ForkManager with the maximum
    # number of threads being the number of processors defined by the user
    my $pm = Parallel::ForkManager->new($processors);

    # Define a subroutine to be executed at the end of each thread so that
    # the results of the test are stored in the Hash Ref
    $pm->run_on_finish(
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
                $data_structure) = @_;

            # Make sure that the data was returned correctly.
            if ( $data_structure && $data_structure->{genomic_location} &&
                defined ($data_structure->{p_value}) &&
                defined ($data_structure->{A}) &&
                defined ($data_structure->{B}) &&
                defined ($data_structure->{C}) &&
                defined ($data_structure->{D})
            ) {

                # Store the result in the test_results Hash Ref
                $test_results->{$data_structure->{genomic_location}} =
                {
                    p_value =>  $data_structure->{p_value},
                    A       =>  $data_structure->{A},
                    B       =>  $data_structure->{B},
                    C       =>  $data_structure->{C},
                    D       =>  $data_structure->{D},
                };
            }
        }
    );

    # Iterate through the genomic regions structure, and perform the
    # Fisher's exact test to determine the two-tailed probability of observing
    # the distribution of peaks/bound regions assuming random distribution of
    # these events across both lists of genes
    foreach my $genomic_location ( keys %{$data_hash} ) {

        # Start a new thread if one is available
        $pm->start and next;

        # Run the '_construct_2_by_2_table' subroutine to return four
        # Math::BigFloat objects that correspond to the four quadrants of the
        # bigram that is constructed as follows:
        #
        #              Near test genes    Near background genes
        #           ==============================================
        #           |                  |                         |
        #  Bound    |       A          |            B            |
        #           |                  |                         |
        #           |============================================|
        #           |                  |                         |
        #  Unbound  |       C          |            D            |
        #           |                  |                         |
        #           ==============================================
        #
        # and used for calculating the p-value
        my ($num_a, $num_b, $num_c, $num_d) = $self->_construct_2_by_2_table(
            $data_hash->{$genomic_location},
            $fisher_threshold
        );

        # Run the 'fisher_exact_test' subroutine, which takes four
        # Math::BigFloat objects as arguments [A, B, C, D] and returns the
        # p-value or probability of observing this distribution of values.
        my $p_value = $self->fisher_exact_test(
            $num_a, $num_b, $num_c, $num_d
        );

        # End the thread
        $pm->finish(0,
            {
                genomic_location    =>  $genomic_location,
                p_value             =>  $p_value,
                A                   =>  $num_a->bstr(),
                B                   =>  $num_b->bstr(),
                C                   =>  $num_c->bstr(),
                D                   =>  $num_d->bstr(),
            }
        );
    }

    # Ensure that all of the threads have finished
    $pm->wait_all_children;

    return $test_results;
}

=head2 _construct_2_by_2_table

This private subroutine is passed a Hash Ref of Array Refs of enrichment data or
number of peaks per relative genomic region. The Hash Ref is indexed by
'test_genes' and 'background_genes'. Based on whether the value (number of peaks
or enrichment value) is zero (indicating that the user is analyzing
peaks-derived data) the binding data values will be expanded 2^x before testing
equality. This subroutine returns four Math::BigFloat objects that correspond to
entries A, B, C, and D on a Fisher 2x2 bigraph.

=cut

sub _construct_2_by_2_table {
    my $self = shift;
    my $binding_data = shift;
    my $fisher_threshold = shift;

    # Pre-define four Math::BigFloat objects for the four quadrants of the
    # bigram.
    my $big_a = Math::BigFloat->new();
    my $big_b = Math::BigFloat->new();
    my $big_c = Math::BigFloat->new();
    my $big_d = Math::BigFloat->new();

    # Test whether the fisher_threshold is zero and therefore the data will be
    # treated as peaks
    if ( defined ($fisher_threshold) && $fisher_threshold == 0 ) {

        # Iterate through the test genes
        foreach my $binding ( @{$binding_data->{test_genes}} ) {

            # Test whether there are any peaks
            if ( defined $binding && $binding > 0 ) {
                $big_a->binc();
            } else {
                $big_b->binc() if defined $binding;
            }
        }

        # Iterate through the background genes
        foreach my $binding ( @{$binding_data->{background_genes}} ) {

            # Test whether there are any peaks
            if ( defined $binding && $binding > 0 ) {
                $big_c->binc();
            } else {
                $big_d->binc() if defined $binding;
            }
        }
    } else {

        # Iterate through the test genes
        foreach my $binding ( @{$binding_data->{test_genes}} ) {

            # Test whether the binding is more than the fisher_threshold
            if ( defined $binding && ( 2 ** $binding ) >= $fisher_threshold ) {
                $big_a->binc();
            } else {
                $big_b->binc() if defined $binding;
            }
        }

        # Iterate through the background genes
        foreach my $binding ( @{$binding_data->{background_genes}} ) {

            # Test whether the binding is more than the fisher_threshold
            if ( defined $binding && ( 2 ** $binding ) >= $fisher_threshold ) {
                $big_c->binc();
            } else {
                $big_d->binc() if defined $binding;
            }
        }
    }

    return ($big_a, $big_b, $big_c, $big_d);
}

=head2 fisher_exact_test

This subroutine is passed four Math::BigFloat objects as A, B, C, and D and
returns the probability of observing the given distribution of binding data.

=cut

sub fisher_exact_test   {
    my $self = shift;
    my $big_a = shift;
    my $big_b = shift;
    my $big_c = shift;
    my $big_d = shift;

    # Calculate the total number of observations
    my $big_n = Math::BigFloat->new();
    $big_n->badd($big_a);
    $big_n->badd($big_b);
    $big_n->badd($big_c);
    $big_n->badd($big_d);

    # Calculate the sum of A and B
    my $a_plus_b = Math::BigFloat->new();
    $a_plus_b->badd($big_a);
    $a_plus_b->badd($big_b);

    # Calculate the sum of C and D
    my $c_plus_d = Math::BigFloat->new();
    $c_plus_d->badd($big_c);
    $c_plus_d->badd($big_d);

    # Calculate the sum of A and C
    my $a_plus_c = Math::BigFloat->new();
    $a_plus_c->badd($big_a);
    $a_plus_c->badd($big_c);

    # Calculate the sum of B and D
    my $b_plus_d = Math::BigFloat->new();
    $b_plus_d->badd($big_b);
    $b_plus_d->badd($big_d);

    # Calculate the p-value
    my $fisher_p = Math::BigFloat->new(
        (
            $a_plus_b->copy()->bfac() * $c_plus_d->copy()->bfac() *
            $a_plus_c->copy()->bfac() * $b_plus_d->copy()->bfac()
        ) / (
            $big_n->copy()->bfac() * $big_a->copy()->bfac() * 
            $big_b->copy()->bfac() * $big_c->copy()->bfac() *
            $big_d->copy()->bfac()
        )
    );

    return $fisher_p->bstr();
}

1;
