
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
        $self->split_ip_files,
        $self->split_input_files,
        $self->genome,
        $self->processors,
        $self->scaling_factor
    );

    # Run the remove_temporary_files subroutine to remove the reads files that
    # were split by chromosome
    $self->remove_temporary_files;

	# Create an instance of PeaksToGenes::Annotate::Database and run the
	# PeaksToGenes::Annotate::Database::parse_and_store subroutine to
	# insert the information into the PeaksToGenes database
#	my $database = PeaksToGenes::Annotate::Database->new(
#		schema			=>	$self->schema,
#		indexed_peaks	=>	$indexed_signal_ratios,
#		name			=>	$self->name,
#		ordered_index	=>	$genomic_index,
#		genome			=>	$self->genome,
#		processors		=>	$self->processors,
#	);
#	$database->parse_and_store;

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

=head2 split_and_merged_ip_files

This Moose attribute holds a Hash Ref of the paths to the IP files that have
been split by chromosome and merged using the mergeBed utility.

=cut

has split_ip_files   =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_split_ip_files',
    writer      =>  '_set_split_ip_files',
);

before  'split_ip_files' =>  sub {
    my $self = shift;
    unless ($self->has_split_ip_files) {
        my $split_files = $self->_check_and_split_files;
        $self->_set_split_ip_files($split_files->{ip_files});
        $self->_set_split_input_files($split_files->{input_files});
    }
};

=head2 split_and_merged_input_files

This Moose attribute holds a Hash Ref of the paths to the IP files that have
been split by chromosome and merged using the mergeBed utility.

=cut

has split_input_files   =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_split_input_files',
    writer      =>  '_set_split_input_files',
);

before  'split_input_files' =>  sub {
    my $self = shift;
    unless ($self->has_split_input_files) {
        my $split_files = $self->_check_and_split_files;
        $self->_set_split_input_files($split_files->{input_files});
        $self->_set_split_ip_files($split_files->{ip_files});
    }
};

=head2 _check_and_split_files

This private subroutine is called to fill the Moose attributes for split and
merged IP and Input files, respectively. This subroutine returns an anonymous
Hash Ref indexed by 'ip_files' and 'input_files'. Each of these keys holds a
Hash Ref of relative file paths to split and merged IP or Input files that are
indexed by chromosome string.

=cut

sub _check_and_split_files    {
    my $self = shift;

    # Create an instance of Parallel::ForkManager with two threads.
    my $pm = Parallel::ForkManager->new(2);

    # Pre-declare a Hash Ref to hold the split and merged files
    my $split_files = {};

    # Define a subroutine to be run at the end of each thread
    $pm->run_on_finish(
        sub {
            my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
                $data_structure) = @_;

            # Check to make sure everything has been returned correctly
            if ( $data_structure && $data_structure->{file_type}
                && $data_structure->{files} ) {

                # Store the information in the split_and_merged_files Hash Ref
                $split_files->{$data_structure->{file_type}} =
                $data_structure->{files};
            }
        }
    );

    # Define a Hash Ref to map the file types
    my $file_type_map = {
        ip_files    =>  $self->ip_file,
        input_files =>  $self->input_file,
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

        # Pre-declare a Hash Ref to hold the split files
        my $split_files = {};

        # Iterate through the chromosomes defined in chromosome_sizes. Create a
        # file path for each chromosome for the given file type in the tmp
        # directory.
        foreach my $chr ( keys %{$self->chromosome_sizes->{$self->genome}} ) {

            # Make a path to where the temporary file will be stored
            my $current_chr_dir = "$FindBin::Bin/../tmp/" . $self->name . '/' . $file_type . '/' . $chr;
            make_path( $current_chr_dir );

            # Define a file path for the current chromosome
            my $current_chr_fh = $current_chr_dir . '/split_reads.bed';

            # If the current chromosome file happens to exist -- delete it.
            if ( -e $current_chr_fh ) {
                unlink ($current_chr_fh);
            }

            # Store the string in the split_files Hash Ref -- indexed by
            # chromosome
            $split_files->{$chr} = $current_chr_fh;
        }

        # Run the _check_and_split subroutine which returns a Hash Ref of the
        # file paths of files indexed by chromosome
        my $split_file_paths = $self->_check_and_split(
            $file_type_map->{$file_type}, 
            $split_files 
        );

        # End the current thread and return the data
        $pm->finish(0, 
            {
                file_type   =>  $file_type,
                files       =>  $split_file_paths,
            }
        );
    }

    # Make sure all the threads have finished executing
    $pm->wait_all_children;

    return $split_files;
}

=head2 _check_and_split

This subroutine checks both of the user-defined BED-format files to ensure that
they are properly formatted and then splits the files by chromosome string.

=cut

sub _check_and_split {
	my $self = shift;
    my $bed_fh = shift;
    my $files_by_chr_hash = shift;

    # Pre-declare a Hash Ref to hold the reads per chromosome
    my $reads_per_chr_hash = {};

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

        # Now that the line has been checked, add it to the appropriate Array
        # Ref of reads per chromosome
        push( @{$reads_per_chr_hash->{$chr}},
            join("\t",
                $chr,
                $start,
                $stop,
                $name,
                $score,
                $strand
            )
        );

        # Test to make sure that the size of the current reads_per_chr_hash
        # Array ref is less than 5,000,000 reads. If it is, print the reads to
        # file and empty the Array Ref.
        if ( scalar (@{$reads_per_chr_hash->{$chr}}) > 5000000 ) {

            # Open the corresponding file for this chromosome from
            # files_by_chr_hash and write the lines. Be sure to add an extra
            # newline character.
            open my $chr_out, ">>", $files_by_chr_hash->{$chr} or croak
            "\n\nCould not write to " . $files_by_chr_hash->{$chr} . " $!\n\n";
            print $chr_out join("\n", @{$reads_per_chr_hash->{$chr}}, "\n");
            close $chr_out;

            # Reset the Array Ref
            $reads_per_chr_hash->{$chr} = [];
        }
	}

    # Iterate through the reads_per_chr_hash and print the remaining reads to
    # file. There is no need to add an extra newline character to these files.
    foreach my $chr ( keys %{$reads_per_chr_hash} ) {

        # Test to make sure there are reads to be printed
        if ( scalar ( @{$reads_per_chr_hash->{$chr}} ) ) {
            # Open the corresponding file from files_by_chr_hash
            open my $chr_out, ">>", $files_by_chr_hash->{$chr} or croak
            "\n\nCould not write to " . $files_by_chr_hash->{$chr} . " $!\n\n";
            print $chr_out join("\n", @{$reads_per_chr_hash->{$chr}});
            close $chr_out;

            # Reset the Array Ref
            $reads_per_chr_hash->{$chr} = [];
        }
    }

    return $files_by_chr_hash;
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

1;
