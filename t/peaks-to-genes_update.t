#
#===============================================================================
#
#         FILE: peaks-to-genes_update.t
#
#  DESCRIPTION: This script is designed to test the functions of
#               PeaksToGenes::Update and the role it consumes
#               PeaksToGenes::Update::UCSC
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Jason R. Dobson (), Jason_Dobson@brown.edu
# ORGANIZATION: Center for Computational Molecular Biology
#      VERSION: 1.0
#      CREATED: 08/03/2013 16:08:47
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

BEGIN {
    use_ok('PeaksToGenes::Update');

    # Define a Hash Ref to hold the genome name and the dynamically-determined
    # window size for each
    my $window_sizes = {
        hg19    =>  2302,
        dm3     =>  328,
        mm10    =>  1682,
    };

    # Iterate through the genomes and test that the dynamically defined window
    # size is correct
    foreach my $genome ( keys %{$window_sizes} ) {

        # Create an instance of PeaksToGenes::Update
        my $dynamic_update = PeaksToGenes::Update->new(
            genome  =>  $genome,
        );

        # Make sure the object has been created properly
        isa_ok( $dynamic_update, 'PeaksToGenes::Update' );

        # Set the genome, but not the step size using
        # PeaksToGenes::Update::UCSC::set_genome_and_step_size
        $dynamic_update->set_genome_and_step_size($genome);

        cmp_ok($dynamic_update->valid_genome, 'eq', $genome,
            "Genome $genome set and valid"
        );

        # Get the dynamic window size
        my $step_size = $dynamic_update->step_size;

        # Make sure the step size was set correctly
        cmp_ok($step_size, '==', $window_sizes->{$genome},
            "Window size $step_size equals $window_sizes->{$genome}"
        );

        $dynamic_update->fetch_tables;
    }

    # Create an instance of PeaksToGenes::Update where the window size is
    # defined by the user
    my $defined_update  = PeaksToGenes::Update->new(
        genome      =>  'dm3',
        window_size =>  '300'
    );

    $defined_update->set_genome_and_step_size('dm3', 300);
    my ( 
        $genome_string,
        $file_names,
        $chromosome_sizes_file
    ) = $defined_update->fetch_tables;

    my $full_update = PeaksToGenes::Update->new(
        genome  =>  'rn4',
    );
    $full_update->update;
}

done_testing();



