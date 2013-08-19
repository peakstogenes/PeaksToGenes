#
#===============================================================================
#
#         FILE: test_wilcoxon.t
#
#  DESCRIPTION: This script tests the functionality of my implementation of the
#               Wilcoxon Rank Sum test with exact p-value calculation
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/18/2013 23:09:55
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;

use Test::More;

BEGIN {
    use_ok('Math::BigFloat');
    use Math::BigFloat  only =>  'GMP';
    use Sort::Rank qw(rank_sort rank_group);

    my $scores = [
        {   score   =>  900,    name    =>  'test_genes'    },
        {   score   =>  700,    name    =>  'test_genes'    },
        {   score   =>  800,    name    =>  'test_genes'    },
        {   score   =>  850,    name    =>  'test_genes'    },
        {   score   =>  770,    name    =>  'test_genes'    },
        {   score   =>  1000,    name    =>  'test_genes'    },
        {   score   =>  400,    name    =>  'test_genes'    },
        {   score   =>  400,    name    =>  'background_genes'    },
        {   score   =>  300,    name    =>  'background_genes'    },
        {   score   =>  1000,    name    =>  'background_genes'    },
        {   score   =>  200,    name    =>  'background_genes'    },
        {   score   =>  150,    name    =>  'background_genes'    },
        {   score   =>  0,    name    =>  'background_genes'    },
    ];

    my @sorted = rank_sort($scores);
    foreach my $value (@sorted) {
        print $value->[0], "\t", $value->[2]{name}, "\n";
    }
}

done_testing();
