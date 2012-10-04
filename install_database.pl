#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: install_database.pl
#
#        USAGE: ./install_database.pl  
#
#  DESCRIPTION: This script is used to execute an external Sqlite3 command
#  				to create the PeaksToGenes database.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (JRD), dobson187@gmail.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 10/04/2012 08:24:20 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use FindBin;
use File::Path qw(make_path remove_tree);

# Test to see if the static directory exists, if it does use
# File::Path::remove_tree to safely remove the contents of the static
# directory. Set keep_root to ensure that the directory remains.
if ( -d "$FindBin::Bin/static" ) {
	remove_tree("$FindBin::Bin/static", {keep_root	=>	1} );
} else {
	# If the static directory does not exist, use File::Path::make_path to
	# create the static directory
	make_path("$FindBin::Bin/static") or die "Could not create the static directory $!\n";
}

# Execute an external call to create the Sqlite3 PeaksToGenes database
`sqlite3 $FindBin::Bin/db/peakstogenes.db < $FindBin::Bin/db/peakstogenes.sql`;
