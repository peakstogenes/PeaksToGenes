
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

use Moose;
use Carp;
use Data::Dumper;

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

sub list_all_experiments {
	my $self = shift;

	#  Extract the experiment column from the experiments table of the
	#  PeaksToGenes database, and print the names for the user.

	if ( $self->schema->resultset('Experiment')->get_column('experiment') ) {
		my @experiments =
		$self->schema->resultset('Experiment')->get_column('experiment')->all;
		if ( @experiments >= 1 ) {
			print "\n\nThe following experiment names are found in the PeaksToGenes database:\n\t",
			join("\n\t", @experiments), "\n\n";
		} else {
			print "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
		}
	} else {
		croak "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
	}
}

1;
