
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

package PeaksToGenes::Contrast::Out 0.001;

use Moose;
use Carp;
use Data::Dumper;

has parsed_array_refs	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has contrast_name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

sub print_tables {
	my $self = shift;

	# Iterate through the tables found in the parsed_array_refs Hash Ref,
	# printing each to file based on the user-defined contrast_name
	foreach my $table_type (keys %{$self->parsed_array_refs}) {
		if ($self->parsed_array_refs->{$table_type}) {
			# Run the PeaksToGenes::Contrast::Out::file_name subroutine
			# to generate a file name for the user's data
			my $fh = $self->file_name($table_type, 'number_of_peaks');

			# Write the table to file
			open my $out, ">", $fh or croak "Could not write to $fh. Please make sure you have the proper permissions to write to this file and that it contains legal characters\n\n";
			print $out join("\n",
				@{$self->parsed_array_refs->{$table_type}}
			);
			close $out;
		}
	}
}

sub file_name {
	my ($self, $table_type, $data_type) = @_;

	# Pre-defile a string to store the file string based on the
	# user-defined contrast name
	my $fh = $self->contrast_name;

	# Make sure there are no illegal characters in the contrast_name string
	$fh =~ s/\/|\\|\s|\.|//g;

	if ( $table_type eq 'anova' ) {
		$fh .= '_ANOVA_test_of_';
	} elsif ( $table_type eq 'point_biserial' ) {
		$fh .= '_point_biserial_test_of_';
	} elsif ( $table_type eq 'kruskal_wallis' ) {
		$fh .= '_kruskal_wallis_rank_order_test_of_';
	} elsif ( $table_type eq 'aggregate' ) {
		$fh .= '_sum_and_mean_values_of_';
	} else {
		croak "The type of table being printed is not a valid PeaksToGenes table\n";
	}

	if ( $data_type eq 'number_of_peaks' ) {
		$fh .= 'number_of_peaks_or_data_per_genomic_interval.txt';
	} elsif ( $data_type eq 'peaks_information' ) {
		$fh .= 'peak_or_interval_score_per_genomic_interval.txt';
	} else {
		croak "The type of data being printed is not a valid PeaksToGenes type\n";
	}

	return $fh;
}

1;
