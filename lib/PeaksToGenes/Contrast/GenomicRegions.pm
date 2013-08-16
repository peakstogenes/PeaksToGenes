
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

package PeaksToGenes::Contrast::GenomicRegions 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Parallel::ForkManager;
use Data::Dumper;

with 'PeaksToGenes::Database';

=head1 NAME

PeaksToGenes::Contrast::GenomicRegions

=cut

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=cut

=head1 DESCRIPTION

This role is consumed by PeaksToGenes::Contrast and interacts with the
PeaksToGenes database to create a data structure of binding information for the
user-defined experiment that will be used for contrast testing.

=cut

=head2 table_dispatch

This Moose attribute holds a Hash Ref of mappings between relative location
strings and the PeaksToGenes database tables in which they are annotated.

=cut

has table_dispatch	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
    predicate   =>  'has_table_dispatch',
    writer      =>  '_set_table_dispatch',
);

before  'table_dispatch'    =>  sub {
    my $self = shift;
    unless ( $self->has_table_dispatch ) {
        $self->_set_table_dispatch(
            $self->_define_table_dispatch
        );
    }
};

=head2 _define_table_dispatch

This private subroutine defines a mapping between relative genomic location
strings and the PeaksToGenes table in which the data are defined.

=cut

sub _define_table_dispatch {
    my $self = shift;

    # Define the table to be returned for the transcript locations
    my $table_dispatch = {
        'TranscriptNumberOfPeaks'   =>  [
            '_5prime_utr_number_of_peaks',
            '_3prime_utr_number_of_peaks',
            '_exons_number_of_peaks',
            '_introns_number_of_peaks',
        ],
    };

    # Define the upstream, downstream and gene body locations
    for (my $i = 0; $i < 10; $i++) {
        push( @{$table_dispatch->{UpstreamNumberOfPeaks}},
            '_' . ($i+1) . '_steps_upstream_number_of_peaks'
        );
        push( @{$table_dispatch->{DownstreamNumberOfPeaks}},
            '_' . ($i+1) . '_steps_downstream_number_of_peaks'
        );
        push( @{$table_dispatch->{GeneBodyNumberOfPeaks}},
            '_gene_body_' . ($i*10) . '_to_' . (($i+1)*10) . '_number_of_peaks'
        );
    }

    return $table_dispatch;
}

=head2 all_regions

This subroutine is given an experiment name and returns a Hash Ref of Hash Refs
of binding data indexed by relative genomic location and transcript ID.

=cut

sub all_regions {
    my $self = shift;
    my $experiment_name = shift;

	# Get the experiment id
	my $experiment_id = $self->experiment_names->{$experiment_name}{id};

    # Die if an experiment ID was not found
    unless ( $experiment_id ) {
        croak "\n\nCould not find the experiment ID for the experiment: " .
        "$experiment_name. Please check that you have entered the experiment " .
        "name correctly and that the experiment you are trying to work with has"
        .  " been installed in the PeaksToGenes database.\n\n";
    }

	# Pre-declare a Hash Ref to hold the genomic regions data
	my $genomic_regions_all_data = {};

    # Iterate through the tables defined in the table_dispatch attribute
    foreach my $table ( keys %{$self->table_dispatch} ) {

        # Create a result set for the table by searching for all rows that match
        # the experiment ID defined above
        my $experiment_rs = $self->schema->resultset($table)->search(
            {
                name    =>  $experiment_id,
            }
        );

        # Expand the result set using HashRefInflator
        $experiment_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

        # Iterate through the Hash Refs
        while ( my $experiment_hash = $experiment_rs->next ) {

            # Iterate through the column types and add the data to the
            # genomic_regions_all_data Hash Ref
            foreach my $location ( @{$self->table_dispatch->{$table}} ) {
                if ( defined $experiment_hash->{$location} ) {
                    
                    # Add the data indexed by the transcript ID
                    $genomic_regions_all_data->{$location}{$experiment_hash->{gene}} = $experiment_hash->{$location};
                }
            }
        }
    }

	return $genomic_regions_all_data;
}

=head2 separate_binding_regions_by_gene_lists

This subroutine is passed the Hash Ref of binding information produced by running the all_regions subroutine and a Hash Ref of gene lists (that are Hash Refs) defined as:

    test_genes          =>  HashRef of RefSeq IDs and PtG IDs
    background_genes    =>  HashRef of RefSeq IDs and PtG IDs

=cut

sub separate_binding_regions_by_gene_lists {
    my $self = shift;
    my $all_binding_hash = shift;
    my $gene_lists_hash = shift;

    # Make sure the gene lists Hash was correctly passed in
    unless ( exists ( $gene_lists_hash->{test_genes} ) && 
        exists ( $gene_lists_hash->{background_genes} ) ) {
        croak "\n\nYou must pass an anonymous Hash to the " .
        "separate_binding_regions_by_gene_lists function that defines two Hash "
        .  "Refs of Hash Ref gene lists. Please check the POD for how to define"
        . " these Hash Refs.\n\n";
    }

	# Create an instance of Parallel::ForkManager with the number of
	# threads allowed set to the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be run at the end of each thread
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$genomic_regions_structure->{test_genes}{$data_structure->{'location'}}{$data_structure->{'table_type'}}
			= $data_structure->{'test_genes_data'};
			$genomic_regions_structure->{background_genes}{$data_structure->{'location'}}{$data_structure->{'table_type'}}
			= $data_structure->{'background_genes_data'};
		}
	);

	foreach my $location ( keys %$genomic_regions_all_data ) {
		foreach  my $table_type ( keys
			%{$genomic_regions_all_data->{$location}} ) {

			# Start a new thread if one is available
			$pm->start and next;

			# Pre-declare Array Refs for the test genes and background
			# genes respectively
			my $test_data = [];
			my $background_data = [];

			my $column = $location . "_" . $table_type;

			while ( my $location_result =
				$genomic_regions_all_data->{$location}{$table_type}->next)
			{
				if (  $test_ids->{$location_result->{gene}} ) {
					if ( $location_result->{$column} ) {
						push(@$test_data, $location_result->{$column});
					} else {
						push(@$test_data, 0);
					}
				} elsif ( $background_ids->{$location_result->{gene}} ) {
					if ( $location_result->{$column} ) {
						push(@$background_data, $location_result->{$column});
					} else {
						push(@$background_data, 0);
					}
				}
			}

			# Fill the test and background gene lists with zeros for the
			# genes that are not found in the PeaksToGenes database
			for (my $i = @$test_data; $i < @{$self->test_genes}; $i++) {
				push(@$test_data, 0);
			}
			for (my $i = @$background_data; $i <
				@{$self->background_genes}; $i++) {
				push(@$background_data, 0);
			}

			$pm->finish(0,
				{
					table_type				=>	$table_type,
					location				=>	$location,
					test_genes_data			=>	$test_data,
					background_genes_data	=>	$background_data,
				}
			);
		}
	}

	$pm->wait_all_children;

	return $genomic_regions_structure;
}

1;
