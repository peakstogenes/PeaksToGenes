#
#===============================================================================
#
#         FILE: peaks-to-genes_contrast.t
#
#  DESCRIPTION: This script is designed to test the functions of
#               PeaksToGenes::Contrast.
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/13/2013 15:49:10
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

use Test::More;

BEGIN   {
    use_ok('PeaksToGenes::Contrast');

    # Create an instance of PeaksToGenes::Contrast and test to make sure the
    # object was properly created
    my $dynamic_contrast_no_tests = PeaksToGenes::Contrast->new(
        name            =>  'msl2_s2_cells',
        processors      =>  4,
        test_genes_fh   =>
        "$FindBin::Bin/../Temp_Data/xchrom_responsive_2_0.csv",
        contrast_name   =>
        "MSL2_binding_response_to_MSL2_RNAi_Dynamic_Background",
    );

    isa_ok($dynamic_contrast_no_tests, 'PeaksToGenes::Contrast');

    # Make sure that the 'valid_test_genes' attribute is a Hash Ref
    isa_ok($dynamic_contrast_no_tests->valid_test_genes, 'HASH');

    # Make sure that the 'valid_background_genes' is a Hash Ref
    isa_ok($dynamic_contrast_no_tests->valid_background_genes, 'HASH');

    # Run the 'all_data' function exported from
    # PeaksToGenes::Contrast::GenomicRegions and make sure a Hash Ref of Hash
    # Refs is returned
    my $all_data = $dynamic_contrast_no_tests->all_regions('msl2_s2_cells');
    isa_ok($all_data, 'HASH');
    isa_ok($all_data->{_gene_body_40_to_50_number_of_peaks}, 'HASH');
    isa_ok($all_data->{_3_steps_upstream_number_of_peaks}, 'HASH');
    isa_ok($all_data->{_7_steps_downstream_number_of_peaks}, 'HASH');
    isa_ok($all_data->{_introns_number_of_peaks}, 'HASH');
}

done_testing();
