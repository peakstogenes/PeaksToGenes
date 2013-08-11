
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

has schema	=>	(
    is			=>	'ro',
    isa			=>	'PeaksToGenes::Schema',
    writer		=>	'_set_schema',
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
            cascade_delete	=>	1
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

1;
