
# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.

package PeaksToGenes::SignalRatio 0.001;

use Moose;
use Carp;
use Parallel::ForkManager;
use File::Path qw(make_path remove_tree);
use File::Basename;
use File::Which;
use IPC::Run3;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

with 'PeaksToGenes::Database', 'PeaksToGenes::SignalRatio::BedTools';

=head2 ip_file

This Moose attribute holds the path to the BED-format reads file for the IP.
This attribute must be set at the time of object creation.

=cut

has ip_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

=head2 input_file

This Moose attribute holds the path to the BED-format reads file for the Input
data. This attribute must be set at the time of object creation.

=cut

has input_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

=head2 scaling_factor

This Moose attribute holds the floating point number for the scaling factor that
is multiplicatively applied to the number of Input reads in a particular genomic
interval before being used as the denominator for calculating sample enrichment.
This Moose attribute must be set at the time of object creation.

=cut

has scaling_factor	=>	(
	is			=>	'ro',
	isa			=>	'Num',
	required	=>	1,
);

=head2 name

This Moose attribute holds the name of the experiment. The experiment name
should already be in the PeaksToGenes database and this attribute must be set at
object creation.

=cut

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

=head2 genome

This Moose attribute holds the name of the genome joined by a hyphen with the
window size. This genome at the desired window size must already have been
installed in the PeaksToGenes database using the --update function. This
attribute must be created at the time of object creation.


=cut

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

=head2 processors

This Moose attribute holds the integer value for the number of processors that
will be used for the execution of PeaksToGenes. This value must be positive and
set at the time of object creation.

=cut

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
    default     =>  1,
);

=head2 full_enricnment

This Moose attribute holds the Boolean value for whether the user would like to
use the full enrichment values or not.

=cut

has full_enricnment =>  (
    is          =>  'ro',
    isa         =>  'Bool',
);

=head2 index_signal_ratio

This subroutine is called and runs the main functions for the signal ratio
algorithm.

=cut

sub index_signal_ratio {
	my $self = shift;

    # Run the check_input_parameters subroutine to make sure the experiment and
    # genome defined are found in the PeaksToGenes database.
    $self->check_input_parameters;

    # Run the annotate_signal_ratio function imported from
    # PeaksToGenes::SignalRatio::BedTools, which returns a Hash Ref of indexed
    # signal ratios
    my $indexed_signal_ratios = $self->annotate_signal_ratio(
        $self->sorted_ip_file,
        $self->sorted_input_file,
        $self->genome,
        $self->processors,
        $self->scaling_factor,
        $self->full_enricnment,
    );

    # Run the remove_temporary_files subroutine to remove the reads files that
    # were split by chromosome
    $self->remove_temporary_files;

    # Run the parse_and_store function from PeaksToGenes::Database to parse the
    # indexed_signal_ratios binding information into an insert statement and
    # store the information in the PeaksToGenes database
    $self->parse_and_store(
        $indexed_signal_ratios,
        $self->genome,
        $self->name,
    );

    # Inform the user that operation is complete
    print "\n\nFinished installing the signal ratio values for the experiment: "
    . $self->name . " into the PeaksToGenes database.\n\n";
}

=head2 check_input_parameters

This subroutine is run to check the genome and experiment defined by the user
against the PeaksToGenes database.

=cut

sub check_input_parameters {
	my $self = shift;

    # Test to make sure the name has not been previously entered in the
    # PeaksToGenes database
    $self->test_name($self->name);

    # Test to make sure the genome entered is valid
    $self->test_genome($self->genome);

    # Test to make sure the scaling factor is valid
    $self->check_scaling_factor;
}

=head2 check_scaling_factor

This subroutine makes sure that the scaling factor defined is appropriate.

=cut

sub check_scaling_factor {
    my $self = shift;
    unless ( $self->scaling_factor > 0 ) {
        croak "\n\nYou must enter a scaling factor that is greater than 0.\n\n";
    }
}

=head2 sorted_ip_file

This Moose attribute holds a Hash Ref of the paths to the IP files that have
been split by chromosome and sorted using the sort utility from BedTools.

=cut

has sorted_ip_file   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    predicate   =>  'has_sorted_ip_file',
    writer      =>  '_set_sorted_ip_file',
);

before  'sorted_ip_file' =>  sub {
    my $self = shift;
    unless ($self->has_sorted_ip_file) {
        my $split_files = $self->_check_and_sort_files;
        $self->_set_sorted_ip_file($split_files->{ip_file});
        $self->_set_sorted_input_file($split_files->{input_file});
    }
};

=head2 sorted_input_file

This Moose attribute holds a Hash Ref of the paths to the IP files that have
been split by chromosome and merged using the sort utility from BedTools.

=cut

has sorted_input_file   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    predicate   =>  'has_sorted_input_file',
    writer      =>  '_set_sorted_input_file',
);

before  'sorted_input_file' =>  sub {
    my $self = shift;
    unless ($self->has_sorted_input_file) {
        my $split_files = $self->_check_and_sort_files;
        $self->_set_sorted_input_file($split_files->{input_file});
        $self->_set_sorted_ip_file($split_files->{ip_file});
    }
};

=head2 _check_and_sort_files

This private subroutine is called to fill the Moose attributes for split and
merged IP and Input files, respectively. This subroutine returns an anonymous
Hash Ref indexed by 'ip_files' and 'input_files'. Each of these keys holds a
Hash Ref of relative file paths to split and merged IP or Input files that are
indexed by chromosome string.

=cut

sub _check_and_sort_files    {
    my $self = shift;

    # Create an instance of Parallel::ForkManager with two threads.
    my $pm = Parallel::ForkManager->new(2);

    # Pre-declare a Hash Ref to hold the split and merged files
    my $sorted_files = {};

    # Define a subroutine to be run at the end of each thread
    $pm->run_on_finish(
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
                $data_structure) = @_;

            # Check to make sure everything has been returned correctly
            if ( $data_structure && $data_structure->{file_type}
                && $data_structure->{file} ) {

                # Store the information in the split_and_merged_files Hash Ref
                $sorted_files->{$data_structure->{file_type}} =
                $data_structure->{file};
            }
        }
    );

    # Define a Hash Ref to map the file types
    my $file_type_map = {
        ip_file    =>  $self->ip_file,
        input_file =>  $self->input_file,
    };

    # Iterate through the file types and start a new thread for each file type.
    # Call the _check_and_split function to return a Hash Ref of paths to files
    # that pass the constraints for PeaksToGenes and have been split by
    # chromosome. Then, call the _merge_files subroutine to merge each split
    # BED-format file so that the files will be smaller and easier for
    # intersectBed to deal with.
    foreach my $file_type ( keys %{$file_type_map} ) {

        # Start a new thread of one is available
        $pm->start and next;

        # Define a string for the temporary file that will hold the sorted
        # BED-format file for the current user-defined IP or Input file.
        my $sorted_dir = "$FindBin::Bin/../tmp" . '/' . $self->name . '/' .
        $file_type;
        make_path($sorted_dir);
        my $sorted_fh = $sorted_dir . '/sorted.bed';

        # Run the _check_BED_file subroutine, which checks to make sure the
        # user-define BED format reads files are correct.
        $self->_check_BED_file(
            $file_type_map->{$file_type}, 
        );

        # Run the _sort_bed_files subroutine to return a Hash Ref of files that
        # have been split by chromosome and sorted by chromosomal position.
        my $sorted_file_path = $self->_sort_bed_files( 
            $file_type_map->{$file_type},
            $sorted_fh
        );

        # End the current thread and return the data
        $pm->finish(0, 
            {
                file_type   =>  $file_type,
                file       =>  $sorted_file_path,
            }
        );
    }

    # Make sure all the threads have finished executing
    $pm->wait_all_children;

    return $sorted_files;
}

=head2 _check_BED_file

This subroutine checks both of the user-defined BED-format files to ensure that
they are properly formatted.

=cut

sub _check_BED_file {
	my $self = shift;
    my $bed_fh = shift;

    print "\n\nNow checking $bed_fh to ensure that the contents " .
    "are valid\n\n";

    # Pre-declare a line number to return useful errors to the user
    my $line_number = 1;

    # Open the user-defined file, iterate through and parse the lines. Any
    # errors found will cause an immediate termination of the script and return
    # an error message to the user.
    open my $bed_file, "<", $bed_fh or croak 
    "Could not read from BED file: " . $bed_fh .  ". Please check the " .
    "permissions on this file. $!\n\n";
    while (<$bed_file>) {
        my $line = $_;
        chomp ($line);

        # Split the line by tab characters
        my ($chr, $start, $stop, $name, $score, $strand, $rest_of_line) =
        split(/\t/, $line);

        # Test to make sure the chromosome defined in column 1 is a valid
        # chromosome for the user-defined genome
        unless ( $self->chromosome_sizes->{$self->genome}{$chr} ) {
            croak "On line: $line_number the chromosome: " . $chr .  " is not "
            . "defined in the user-defined genome: " .  $self->genome . 
            ". Please check your file: $bed_fh and the genome you would like"
            . " to use.\n\n";
        }

        # Test to make sure that the values in for the interval start in column
        # 2 and the interval end in column 3 are integers
        unless ( $start =~ /^\d+$/ ) {
            croak "On line: $line_number the interval start defined: " .
            $start . " is not an integer. Please check your file:
            $bed_fh.\n\n";
        }
        unless ( $stop =~ /^\d+$/ ) {
            croak "On line: $line_number the interval stop defined: " .
            $stop . " is not an integer. Please check your file:
            $bed_fh.\n\n";
        }

        # Test to make sure the integer value defined for the interval end in
        # column three is greater than the interval value defined for the
        # interval start in column two
        unless ( $stop > $start ) {
            croak "On line: $line_number the stop: $stop is not larger " .
            "than the start: $start. Please check your file: $bed_fh.\n\n";
        }

        # Test to make sure that the integer values defined for the interval
        # start in column two and the interval end in column three are valid
        # coordinates based on the length of the chromosome defined in column
        # one for the user-defined genome
        unless (($start <= $self->chromosome_sizes->{$self->genome}{$chr}) && 
            ($stop <= $self->chromosome_sizes->{$self->genome}{$chr})) {
            croak "On line: $line_number the coordinates are not valid " .
            "for the user-defined genome: " . $self->genome 
            . ". Please check your file: $bed_fh.\n\n";
        }

        # Test to make sure that a name is defined in the fourth column. It does
        # not have to be unique.
        unless ($name) {
            croak "On line: $line_number you do not have anything in the "
            . "fourth column to designate an interval/peak name. Please " .
            "check your file: $bed_fh or use the helper script to add a nominal " .
            "name in this column.\n\n";
        }

        # Test to make sure a score is defined in the fifth column and that it
        # is a numerical value 
        unless ($score && ($score >= 0 || $score <= 0)) {
            croak "On line: $line_number of your file: $bed_fh you "
            . "do not have a score entered ".
            "for your peak/interval. If these intervals do not have " . 
            "scores associated with them, please use the helper script " .
            "to add a nominal score in the fifth column.\n\n" unless (
                $score == 0 );
        }

        # Test to make sure the strand column is valid
        unless ($strand eq '-' || $strand eq '+') {
            croak "On line: $line_number of your file: $bed_fh," .
            " there is not a valid entry in the sixth column for the "
            . "strand. It should be either a '-' or a '+'\n\n";
        }

        # Test to make sure there are no other tab-delimited fields in the file
        # past the strand in the sixth column.
        if ($rest_of_line){
            croak "On line: $line_number, you have extra tab-" . 
            "delimited items after the sixth (strand) column. Please " .
            "use the helper script to trim these entries from your " .
            "file: $bed_fh.\n\n";
        }

        $line_number++;
	}
}

=head2 _sort_bed_files

This private subroutine is called to run the sortBed utility from BedTools to
sort the BED files. This subroutine is passed a file path and returns a file
path that has been sorted.

=cut

sub _sort_bed_files {
    my $self = shift;
    my $unsorted_fh = shift;
    my $sorted_fh = shift;

    # Define a string to be executed by IPC::Run3 to run sortBed
    my $sort_command = join(" ",
        which('sortBed'),
        '-i',
        $unsorted_fh,
        '>',
        $sorted_fh
    );

    # Run the sortBed command
    run3 $sort_command, undef, undef, undef;

    # If the sorted file exists, return the sorted file, otherwise die
    if ( -s $sorted_fh ) {
        return $sorted_fh;
    } else {
        croak "\n\nThere was a problem sorting the file: $unsorted_fh.\n\n";
    }

    return $sorted_fh;
}

=head2 remove_temporary_files

This subroutine removes the temporary files created in the tmp directory. These
files should be under the directory that is defined by the experiment name.

=cut

sub remove_temporary_files  {
    my $self = shift;

    # Define a string for the temporary file base directory
    my $temp_base_dir = "$FindBin::Bin/../tmp/" . $self->name;
    
    # Run the remove_tree function from File::Path to recursively delete the
    # temporary directory
    remove_tree($temp_base_dir);
}

__PACKAGE__->meta->make_immutable;

1;
