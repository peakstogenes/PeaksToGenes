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
use IPC::Run3;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

use Test::More;

BEGIN {

    # Delete the experiment named 'msl2_s2_cells' if it exists
    #
    # Create a string to be executed by IPC::Run3
    my $delete_command = join(" ",
        "$FindBin::Bin/../bin/peakstogenes.pl",
        '--delete',
        '--name',
        'msl2_s2_cells'
    );

    # Execute the command with run3
    run3 $delete_command, undef, undef, undef;
    
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
    my $split_and_merged_ip_hash = $signal_ratio->sorted_ip_file;

    # Run the annotate_signal_ratio function to return a Hash Ref of signal
    # ratios and test that the returned data structure is correct
    my $indexed_signal_ratios = $signal_ratio->annotate_signal_ratio(
        $signal_ratio->sorted_ip_file,
        $signal_ratio->sorted_input_file,
        $signal_ratio->genome,
        $signal_ratio->processors,
        $signal_ratio->scaling_factor,
    );
    isa_ok($indexed_signal_ratios, 'HASH');

    # Run the remove_temporary_files function to delete the temporary split
    # BED-format files
    $signal_ratio->remove_temporary_files;

    # Run the parse_and_store function to insert the information into the
    # PeaksToGenes database
    $signal_ratio->parse_and_store(
        $indexed_signal_ratios,
        $signal_ratio->genome,
        $signal_ratio->name,
    );
    
    # Delete the entered data
    run3 $delete_command, undef, undef, undef;

    # Create an instance of PeaksToGenes::SignalRatio
    my $signal_ratio_full = PeaksToGenes::SignalRatio->new(
        name            =>  'msl2_s2_cells',
        genome          =>  'dm3-300',
        scaling_factor  =>  1.08840448781593,
        ip_file         =>  "$FindBin::Bin/../Temp_Data/MSL_ChIP_S2_Cells_Combined_converted.bed",
        input_file      =>  "$FindBin::Bin/../Temp_Data/MSL_Input_S2_Cells_Combined_converted.bed",
        processors      =>  4,
    );

    # Install the data again using the 'index_signal_ratio' function
    $signal_ratio_full->index_signal_ratio;

    # Delete the entered data to finish
    run3 $delete_command, undef, undef, undef;
}

done_testing();
