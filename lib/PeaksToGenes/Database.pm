
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
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>

package PeaksToGenes::Database 0.001;

use Moose::Role;
use Carp;
use Parallel::ForkManager;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Schema;
use DBIx::Class::ResultClass::HashRefInflator;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Database

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=head1 DESCRIPTION

This Moose role is designed to export the methods to access the PeaksToGenes
database through a DBIx::Class object.

=head1 SYNOPSIS

with 'PeaksToGenesDatabase';

$self->schema->....

=cut

=head2 schema

This Moose attribute holds the DBI connection to the PeaksToGenes database.

=cut

has schema  =>  (
    is          =>  'ro',
    isa         =>  'PeaksToGenes::Schema',
    writer      =>  '_set_schema',
    predicate   =>  'has_schema',
);

before  'schema'    =>  sub {
    my $self = shift;
    unless ($self->has_schema) {
        $self->_set_schema($self->_define_schema);
    }
};

sub _define_schema  {
    my $self = shift;
    my $dsn = "dbi:SQLite:$FindBin::Bin/../db/peakstogenes.db";
    my $schema = PeaksToGenes::Schema->connect($dsn, '', '', {
            cascade_delete  =>  1
        }
    );
    return $schema;
}

=head2 installed_genomes

This Moose attribute holds an Hash Ref of Hash Ref of genomes installed in the
PeaksToGenes database.

=cut

has installed_genomes   =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_installed_genomes',
    writer      =>  '_set_installed_genomes',
);

before  'installed_genomes' =>  sub {
    my $self = shift;
    unless ( $self->has_installed_genomes ) {
        $self->_set_installed_genomes($self->_get_installed_genomes);
    }
};

=head2 _get_installed_genomes

This subroutine interacts with the PeaksToGenes database and returns the
'AvailableGenome' table as a Hash Ref indexed by genome string.

=cut

sub _get_installed_genomes {
    my $self = shift;

    # Pre-declare a Hash Ref of genome Hash Refs
    my $genome_hash_refs = {};

    # Create a result set for the Available Genome table
    my $availabe_genome_rs = $self->schema->resultset('AvailableGenome');

    # Inflate the table
    $availabe_genome_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    while ( my $availabe_genome_hash = $availabe_genome_rs->next ) {
        $genome_hash_refs->{$availabe_genome_hash->{genome}} = $availabe_genome_hash;
    }

    return $genome_hash_refs;
}

=head2 experiment_names

This Moose attribute holds an Hash Ref of Hash Refs of the information
pertaining to experiments that have been installed in the PeaksToGenes database.

=cut

has experiment_names    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_experiment_names',
    writer      =>  '_set_experiment_names',
);

before  'experiment_names'  =>  sub {
    my $self = shift;
    unless ( $self->has_experiment_names ) {
        $self->_set_experiment_names($self->_get_experiment_names);
    }
};

=head2 _get_experiment_names

This private subroutine is called dynamically to interact with the PeaksToGenes
database to return a Hash Ref structure of Hash Refs of information pertaining
to the experiments installed in the PeaksToGenes database.

=cut

sub _get_experiment_names   {
    my $self = shift;

    # Pre-declare a Hash Ref to hold the installed experiments information
    my $installed_experiments_hash = {};

    # Create a result set for the Available Genome table
    my $installed_experiments_rs = $self->schema->resultset('Experiment');

    # Inflate the table
    $installed_experiments_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    while ( my $installed_experiment_hash = $installed_experiments_rs->next ) {
        $installed_experiments_hash->{$installed_experiment_hash->{experiment}} = $installed_experiment_hash;
    }

    return $installed_experiments_hash;
}

=head2 transcripts

This Moose attribute holds a Hash Ref of the transcript information stored in
the PeaksToGenes database. This Hash Ref is indexed by genome string, RefSeq
transcript ID and then has a Hash Ref of transcript info as the value.

=cut

has transcripts =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_transcripts',
    writer      =>  '_set_transcripts',
);

before  'transcripts'   =>  sub {
    my $self = shift;
    unless ($self->has_transcripts) {
        $self->_set_transcripts($self->_get_transcripts);
    }
};

=head2 _get_transcripts

This private subroutine is called dynamically to interact with the PeaksToGenes
database and extract the transcripts information. This subroutine returns a Hash
Ref that is indexed by RefSeq accession with a Hash Ref containing the accession
and the genome_id as a value.

=cut

sub _get_transcripts    {
    my $self = shift;

    # Pre-declare a Hash Ref to hold the transcripts information
    my $transcript_hash = {};

    # Create a result set for the Available Genome table
    my $transcripts_rs = $self->schema->resultset('Transcript');

    # Inflate the table
    $transcripts_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    # Extract the RefSeq accession and table row ID for each transcript, storing
    # the information in the transcript_hash.
    while ( my $transcripts_hash = $transcripts_rs->next ) {
        $transcript_hash->{$transcripts_hash->{genome_id}}{$transcripts_hash->{transcript}}
        = $transcripts_hash;
    }

    return $transcript_hash;
}

=head2 chromosome_sizes

This Moose attribute holds a Hash Ref of chromosome sizes info indexed by
genome string referenced from installed_genomes.

=cut

has chromosome_sizes  =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_chromosome_sizes',
    writer      =>  '_set_chromosome_sizes',
);

before  'chromosome_sizes'    =>  sub {
    my $self = shift;
    unless ( $self->has_chromosome_sizes ) {
        $self->_set_chromosome_sizes($self->_get_chromosome_sizes);
    }
};

=head2 _get_chromosome_sizes

This private subroutine is called to interact with the PeaksToGenes database to
extract the ChromosomeSize table and return a Hash Ref of chromosome size info
indexed by genome strings that are referenced from installed_genomes.

=cut

sub _get_chromosome_sizes {
    my $self = shift;

    # Pre-declare a Hash Ref to hold the chromosome sizes information indexed
    # by genome string.
    my $chromosome_sizes_files_hash = {};

    # Create a result set for the Available Genome table
    my $chromosome_sizes_rs = $self->schema->resultset('ChromosomeSize');

    # Inflate the table
    $chromosome_sizes_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    while ( my $chromosome_size_file_hash = $chromosome_sizes_rs->next ) {
        $chromosome_sizes_files_hash->{$chromosome_size_file_hash->{genome_id}}
        = $chromosome_size_file_hash->{chromosome_sizes_file};
    }

    # Pre-declare a Hash Ref to hold the chromosome sizes info
    my $chromosome_sizes_info_hash = {};

    # Iterate through the genomes in installed_genomes, match the genome id
    # between the chromosome_sizes_files_hash and the genome string in
    # installed_genomes.
    foreach my $genome_string ( keys %{$self->installed_genomes} ) {

        # Copy the chromosome sizes file into a local scalar string
        my $fh = $chromosome_sizes_files_hash->{$self->installed_genomes->{$genome_string}{id}};

        # Open the chromosome sizes file, iterate through the lines, parse the
        # lines and store the chromosome sizes info in the
        # chromosome_sizes_info_hash indexed by genome string
        open my $file, "<", $fh or croak 
        "\n\nCould not read from $fh. Please check your PeaksToGenes installation.\n\n";
        while (<$file>) {
            my $line = $_;
            chomp($line);
            my ($chr, $length) = split(/\t/, $line);
            $chromosome_sizes_info_hash->{$genome_string}{$chr} = $length;
        }
        close $file;
    }

    return $chromosome_sizes_info_hash;
}

=head2 index_file_names

This Moose attribute holds a Hash Ref of ordered Array Refs indexed by genome
string.

=cut

has index_file_names    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_index_file_names',
    writer      =>  '_set_index_file_names',
);

before  'index_file_names'  =>  sub {
    my $self = shift;
    unless ($self->has_index_file_names) {
        $self->_set_index_file_names($self->_get_index_file_names);
    }
};

=head2 _get_index_file_names

This private subroutine is called to extract an ordered Array Ref of relative
coordinates files for each genome installed in the PeaksToGenes database. These
ordered Array Refs are organized in a Hash Ref -- indexed by genome string.

=cut

sub _get_index_file_names   {
    my $self = shift;

    # Pre-declare a Hash Ref to hold the ordered Array Refs
    my $indexed_files_hash = {};

    # Iterate through the genomes in installed_genomes
    foreach my $genome_string ( keys %{$self->installed_genomes} ) {
        push(@{$indexed_files_hash->{$genome_string}},
            $self->installed_genomes->{$genome_string}{_5prime_utr_peaks_file},
            $self->installed_genomes->{$genome_string}{_exons_peaks_file},
            $self->installed_genomes->{$genome_string}{_introns_peaks_file},
            $self->installed_genomes->{$genome_string}{_3prime_utr_peaks_file},
        );
        for ( my $i = 0; $i < 10; $i++ ) {
            push(@{$indexed_files_hash->{$genome_string}},
                $self->installed_genomes->{$genome_string}{'_gene_body_' .
                ($i*10) . '_to_' . (($i+1)*10) . '_peaks_file'},
            );
        }
        for ( my $i = 0; $i < 10; $i++ ) {
            push(@{$indexed_files_hash->{$genome_string}},
                $self->installed_genomes->{$genome_string}{'_' . ($i+1) .
                '_steps_downstream_peaks_file'},
            );
            unshift(@{$indexed_files_hash->{$genome_string}},
                $self->installed_genomes->{$genome_string}{'_' . ($i+1) .
                '_steps_upstream_peaks_file'},
            );
        }
    }

    return $indexed_files_hash;
}

=head2 test_genome

This subroutine determines whether a given genome is valid and can be found in
the PeaksToGenes database. This subroutine takes a genome string as an argument
and will kill execution if the user-defined genome string is not valid.

=cut

sub test_genome {
    my $self = shift;
    my $genome = shift;

    # Search the installed_genomes attribute to see if the user-defined genome
    # has been installed
    unless ( $self->installed_genomes->{$genome} ) {
        croak "\n\nThe user-defined genome " . $genome . " has not been " .
        "indexed. Please use the 'update' function to add the genome.\n\n";
    }
}

=head2 test_name

This subroutine determines whether a given experiment name has been entered into
the PeaksToGenes database. If the experiment name has already been used, this
subroutine kills execution and returns a message to the user.

=cut

sub test_name   {
    my $self = shift;
    my $name = shift;

    # Search the experiment_names attribute determine if the user-defined
    # experiment name has already been defined.
    if ( $self->experiment_names->{$name} ) {
        croak "\n\nThe user-defined experiment name: " . $name . ". Is " .
        "already in use. Either delete those entries in the database or choose " .
        "another experiment name.\n\n";
    }
}

=head2 parse_and_store

This subroutine is the main function called by the PeaksToGenes::Annotate
controller class. This function takes the following parameters as arguments:

    A Hash Ref of binding information indexed by RefSeq transcript accession and relative location
    The genome string
    The name of the experiment

This subroutine parses these information into an insert statement for DBIx and
inserts the relevant information into the PeaksToGenes database. Nothing is
returned by this function, but it will kill execution if there are problems.

=cut

sub parse_and_store {
    my $self = shift;
    my $binding_info = shift;
    my $genome = shift;
    my $experiment_name = shift;

    # Copy the genome ID into a local variable
    my $genome_id = $self->get_genome_id($genome);

    # Pre-declare an Array Ref (and partially define it) inside of a Hash Ref to
    # hold the insert lines for the tables in the PeaksToGenes database.
    my $insert = {
        genome_id                   =>  $genome_id,
        experiment                  =>  $experiment_name,
        gene_body_numbers_of_peaks  =>  [],
        downstream_numbers_of_peaks =>  [],
        upstream_numbers_of_peaks   =>  [],
        transcript_numbers_of_peaks =>  [],
    };

    # Iterate through the genes defined as the first set of keys and create
    # insertion statements for each gene that will be added to the main
    # insertion table
    foreach my $accession ( keys %{$binding_info} ) {

        # Copy the transcript ID into a local variable
        my $transcript_id =
        $self->transcripts->{$genome_id}{$accession}{id};

        # Make sure the transcript ID was found. If not, die.
        unless ( $transcript_id ) {
            croak "\n\nUnable to extract the transcript ID for $accession.\n\n";
        }

        # Pre-define a Hash Ref for each type of insert for this line
        my $upstream_number_of_peaks_insert_line = {
            gene        =>  $transcript_id,
            genome_id   =>  $genome_id,
        };

        my $downstream_number_of_peaks_insert_line = {
            gene        =>  $transcript_id,
            genome_id   =>  $genome_id,
        };

        my $gene_body_number_of_peaks_insert_line = {
            gene        =>  $transcript_id,
            genome_id   =>  $genome_id,
        };

        my $transcript_number_of_peaks_insert_line = {
            gene        =>  $transcript_id,
            genome_id   =>  $genome_id,
            '_3prime_utr_number_of_peaks'   =>
            $binding_info->{$accession}{'_3prime_utr_number_of_peaks'},
            '_5prime_utr_number_of_peaks'   =>
            $binding_info->{$accession}{'_5prime_utr_number_of_peaks'},
            '_exons_number_of_peaks'   =>
            $binding_info->{$accession}{'_exons_number_of_peaks'},
            '_introns_number_of_peaks'   =>
            $binding_info->{$accession}{'_introns_number_of_peaks'},
        };

        # Use a C-style loop to add the upstream, downstream and gene body
        # binding info to their respective Hash Refs
        for ( my $i = 0; $i < 10; $i++ ) {

            # Add the gene body info
            my $gene_body_location_string = '_gene_body_' . ($i*10) . 
            '_to_' . (($i+1)*10) . '_number_of_peaks';
            $gene_body_number_of_peaks_insert_line->{$gene_body_location_string}
            = $binding_info->{$accession}{$gene_body_location_string};

            # Add the upstream binding info
            my $upstream_location_string = '_' . ($i+1) .
            '_steps_upstream_number_of_peaks';
            $upstream_number_of_peaks_insert_line->{$upstream_location_string} =
            $binding_info->{$accession}{$upstream_location_string};

            # Add the downstream binding info
            my $downstream_location_string = '_' . ($i+1) .
            '_steps_downstream_number_of_peaks';
            $downstream_number_of_peaks_insert_line->{$downstream_location_string} =
            $binding_info->{$accession}{$downstream_location_string};
        }

        # Add the lines to the insert statement
        push(@{$insert->{gene_body_numbers_of_peaks}},
            $gene_body_number_of_peaks_insert_line
        );
        push(@{$insert->{upstream_numbers_of_peaks}},
            $upstream_number_of_peaks_insert_line
        );
        push(@{$insert->{downstream_numbers_of_peaks}},
            $downstream_number_of_peaks_insert_line
        );
        push(@{$insert->{transcript_numbers_of_peaks}},
            $transcript_number_of_peaks_insert_line
        );
    }

    # Use a transaction scope guard to rapidly insert the statement into the
    # PeaksToGenes database.
    my $guard = $self->schema->txn_scope_guard;

    # Insert the statement
    $self->schema->resultset('Experiment')->populate([$insert]);

    # After the transaction is complete, it is necessary to explicitly
    # commit the transaction
    $guard->commit;
}

=head2 get_genome_id

This subroutine is passed a genome string and returns the integer value that
corresponds to the genome ID of the user-defined genome string. If the
user-defined genome is not found the program dies and prints an error message to
STDOUT.

=cut

sub get_genome_id   {
    my $self = shift;
    my $genome_string = shift;

    # Access the Moose attribute installed_genomes to return the ID
    if ( $self->installed_genomes->{$genome_string}{id} ) {
        return $self->installed_genomes->{$genome_string}{id};
    } else {
        croak "\n\nCould not find the genome ID for the user-defined genome: " .
        $genome_string . ". Please check that this genome has been " .
        "installed.\n\n";
    }
}

1;
