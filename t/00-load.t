#!/usr/bin/perl

use Test::More tests => 9;
use FindBin;
use lib "$FindBin::Bin/../lib";
use strict;
use warnings;

BEGIN {
	use_ok( 'Moose' ) || print "Bail out!\n";
	use_ok( 'Moose::Util::TypeConstraints' ) || print "Bail out!\n";
	use_ok( 'Carp' ) || print "Bail out!\n";
	use_ok( 'MooseX::Getopt' ) || print "Bail out!\n";
	use_ok( 'DBIx::Class::Schema' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::BedTools' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Contrast' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::FileStructure' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Out' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Schema' ) || print "Bail out!\n";
	use_ok( 'PeaksToGenes::UCSC' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Update' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Update::UCSC' ) || print "Bail out!\n";
}

diag( "Testing PeaksToGenes $PeaksToGenes::VERSION, Perl $], $^X" );
