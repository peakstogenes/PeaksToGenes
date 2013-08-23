
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

package PeaksToGenes::Contrast::Aggregate 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Statistics::Descriptive;
use Data::Dumper;

=head2 get_binding_stats

This subroutine is passed a Hash Ref of binding data separated by test_genes and
background_genes as well as the number of processors to use and returns a Hash
Ref of statistics about each distribution of binding data.

=cut

sub get_binding_stats   {
    my $self = shift;
    my $binding_hash = shift;
    my $processors = shift;

    # Define a Hash Ref to hold the statistics
    my $stats_hash = {};

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
            if ( $data_structure && $data_structure->{location} &&
                $data_structure->{gene_type} && exists $data_structure->{stats}
            ) {
                $stats_hash->{$data_structure->{location}}{$data_structure->{gene_type}}
                = $data_structure->{stats};
            }
        }
    );

    # Iterate through the relative genomic locations
    foreach my $genomic_location ( keys %{$binding_hash} ) {

        # Iterate through the gene types
        foreach my $gene_type ( keys %{$binding_hash->{$genomic_location}} ) {

            # Start a new thread if one is available
            $pm->start and next;

            # Make sure there are more than one data value entry
            if ( scalar (@{$binding_hash->{$genomic_location}{$gene_type}}) > 1) {

                # Create a local copy of the Array Ref of binding data that
                # ensures all values are defined
                my $local_binding_array = [];
                foreach my $binding_value ( @{$binding_hash->{$genomic_location}{$gene_type}} ) {
                    push (@{$local_binding_array}, 2 ** $binding_value) if defined $binding_value;
                }

                # Create an instance of Statistics::Descriptive::Sparse
                my $sparse_stat = Statistics::Descriptive::Sparse->new();

                # De-reference the Array Ref of binding data and add it to the
                # Statistics::Descriptive::Sparse object
                $sparse_stat->add_data(@{$local_binding_array});

                # Copy the number of data items to a local value
                my $total = $sparse_stat->count();

                # Create an instance of Statistics::Descriptive::Full
                my $full_stat = Statistics::Descriptive::Full->new();

                # De-reference the Array Ref of binding data and add it to the
                # Statistics::Descriptive::Full object
                $full_stat->add_data(@{$local_binding_array});

                # Get the statistics and return in a Hash Ref
                $pm->finish(0,
                    {
                        location    =>  $genomic_location,
                        gene_type   =>  $gene_type,
                        stats       =>  {
                            min                 =>  $sparse_stat->min(),
                            total               =>  $total,
                            max                 =>  $sparse_stat->max(),
                            mean                =>  $sparse_stat->mean(),
                            median              =>  $full_stat->median(),
                            first_quartile      =>  ($full_stat->percentile(25))[0],
                            third_quartile      =>  ($full_stat->percentile(75))[0],
                            variance            =>  $sparse_stat->variance(),
                            standard_deviation  =>  $sparse_stat->standard_deviation(),
                            SEM                 =>  (
                                $full_stat->standard_deviation() / sqrt($total)
                            ),
                        }
                    }
                );
            } else {
                $pm->finish(0,
                    {
                        location    =>  $genomic_location,
                        gene_type   =>  $gene_type,
                        stats       =>  {},
                    }
                );
            }
        }
    }

    # Make sure all of the threads have finished
    $pm->wait_all_children;

    return $stats_hash;
}

#sub create_table {
#	my $self = shift;
#
#	# Pre-declare a Array Ref to store the Array Ref tables for each data
#	# type
#	my $array_ref_of_aggregate_tables = [];
#
#	# Pre-declare Array Refs to hold the row data
#	my $header = ['Aggregate Source'];
#	my $test_genes = ['Test Genes Sum'];
#	my $test_genes_mean = ['Test Genes Mean'];
#	my $test_genes_sems = ['Test Genes SEM'];
#	my $background_genes = ['Background Genes Sum'];
#	my $background_genes_mean = ['Background Genes Mean'];
#	my $background_genes_sems = ['Background Genes SEM'];
#
#	foreach my $genomic_location (@{$self->genomic_index}) {
#
#		# Use the PeaksToGenes::Contrast::Aggregate::mean_and_sum
#		# subroutine to extract the mean and sum from both the
#		# background and test genes sets. Then add the values to the
#		# row data
#		my ($test_genes_sum, $test_genes_mean_val) = $self->mean_and_sum(
#			$self->genomic_regions_structure->{test_genes}{$genomic_location}{number_of_peaks}
#		);
#		my ($background_genes_sum, $background_genes_mean_val) = $self->mean_and_sum(
#			$self->genomic_regions_structure->{background_genes}{$genomic_location}{number_of_peaks}
#		);
#		my $test_genes_sem = $self->sem(
#			$self->genomic_regions_structure->{test_genes}{$genomic_location}{number_of_peaks},
#			$test_genes_mean_val
#		);
#		my $background_genes_sem = $self->sem(
#			$self->genomic_regions_structure->{background_genes}{$genomic_location}{number_of_peaks},
#			$background_genes_mean_val
#		);
#
#		push(@$test_genes, $test_genes_sum);
#		push(@$test_genes_mean, $test_genes_mean_val);
#		push(@$test_genes_sems, $test_genes_sem);
#		push(@$background_genes, $background_genes_sum);
#		push(@$background_genes_mean, $background_genes_mean_val);
#		push(@$background_genes_sems, $background_genes_sem);
#
#		# Copy the location into a temporary scalar, and remove the
#		# leading underscore before adding it to the header line
#		my $temp_header = $genomic_location;
#		$temp_header =~ s/^_//;
#		push(@$header, $temp_header);
#
#	}
#
#	# Add the row data to the main Array Ref in the Hash Ref
#	push(@$array_ref_of_aggregate_tables,
#		join("\n",
#			join("\t", @$header),
#			join("\t", @$test_genes),
#			join("\t", @$background_genes),
#			join("\t", @$test_genes_mean),
#			join("\t", @$background_genes_mean),
#			join("\t", @$test_genes_sems),
#			join("\t", @$background_genes_sems),
#		)
#	);
#
#	return $array_ref_of_aggregate_tables;
#}

#sub mean_and_sum {
#	my ($self, $array) = @_;
#
#	if ( @{$array} ) {
#		return ( sum(@$array), (sum(@$array) / @$array));
#	} else {
#		return (0, 0);
#	}
#}

#sub sem {
#	my ($self, $array, $mean) = @_;
#
#	if ( @{$array} ) {
#		# Pre-declare an Array Ref to hold the squared differences.
#		my $squared_differences = [];
#
#		foreach my $value ( @$array ) {
#			push(@$squared_differences,
#				( $value ** 2 ) - ( $mean ** 2 )
#			);
#		}
#
#		my $stdev = sqrt (sum(@$squared_differences) / @$squared_differences);
#
#		return ( $stdev / sqrt(@$array) );
#	} else {
#		return 0;
#	}
#}

1;
