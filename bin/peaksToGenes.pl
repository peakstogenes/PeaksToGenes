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
use File::Which;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes;

# First, we must check whether the required executables are in the $PATH,
# otherwise PeaksToGenes will not be able to run properly

# Pre-define a Hash Ref of program names as Keys and the command-line
# executable strings as the Hash values
my $required_executables = {
	SQLite			=>	'sqlite3',
	intersectBed	=>	'intersectBed',
	mergeBed		=>	'mergeBed',
};

# Pre-declare an Array Ref to hold error messages if external executables
# can not be found in the user's $PATH
my $error_messages = [];

# Iterate through the required_executables Hash Ref, checking each 
foreach my $program (keys %$required_executables) {
	my $executable_path = which($required_executables->{$program});
	chomp($executable_path);
	if ( $executable_path ) {
		print "Using $program found in $executable_path\n";
	} else {
		push(@$error_messages, "Unable to find $program in the \$PATH.".
			"Please check that you have $program installed and that your".
			".bashrc (or equivalent) is properly configured\n");
	}
}

# If any programs were not found in the $PATH, print an error message for
# each program, and complete execution, otherwise run the main subroutines.
if ( @$error_messages ) {
	print join("\n", @$error_messages), "\n";
} else {
	my $peaks_to_genes = PeaksToGenes->new_with_options();
	$peaks_to_genes->execute;
}
