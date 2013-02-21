#!/usr/bin/env perl

#===============================================================================
#
#         FILE: peaksToGenes.pl
#
#        USAGE: ./peaksToGenes.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 06/08/2012 05:32:14 PM
#     REVISION: ---
#===============================================================================

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
	MySQL			=>	'mysql',
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
