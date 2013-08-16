
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
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>

package PeaksToGenes::List 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

with 'PeaksToGenes::Database';

=head1 NAME

PeaksToGenes::List

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=head1 DESCRIPTION

This Moose role is designed to export a method to list all of the experiment
names defined in the PeaksToGenes database.

=head1 SYNOPSIS

with 'PeaksToGenes::List';

$self->list_all_experiments;

=cut

=head2 list_all_experiments

This subroutine is called and prints to STDOUT a list of all the genomes
installed, then a tab-delimited list of all experiments installed with their
corresponding genome in the second column.

=cut

sub list_all_experiments {
	my $self = shift;

    # Pre-declare a Hash Ref to hold the genomes and genome IDs installed.
    # Genome IDs are the keys, while the genome strings are values.
    my $genomes = {};

    # Pre-declare an Array Ref to hold the list of genomes installed that will
    # be printed for the user. Each entry contains three values in tab-delimited
    # format:
    #   1. UCSC genome string
    #   2. Step size used for defining relative genomic positions
    #   3. String used for PeaksToGenes database
    my $genome_list = [];

    # Add a header to the genome_list
    push(@{$genome_list},
        join("\t",
            '|',
            'UCSC',
            '|',
            'Step',
            '|',
            'PeaksToGenes genome string',
            '|',
        ),
        "-------------------------------------------------------------------------",
        "-------------------------------------------------------------------------",
    );

    # Iterate through the genomes in installed_genomes from
    # PeaksToGenes::Database, adding the appropriate information to the genomes
    # Hash Ref and the genome string will be added to the genome list.
    foreach my $genome ( keys %{$self->installed_genomes} ) {
        $genomes->{$self->installed_genomes->{$genome}{id}} = $genome;

        # Add the relevant information to the genome_list
        my ($ucsc, $step) = split(/-/, $genome);
        if ( length( $genome ) < 8 ) {
            push(@{$genome_list},
                join("\t",
                    '|',
                    $ucsc, 
                    '|',
                    $step, 
                    '|',
                    "\t$genome\t\t",
                    '|',
                ),
                "-------------------------------------------------------------------------",
            );
        } else {
            push(@{$genome_list},
                join("\t",
                    '|',
                    $ucsc, 
                    '|',
                    $step, 
                    '|',
                    "\t$genome\t",
                    '|',
                ),
                "-------------------------------------------------------------------------",
            );
        }
    }

    # Print the genomes installed to STDOUT
    print "\n\nThe following genomes are installed in the PeaksToGenes" .
    " database:";
    print "\n\n", join("\n", @{$genome_list}), "\n\n";

    # Pre-declare an Array Ref to hold the experiment names and corresponding
    # PeaksToGenes experiment names
    my $experiments_installed = [];

    # Add a header to the table.
    push(@{$experiments_installed},
        join("\t",
            '|',
            'Experiment', 
            '|',
            'PeaksToGenes genome string', 
            '|',
        ),
        "-----------------------------------------------------------------",
    );

    # Iterate through the experiment names in 'experiment_names' from
    # PeaksToGenes::Databse. Use the genome ID in the local 'genomes' Hash Ref
    # to extract the PeaksToGenes genome string.
    foreach my $experiment ( keys %{$self->experiment_names} ) {
        if ( length
            ($genomes->{$self->experiment_names->{$experiment}{genome_id}}) < 8
        ) {
            push(@{$experiments_installed},
                join("\t",
                    '|',
                    $experiment, 
                    '|',
                    "\t$genomes->{$self->experiment_names->{$experiment}{genome_id}}\t\t",
                    '|',
                ),
                "-----------------------------------------------------------------",
            );
        } else {
            push(@{$experiments_installed},
                join("\t",
                    '|',
                    $experiment, 
                    '|',
                    "\t$genomes->{$self->experiment_names->{$experiment}{genome_id}}\t",
                    '|',
                ),
                "-----------------------------------------------------------------",
            );
        }
    }

    # Print the experiments installed to STDOUT
    print "\n\nThe following experiments are installed in the PeaksToGenes" . 
    " database:";
    print "\n\n", join("\n", @{$experiments_installed}), "\n\n";

	#  Extract the experiment column from the experiments table of the
	#  PeaksToGenes database, and print the names for the user.
#
#	if ( $self->schema->resultset('Experiment')->get_column('experiment') ) {
#		my @experiments =
#		$self->schema->resultset('Experiment')->get_column('experiment')->all;
#		if ( @experiments >= 1 ) {
#			print "\n\nThe following experiment names are found in the PeaksToGenes database:\n\t",
#			join("\n\t", @experiments), "\n\n";
#		} else {
#			print "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
#		}
#	} else {
#		croak "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
#	}
}

1;
