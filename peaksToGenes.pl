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
use lib '/home/jason/Documents/Programming/Perl/PeaksToGenes/lib';
use PeaksToGenes;
my $peaks_to_genes = PeaksToGenes->new_with_options();
$peaks_to_genes->execute;
