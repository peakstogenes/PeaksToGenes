
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

package PeaksToGenes::Delete 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

with 'PeaksToGenes::Database';

sub seek_and_destroy {
	my $self = shift;

	# Create an experiment results set searching for the user-defined
	# experiment name
	my $experiment_result_set =
	$self->schema->resultset('Experiment')->find(
		{
			experiment	=>	$self->name,
		}
	);

	if ( $experiment_result_set ) {

		print "\n\nDeleting the ", $self->name, " data.\n\n";

		# Loop through the tables, and delete the rows where the data
		# corresponds to the table
        foreach my $table ('UpstreamNumberOfPeaks', 'TranscriptNumberOfPeaks',
            'GeneBodyNumberOfPeaks', 'DownstreamNumberOfPeaks' ) {
			my $result_set = $self->schema->resultset($table)->search(
				{
					name	=>	$experiment_result_set->id
				}
			)->delete;
		}
		$experiment_result_set->delete;
	} else {
		croak "\n\nCould not find the experiment defined: " . $self->name .
		". Please check that you have entered the correct name.\n\n";
	}
}

1;
