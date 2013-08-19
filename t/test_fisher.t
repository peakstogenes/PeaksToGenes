#
#===============================================================================
#
#         FILE: test_fisher.t
#
#  DESCRIPTION: This script is designed to test the functionality of my
#               implementation of the Fisher exact test.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/18/2013 20:57:29
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Data::Dumper;

use Test::More;

BEGIN {
    use_ok('Math::BigFloat');
    use Math::BigFloat  only =>  'GMP';

    sub fisher {
        my $a_val = shift;
        my $b_val = shift;
        my $c_val = shift;
        my $d_val = shift;

        my $big_a = Math::BigFloat->new($a_val);
        my $big_b = Math::BigFloat->new($b_val);
        my $big_c = Math::BigFloat->new($c_val);
        my $big_d = Math::BigFloat->new($d_val);

        my $big_n = Math::BigFloat->new();
        $big_n->badd($big_a);
        $big_n->badd($big_b);
        $big_n->badd($big_c);
        $big_n->badd($big_d);

        my $a_plus_b = Math::BigFloat->new();
        $a_plus_b->badd($big_a);
        $a_plus_b->badd($big_b);

        my $c_plus_d = Math::BigFloat->new();
        $c_plus_d->badd($big_c);
        $c_plus_d->badd($big_d);

        my $a_plus_c = Math::BigFloat->new();
        $a_plus_c->badd($big_a);
        $a_plus_c->badd($big_c);

        my $b_plus_d = Math::BigFloat->new();
        $b_plus_d->badd($big_b);
        $b_plus_d->badd($big_d);

        my $fisher_p = Math::BigFloat->new(
            (
                $a_plus_b->bfac() * $c_plus_d->bfac() *
                $a_plus_c->bfac() * $b_plus_d->bfac()
            ) / (
                $big_n->bfac() * $big_a->bfac() * 
                $big_b->bfac() * $big_c->bfac() *
                $big_d->bfac()
            )
        );

        return $fisher_p;
    }

    print fisher(500, 10, 300, 3000), "\n";
    print fisher(1, 9, 11, 3), "\n";
}

done_testing();
