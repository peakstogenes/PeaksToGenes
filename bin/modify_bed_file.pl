#!/usr/bin/env perl 

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


use strict;
use warnings;
use utf8;

my $bed_file = $ARGV[0];

open my $file, "<", $bed_file or die "Could not read from $bed_file $!\n";
while (<$file>) {
	my $line = $_;
	chomp ($line);

	my @line_items = split(/\t/, $line);

	if ( @line_items >= 6 ) {
		print join("\t", $line_items[0], $line_items[1], $line_items[2],
			$line_items[3], $line_items[4]), "\n";
	}
}
