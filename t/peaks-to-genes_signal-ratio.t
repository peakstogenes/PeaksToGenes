#
#===============================================================================
#
#         FILE: peaks-to-genes_signal-ratio.t
#
#  DESCRIPTION: This script is designed to test the function of
#               PeaksToGenes::SignalRatio
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/10/2013 15:11:52
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

use Test::More;

BEGIN {
    
    # Make sure that PeaksToGenes::SignalRatio can be used
    use_ok('PeaksToGenes::SignalRatio');

    # Create an instance of PeaksToGenes::SignalRatio and make sure the object
    # was created properly
    my $signal_ratio = PeaksToGenes::SignalRatio->new(
        name            =>  'msl2_s2_cells',
        genome          =>  'dm3-300',
        scaling_factor  =>  1.08840448781593,
        ip_file         =>  "$FindBin::Bin/../Temp_Data/MSL_ChIP_S2_Cells_Combined_converted.bed",
        input_file      =>  "$FindBin::Bin/../Temp_Data/MSL_Input_S2_Cells_Combined_converted.bed",
        processors      =>  4,
    );

    isa_ok($signal_ratio, 'PeaksToGenes::SignalRatio');

    # Make sure the $signal_ratio object can execute the
    # 'check_input_parameters' function
    can_ok($signal_ratio, 'check_input_parameters');

    # Run the 'check_input_parameters' subroutine to make sure things entered
    # were valid.
    $signal_ratio->check_input_parameters;

    # Store the split_and_merged_ip_files Moose attribute into a local variable
    # and make sure the contents are returned correctly.
    my $split_and_merged_ip_hash = $signal_ratio->split_ip_files;
    isa_ok($split_and_merged_ip_hash, 'HASH');

    # Run a subtest to make sure the Hash Ref returned has the correct items
    subtest 'check_split_and_merged_ip_hash'    =>  sub {
        foreach my $chr ( keys %{$split_and_merged_ip_hash} ) {
            ok( 
                $signal_ratio->chromosome_sizes->{'dm3-300'}{$chr}, 
                'The chromosome ' . $chr . ' is valid for dm3'
            );
            ok(
                -r $split_and_merged_ip_hash->{$chr} &&
                -s $split_and_merged_ip_hash->{$chr},
                'The file ' . $split_and_merged_ip_hash->{$chr} .
                ' is readable'
            );
        }
    };

    # Run the annotate_signal_ratio function to return a Hash Ref of signal
    # ratios and test that the returned data structure is correct
    my $indexed_signal_ratios = $signal_ratio->annotate_signal_ratio(
        $signal_ratio->split_ip_files,
        $signal_ratio->split_input_files,
        $signal_ratio->genome,
        $signal_ratio->processors,
        $signal_ratio->scaling_factor,
    );
    isa_ok($indexed_signal_ratios, 'HASH');

    # Run the remove_temporary_files function to delete the temporary split
    # BED-format files
    $signal_ratio->remove_temporary_files;

    print Dumper $indexed_signal_ratios;
}

done_testing();
