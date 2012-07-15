#!perl -T

use Test::More tests => 6;
use lib './lib';

BEGIN {
    use_ok( 'PeaksToGenes' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::FileStructure' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::BedTools' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Database' ) || print "Bail out!\n";
    use_ok( 'PeaksToGenes::Out' ) || print "Bail out!\n";
	use_ok( 'PeaksToGenes::Schema' ) || print "Bail out!\n";
}

diag( "Testing PeaksToGenes $PeaksToGenes::VERSION, Perl $], $^X" );
