
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

package PeaksToGenes::Update::UCSC 0.001;
use Moose::Role;
use Carp;
use Statistics::Descriptive;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::UCSC;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Update::UCSC

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=cut

=head1 DESCRIPTION

This module is called by the PeaksToGenes::Update module to interact with the
UCSC Genome MySQL Browser to download the required minimal base files for the
index.

=cut

=head2 valid_genome

This Moose attribute holds the genome string once it has been validated against
the defined known genome strings for UCSC.

=cut

has valid_genome    =>  (
    is          =>  'ro',
    isa         =>  'Str',
    writer      =>  '_set_valid_genome',
);

=head2 genome_string

This Moose attribute holds a '-'-delimited string that combines the genome
string and the size of the step that was used to define the given genome. This
attribute is created dynamically.

=cut

has genome_string   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    predicate   =>  'has_genome_string',
    writer      =>  '_set_genome_string',
);

before  'genome_string' =>  sub {
    my $self = shift;
    unless ( $self->has_genome_string ) {
        $self->_set_genome_string(
            join('-',
                $self->valid_genome,
                $self->step_size
            )
        );
    }
};

=head2 set_genome_and_step_size

This subroutine is called to set the genome and the step size for the
installation of a genome using this role.

=cut

sub set_genome_and_step_size {
    my $self = shift;
    my $genome = shift;
    my $step_size  = shift;

    # Make sure the genome define is valid. If it is, store the string in the
    # genome attribute, otherwise die horribly.
    if ( $self->genome_info->{$genome} ) {
        $self->_set_valid_genome($genome);
    } else {
        croak "\n\nThe genome $genome is not a valid UCSC genome\n\n";
    }

    # If the user has set a step size, store it in  the step_size attribute.
    if ( $step_size ) {
        $self->_set_step_size($step_size);
    }
}

=head2 fetch_tables

This is the main subroutine called externally to interact with the UCSC database
and extract the required information to install a genome database. This
subroutine expects one required argument and one optional argument. The required
argument is the UCSC genome string. The optional argument is the size of the
steps to use for the given genome.

=cut

sub fetch_tables    {
    my $self = shift;

    # Return the genome_string, the path to the relative coordinates file, and
    # the path to the chromosome sizes file
    return ( 
        $self->genome_string, 
        $self->file_names,
        $self->chromosome_sizes_file
    );
}

=head2 step_size

This Moose attribute is either set by the user or dynamically determined by the
size of the genome.

=cut

has step_size   =>  (
    is          =>  'ro',
    isa         =>  'Int',
    predicate   =>  'has_step_size',
    writer      =>  '_set_step_size',
);

before  'step_size' =>  sub {
    my $self = shift;
    unless ($self->has_step_size) {

        # Dynamically determine the step size to use based on the genomic
        # architecture of the user-defined genome
        $self->_set_step_size($self->_dynamically_determine_step);
    }
};

=head2 _dynamically_determine_step

This subroutine is called to dynamically determine the step size based on the
genomic architecture of the user-defined genome. This subroutine returns a
positive integer.

To make this calculation, this subroutine finds the median value for the lengths
of all genes in the user-defined genome and returns a rounded integer that is
1/10th the median gene length.

=cut

sub _dynamically_determine_step {
    my $self = shift;

    # Pre-declare an Array Ref to hold the lengths of all genes in the given
    # genome.
    my $gene_lengths = [];

    # Iterate through the genes in genomic_positions_tables. For each
    # transcript, add the length of the gene to the gene_lengths Array Ref
    foreach my $transcript ( keys %{$self->genomic_coordinates} ) {
        push(@{$gene_lengths},
            abs($self->genomic_coordinates->{$transcript}{txEnd} -
                $self->genomic_coordinates->{$transcript}{txStart}
            )
        );
    }

    # Create an instance of Statistics::Descriptive to calculate the median
    # gene length
    if ( @{$gene_lengths} ) {
        my $stat = Statistics::Descriptive::Full->new();
        $stat->add_data(@{$gene_lengths});
        return ( int ( ($stat->median() / 10) + 0.5) );
    } else {
        croak "\n\nUnable to dynamically define a step size for the " .
        $self->valid_genome . " genome\n\n";
    }
}

=head2 genome_info

This Moose attribute returns a Hash Ref that defined the UCSC names of valid
genomes that can be used with the current version of PeaksToGenes.

=cut

has genome_info	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[Str]',
	required	=>	1,
	default		=>	sub {
		my $self = shift;
		my $genome_info = {
			hg19	=>	1,
			hg18	=>	1,
			hg17	=>	1,
			hg16	=>	1,
			panTro3	=>	1,
			panTro2	=>	1,
			panTro1	=>	1,
			ponAbe2	=>	1,
			rheMac2	=>	1,
			calJac3	=>	1,
			calJac1	=>	1,
			mm10	=>	1,
			mm9	=>	1,
			mm8	=>	1,
			mm7	=>	1,
			rn5	=>	1,
			rn4	=>	1,
			rn3	=>	1,
			cavPor3	=>	1,
			oryCun2	=>	1,
			oviAri1	=>	1,
			bosTau7	=>	1,
			bosTau6	=>	1,
			bosTau4	=>	1,
			bosTau3	=>	1,
			bosTau2	=>	1,
			equCab2	=>	1,
			equCab1	=>	1,
			felCat4	=>	1,
			felCat3	=>	1,
			canFam3	=>	1,
			canFam2	=>	1,
			canFam1	=>	1,
			monDom5	=>	1,
			monDom4	=>	1,
			monDom1	=>	1,
			ornAna1	=>	1,
			galGal4	=>	1,
			galGal3	=>	1,
			galGal2	=>	1,
			taeGut1	=>	1,
			xenTro3	=>	1,
			xenTro2	=>	1,
			xenTro1	=>	1,
			danRer7	=>	1,
			danRer6	=>	1,
			danRer5	=>	1,
			danRer4	=>	1,
			danRer3	=>	1,
			fr3	=>	1,
			fr2	=>	1,
			fr1	=>	1,
			gasAcu1	=>	1,
			oryLat2	=>	1,
			dm3	=>	1,
			dm2	=>	1,
			dm1	=>	1,
			ce10	=>	1,
			ce6	=>	1,
			ce4	=>	1,
			ce2	=>	1,
			ce10	=>	1,
		};
		return $genome_info;
	},
);

=head2 chromosome_sizes_hash

This Moose attribute holds a Hash Ref of chromosome sizes fetched from the UCSC
MySQL server.

=cut

has chromosome_sizes_hash    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_chromosome_sizes_hash',
    writer      =>  '_set_chromosome_sizes_hash'
);

before 'chromosome_sizes_hash'   =>  sub {
    my $self = shift;
    unless ( $self->has_chromosome_sizes_hash ) {
        $self->_set_chromosome_sizes_hash($self->_get_chromosome_sizes_hash);
    }
};

sub _get_chromosome_sizes_hash    {
    my $self = shift;

    # Connect to the UCSC MySQL Browser
    my $schema =
    PeaksToGenes::UCSC->connect('dbi:mysql:host=genome-mysql.cse.ucsc.edu;database='
        . $self->valid_genome, "genome");
    # Get the chromosome sizes file from UCSC
    my $raw_chrom_sizes = $schema->storage->dbh_do(
        sub {
            my ($storage, $dbh, @args) = @_;
            $dbh->selectall_hashref("SELECT chrom, size FROM chromInfo",
                ["chrom"]);
        },
    );

    # Pre-declare a Hash Ref to hold the final information for the chromosome sizes
    my $chrom_sizes = {};

    # Parse the chromosome sizes file into an easier to use form
    foreach my $chromosome (keys %$raw_chrom_sizes) {
        $chrom_sizes->{$chromosome} = $raw_chrom_sizes->{$chromosome}{size};
    }

    return $chrom_sizes;
}

=head2 genomic_coordinates

This Moose attribute holds the positions of all RefSeq transcripts in the user-defined genome in Hash Ref format.

=cut

has genomic_coordinates    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    predicate   =>  'has_genomic_coordinates',
    writer      =>  '_set_genomic_coordinates',
);

before 'genomic_coordinates'   =>  sub {
    my $self = shift;
    unless ( $self->has_genomic_coordinates ) {
        $self->_set_genomic_coordinates($self->_get_genomic_coordinates);
    }
};

sub _get_genomic_coordinates {
	my $self = shift;

	# Define the columns to fetch from the UCSC MySQL browser
	my $column_names = [
		"chrom",
		"txStart",
		"txEnd",
		"cdsStart",
		"cdsEnd",
		"exonCount",
		"exonStarts",
		"exonEnds",
		"name",
		"strand",
	];

	# Create a string for the DBI call
	my $col_string = join(", ", @$column_names);

	# Connect to the UCSC MySQL Browser
	my $schema =
    PeaksToGenes::UCSC->connect('dbi:mysql:host=genome-mysql.cse.ucsc.edu;database='
        . $self->valid_genome, "genome");

	# Extract all of the RefSeq gene coordinates
	my $refseq = $schema->storage->dbh_do(
		sub {
			my ($storage, $dbh, @args) = @_;
			$dbh->selectall_hashref("SELECT $col_string FROM refGene",
				["name"]);
		},
	);

	return $refseq;
}

=head2 relative_coordinates

This Moose attribute holds the relative coordinates for each transcript at each
relative genomic position. This attribute is a Hash Ref that is indexed by
relative genomic position and an Array Ref of coordinates in BED format.

=cut

has relative_coordinates    =>  (
    is          =>  'ro',
    isa         =>  'HashRef',
    writer      =>  '_set_relative_coordinates',
    predicate   =>  'has_relative_coordinates',
);

before  'relative_coordinates'  =>  sub {
    my $self = shift;
    unless ( $self->has_relative_coordinates ) {
        $self->_set_relative_coordinates($self->_define_relative_coordinates);
    }
};

=head2 _define_relative_coordinates

This subroutine is called to iterate through the transcripts defined in
genomic_coordinates and define the coordinates of the 34 relative genomic
positions. These coordinates are stored in a Hash Ref that is indexed by
relative genomic position and has an Array Ref of BED format coordinates for
each Key value set.

=cut

sub _define_relative_coordinates    {
    my $self = shift;

    # Pre-declare a Hash Ref to hold the genomic coordinates
    my $relative_coordinates_hash = {};

    # Iterate through the transcripts defined in genomic_coordinates. For each
    # transcript, define the relative coordinates for each set of relative
    # coordinate types.
    foreach my $transcript ( keys %{$self->genomic_coordinates} ) {


        # Calculate the length of the gene body, and divide it into 10
        # approximately equal lengths.
        my $gene_body_length = $self->genomic_coordinates->{$transcript}{txEnd}
        - $self->genomic_coordinates->{$transcript}{txStart};
        my $decile_length = int(($gene_body_length / 10) + 0.5);

        # Get the gene body coordinates
        if ( $self->genomic_coordinates->{$transcript}{strand} eq '+' ) {
            for ( my $i = 1; $i < 10; $i++ ) {

                # Calculate the decile coordinates of the first 9 deciles
                my $decile_start =
                $self->genomic_coordinates->{$transcript}{txStart} +
                ($decile_length * ($i-1));
                my $decile_stop = $decile_start + $decile_length - 1;

                # Add the decile coordinates to the relative_coordinates_hash
                push (@{$relative_coordinates_hash->{decile_coordinates}{$i}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $decile_start, 
                        $decile_stop,
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            }

            # Calculate the decile coordinates of the last (tenth) decile.  This
            # function ensures that the ninth and tenth decile do not overlap
            # and that the tenth decile is at least 1 bp long that does not
            # extend beyond the length of the gene.
            my $tenth_decile_start = (
                ( $self->genomic_coordinates->{$transcript}{txStart} + 
                    ( 9 * $decile_length ) ) <
                $self->genomic_coordinates->{$transcript}{txEnd} ?
                ( $self->genomic_coordinates->{$transcript}{txStart} + 
                    ( 9 * $decile_length )) :
                $self->genomic_coordinates->{$transcript}{txEnd}
            );

            # Add the tenth decile coordinates to the relative_coordinates_hash 
            push( @{$relative_coordinates_hash->{decile_coordinates}{10}},
                join("\t",
                    $self->genomic_coordinates->{$transcript}{chrom},
                    $tenth_decile_start,
                    $self->genomic_coordinates->{$transcript}{txEnd},
                    $self->genomic_coordinates->{$transcript}{name},
                )
            );
        } elsif ( $self->genomic_coordinates->{$transcript}{strand} eq '-' ) {
            for ( my $i = 1; $i < 10; $i++ ) {

                # Calculate the decile coordinates of the first 9 deciles
                my $decile_start =
                $self->genomic_coordinates->{$transcript}{txEnd} -
                ($decile_length * $i);
                my $decile_stop = (
                    ($decile_start + $decile_length + 1) <=
                    $self->genomic_coordinates->{$transcript}{txEnd} ?
                    ($decile_start + $decile_length + 1) :
                    $self->genomic_coordinates->{$transcript}{txEnd}
                );

                # Add the decile coordinates to the relative_coordinates_hash
                push (@{$relative_coordinates_hash->{decile_coordinates}{$i}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $decile_start, 
                        $decile_stop,
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            }

            # Calculate the decile coordinates of the last (tenth) decile.  This
            # function ensures that the ninth and tenth decile do not overlap
            # and that the tenth decile is at least 1 bp long that does not
            # extend beyond the length of the gene.
            my $tenth_decile_end = (
                ( $self->genomic_coordinates->{$transcript}{txEnd} - 
                    ( 9 * $decile_length ) + 1 ) >
                $self->genomic_coordinates->{$transcript}{txStart} ?
                ( $self->genomic_coordinates->{$transcript}{txStart} + 
                    ( 9 * $decile_length ) + 1) :
                $self->genomic_coordinates->{$transcript}{txStart}
            );

            # Add the tenth decile coordinates to the relative_coordinates_hash 
            push( @{$relative_coordinates_hash->{decile_coordinates}{10}},
                join("\t",
                    $self->genomic_coordinates->{$transcript}{chrom},
                    $self->genomic_coordinates->{$transcript}{txStart},
                    $tenth_decile_end,
                    $self->genomic_coordinates->{$transcript}{name},
                )
            );
        }

        # Get the upstream, and downstream coordinates
        for ( my $i = 0; $i < 10; $i++ ) {

            # Use the coordinates for the given accession and extend the
            # coordinates based on the iterator extension values and within the
            # bounds of the chromosome size. If the coordinates are valid, push
            # them on to the end of the corresponding Array Ref within the
            # relative_coordinates_hash.
            #
            # Pre-declare two integers for the extended start and stop for
            # upstream and downstream, respectively.
            my $upstream_extended_start = 0;
            my $upstream_extended_stop = 0;
            my $downstream_extended_start = 0;
            my $downstream_extended_stop = 0;

            # Depending on the strand the gene is located on, the operations for
            # calculating the relative genomic windows will be different.
            if ( $self->genomic_coordinates->{$transcript}{strand} eq '+' ) {

                # Calculate the upstream coordinates
                $upstream_extended_start = $self->genomic_coordinates->{$transcript}{txStart} -
                ($i*$self->step_size);
                $upstream_extended_stop = $self->genomic_coordinates->{$transcript}{txStart} -
                ($i*$self->step_size) + $self->step_size - 1;

                # Calculate the downstream coordinates
                $downstream_extended_start = $self->genomic_coordinates->{$transcript}{txEnd} +
                ($i*$self->step_size) - $self->step_size;
                $downstream_extended_stop = $self->genomic_coordinates->{$transcript}{txEnd} +
                (($i*$self->step_size) - 1);

            } elsif ( $self->genomic_coordinates->{$transcript}{strand} eq '-' ) {

                # Calculate the upstream coordinates
                $upstream_extended_start = $self->genomic_coordinates->{$transcript}{txEnd} +
                ($i*$self->step_size) - $self->step_size;
                $upstream_extended_stop = $self->genomic_coordinates->{$transcript}{txEnd} +
                (($i*$self->step_size) - 1);

                # Calculate the downstream coordinates
                $downstream_extended_start = $self->genomic_coordinates->{$transcript}{txStart}
                - ($i*$self->step_size);
                $downstream_extended_stop = $self->genomic_coordinates->{$transcript}{txStart}
                - ($i*$self->step_size) + $self->step_size - 1;
            } else {
                croak "\n\nThere was a problem getting the appropriate database " . 
                "information for the genome specified. Please check that the UCSC " . 
                "MySQL tables have not changed.\n\n";
            }

            # Test to make sure that the extended coordinates are valid within
            # the constraints of the chromosome.
            if (($downstream_extended_start > 0) && 
                ($downstream_extended_start <=
                    $self->chromosome_sizes_hash->{$self->genomic_coordinates->{$transcript}{chrom}})
                && ($downstream_extended_stop > 0) && 
                ($downstream_extended_start <=
                    $self->chromosome_sizes_hash->{$self->genomic_coordinates->{$transcript}{chrom}}))
            {

                # Add the coordinates to the Array Ref
                push( @{$relative_coordinates_hash->{Downstream}{$i}}, 
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom},
                        $downstream_extended_start, 
                        $downstream_extended_stop,
                        $self->genomic_coordinates->{$transcript}{name},
                    )
                );
            }
            if (($upstream_extended_start > 0) && 
                ($upstream_extended_start <= 
                    $self->chromosome_sizes_hash->{$self->genomic_coordinates->{$transcript}{chrom}})
                && ($upstream_extended_stop > 0) && 
                ($upstream_extended_start <=
                    $self->chromosome_sizes_hash->{$self->genomic_coordinates->{$transcript}{chrom}}))
            {
                # Add the coordinates to the Array Ref
                push( @{$relative_coordinates_hash->{Upstream}{$i}}, 
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom},
                        $upstream_extended_start, 
                        $upstream_extended_stop,
                        $self->genomic_coordinates->{$transcript}{name},
                    )
                );
            }
        }

        # Get the intron, exon, and UTR coordinates
        #
        # Test to make sure that the transcription start site and the coding start site
        # are different, if they are push the coordinates onto the 5'-UTR coordinates
        # or 3'-UTR coordinates depending on the strand
        if ( $self->genomic_coordinates->{$transcript}{txStart} !=
            $self->genomic_coordinates->{$transcript}{cdsStart} ) {

            # Positive strand corresponds to the 5' UTR while negative strand
            # corresponds to the 3' UTR
            if ( $self->genomic_coordinates->{$transcript}{strand} eq '+' ) {
                push(@{$relative_coordinates_hash->{five_prime_utr_coordinates}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $self->genomic_coordinates->{$transcript}{txStart},
                        ($self->genomic_coordinates->{$transcript}{cdsStart} - 1), 
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            } elsif ( $self->genomic_coordinates->{$transcript}{strand} eq '-' ) {
                push(@{$self->genomic_coordinates->{three_prime_utr_coordinates}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $self->genomic_coordinates->{$transcript}{txStart},
                        ($self->genomic_coordinates->{$transcript}{cdsStart} - 1), 
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            }
        }
        # Test to make sure that the transcription termination site and the
        # coding termination site are different, if they are push the
        # coordinates onto the 5'-UTR coordinates or 3'-UTR coordinates
        # depending on the strand.
        if ( $self->genomic_coordinates->{$transcript}{txEnd} !=
            $self->genomic_coordinates->{$transcript}{cdsEnd} ) {

            # In this case positive strand corresponds to the 3'-UTR, while the
            # negative strand corresponds to the 5'-UTR
            if ( $self->genomic_coordinates->{$transcript}{strand} eq '+' ) {
                push(@{$relative_coordinates_hash->{three_prime_utr_coordinates}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $self->genomic_coordinates->{$transcript}{cdsEnd},
                        ($self->genomic_coordinates->{$transcript}{txEnd} - 1), 
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            } elsif ( $self->genomic_coordinates->{$transcript}{strand} eq '-' ) {
                push(@{$relative_coordinates_hash->{five_prime_utr_coordinates}},
                    join("\t", 
                        $self->genomic_coordinates->{$transcript}{chrom}, 
                        $self->genomic_coordinates->{$transcript}{cdsEnd},
                        ($self->genomic_coordinates->{$transcript}{txEnd} - 1), 
                        $self->genomic_coordinates->{$transcript}{name}
                    )
                );
            }
        }

        # Extract the coding exon and intron coordinates based on which strand
        # the gene is located
        my @exon_starts = split(/,/, $self->genomic_coordinates->{$transcript}{exonStarts});
        my @exon_ends = split(/,/, $self->genomic_coordinates->{$transcript}{exonEnds});
        if ( $self->genomic_coordinates->{$transcript}{strand} eq '+' ) {
            for ( my $i = 0; $i < @exon_starts; $i++ ) {
                if ( $exon_starts[$i] && $exon_ends[$i] ) {
                    push(
                        @{$relative_coordinates_hash->{exon_coordinates}},
                        join("\t",
                            $self->genomic_coordinates->{$transcript}{chrom}, 
                            $exon_starts[$i],
                            ($exon_ends[$i] - 1),
                            $self->genomic_coordinates->{$transcript}{name},
                        )
                    );
                }
            }

            # Calculate the intron coordinates if there are more than one exon
            # start
            for ( my $i = 0; $i < @exon_ends; $i++ ) {

                # Unless the current exon end is the last exon, calculate the
                # intron coordinates and add the to the
                # relative_coordinates_hash
                if ( $exon_starts[$i+1] ) {
                    push( @{$relative_coordinates_hash->{intron_coordinates}},
                        join("\t",
                            $self->genomic_coordinates->{$transcript}{chrom}, 
                            $exon_ends[$i],
                            ($exon_starts[$i+1] - 1),
                            $self->genomic_coordinates->{$transcript}{name},
                        )
                    );
                }
            }
        } elsif ( $self->genomic_coordinates->{$transcript}{strand} eq '-' ) {
            for ( my $i = @exon_starts; $i > 0; $i-- ) {
                if ( $exon_starts[$i] && $exon_ends[$i] ) {
                    push(@{$relative_coordinates_hash->{exon_coordinates}},
                        join("\t",
                            $self->genomic_coordinates->{$transcript}{chrom}, 
                            $exon_starts[$i],
                            ($exon_ends[$i] - 1),
                            $self->genomic_coordinates->{$transcript}{name},
                        )
                    );
                }
            }
            # Calculate the intron sizes if there is more than one exon start
            for ( my $i = (@exon_starts-1); $i > 0; $i-- ) {
                # Unless this is the last exon, calculate the intron coordinates
                # and add then to the relative_coordinates_hash
                if ( $exon_ends[$i-1] ) {
                    push(@{$relative_coordinates_hash->{intron_coordinates}},
                        join("\t",
                            $self->genomic_coordinates->{$transcript}{chrom}, 
                            $exon_ends[$i-1],
                            ($exon_starts[$i] - 1),
                            $self->genomic_coordinates->{$transcript}{name},
                        )
                    );
                }
            }
        }
    }

    return $relative_coordinates_hash;
}

#=head2 fetch_tables
#
#This subroutine is called by the PeaksToGenes::Update module to interact with
#the UCSC Genome MySQL browser to download the minimal index files in BED format.
#If this module is unable to download the required files, it will return an error
#to the PeaksToGenes::Update module, otherwise it will return an Array Ref of
#file names.
#
#=cut
#
#sub fetch_tables {
#	my $self = shift;
#
#	# Check to make sure that the genome defined by the user is a valid
#	# RefSeq genome
#	unless ( $self->genome_info->{$self->genome} ) {
#		croak "\n\nThe genome you have entered: " .
#        $self->genome . " is not a valid RefSeq genome. Please check to make" . 
#        " sure you have entered it correctly.\n\n"; 
#    }
#
#	# Use the file_names subroutine to create a folder in the static
#	# directory for the genome to be updated. This will also delete any
#	# existing folder. The file names are returned in the form of an Array
#	# Ref
#	my $file_strings = $self->file_names;
#
#	# Write the chromosome sizes to file 
#	my $chromosome_sizes_fh = $self->write_chromosome_sizes;
#
#	# Use the get_gene_body_coordinates subroutine to interact with the
#	# UCSC MySQL server and return the gene coordinates in the form of a
#	# Hash Ref
#	my $refseq = $self->get_gene_body_coordinates;
#
#	# Get the chromosome sizes file from UCSC
#	my $chrom_sizes = $self->chromosome_sizes;
#
#	# Make a call to the empty_genomic_coordinates subroutine to create a
#	# structure to store the genomic coordinates in
#	my $genomic_coordinates = $self->empty_genomic_coordinates;
#
#	# Iterate through the accessions returned from UCSC and calculate the
#	# coordinates needed for the upstream, downstream, UTRs, exons,
#	# introns, and gene body positions.
#	foreach my $accession (keys %$refseq) {
#		# Make a call to the get_upstream_and_downstream_coordinates
#		# subroutine to add to the genomic_coordinates Hash Ref of Array
#		# Refs of coordinates.
#		$genomic_coordinates =
#		$self->get_upstream_and_downstream_coordinates($refseq->{$accession},$chrom_sizes,
#			$genomic_coordinates);
#
#		# Make a call to the get_utrs_exon_and_introns subroutine to add
#		# the coordinates to the genomic_coordinates Hash Ref of Array Refs
#		# of coordinates
#		$genomic_coordinates =
#		$self->get_utrs_exon_and_introns($refseq->{$accession},
#			$genomic_coordinates);
#
#		# Make a call to the get_gene_body_coordinates subroutine to add
#		# the coordinates to the genomic_coordinates Hash Ref of Array Refs
#		# of coordinates
#		$genomic_coordinates =
#		$self->get_decile_coordinates($refseq->{$accession},
#			$genomic_coordinates);
#	}
#	# Make a call to the print_genomic_coordinates subroutine to print the
#	# coordinates to BED-format files in the static directory
#	$self->print_genomic_coordinates($file_strings, $genomic_coordinates);
#	return ($file_strings, $chromosome_sizes_fh);
#}

=head2 file_names

This Moose attribute holds an Array Ref of file names to which the relative
coordinates have been written to.

=cut

has file_names   =>  (
    is          =>  'ro',
    isa         =>  'ArrayRef',
    predicate   =>  'has_file_names',
    writer      =>  '_set_file_names',
);

before  'file_names'    =>  sub {
    my $self = shift;
    unless ( $self->has_file_names ) {
        $self->_set_file_names($self->_write_relative_coordinates_files);
    }
};

=head2 _write_relative_coordinates_files

This private subroutine is called to write the relative coordinates to file and
return an Array Ref of the paths to these files.

=cut

sub _write_relative_coordinates_files {
    my $self = shift;

    # Define a base directory
    my $file_base = "$FindBin::Bin/../static/";

    # Define a directory that will be used for the current genome and step size
    my $directory = $file_base . $self->genome_string . "_Index/";

    # If the directory exists, delete it and all of the files contained within
    if ( -d $directory ) {
        `rm -rf $directory`;
    }

    # Make a clean directory
    `mkdir -p $directory`;

    # Define an Array Ref of file strings for the relative coordinates to be
    # written to
    my $file_strings = [
		$directory . $self->genome_string . "_5Prime_UTR.bed",
		$directory . $self->genome_string . "_Exons.bed",
		$directory . $self->genome_string . "_Introns.bed",
		$directory . $self->genome_string . "_3Prime_UTR.bed",
		$directory . $self->genome_string . "_Gene_Body_0_to_10.bed",
		$directory . $self->genome_string . "_Gene_Body_10_to_20.bed",
		$directory . $self->genome_string . "_Gene_Body_20_to_30.bed",
		$directory . $self->genome_string . "_Gene_Body_30_to_40.bed",
		$directory . $self->genome_string . "_Gene_Body_40_to_50.bed",
		$directory . $self->genome_string . "_Gene_Body_50_to_60.bed",
		$directory . $self->genome_string . "_Gene_Body_60_to_70.bed",
		$directory . $self->genome_string . "_Gene_Body_70_to_80.bed",
		$directory . $self->genome_string . "_Gene_Body_80_to_90.bed",
		$directory . $self->genome_string . "_Gene_Body_90_to_100.bed",
    ];

	# Add the 1Kb iterative locations to the file strings Array Ref
	for ( my $i = 1; $i <= 10; $i++ ) {
		unshift ( @{$file_strings}, 
            $directory . $self->genome_string . "_$i" .  "_Steps_Upstream.bed"
        );
		push ( @{$file_strings}, 
            $directory . $self->genome_string . "_$i" .  "_Steps_Downstream.bed"
        );
	}

    # Print the genomic coordinates to the appropriate file string defined above
    #
    # Print the gene body, upstream, and downstream coordinates to file
    for ( my $i = 0; $i < 10; $i++ ) {

        # Print the gene body file
		open my $decile_out, ">", $file_strings->[13+$i+1] or croak
		"\n\nCould not write to " . $file_strings->[13+$i+1] . " $!\n\n";
		print $decile_out join(
            "\n",
			@{$self->relative_coordinates->{decile_coordinates}{$i+1}}
        );
        close $decile_out;

        # Print the upstream file
        open my $upstream_out, ">", $file_strings->[9-$i] or croak
        "\n\nCould not write to " . $file_strings->[9-$i] . " $!\n\n";
        print $upstream_out join("\n",
            @{$self->relative_coordinates->{Upstream}{$i}}
        );
        close $upstream_out;

        # Print the downstream file
        open my $downstream_out, ">", $file_strings->[24+$i] or croak
        "\n\nCould not write to " . $file_strings->[24+1] . " $!\n\n";
        print $downstream_out join("\n",
            @{$self->relative_coordinates->{Downstream}{$i}}
        );
        close $downstream_out;
    }

    # Define a Hash Ref that links the position in the file_strings to the
    # transcript annotation relative position name
    my $relative_transcript_hash = {
        10  =>  'five_prime_utr_coordinates',
        11  =>  'exon_coordinates',
        12  =>  'intron_coordinates',
        13  =>  'three_prime_utr_coordinates',
    };

    # Iterate through the relative_transcript_hash and write these coordinates
    # to file
    foreach my $pos ( keys %{$relative_transcript_hash} ) {
        open my $out_file, ">", $file_strings->[$pos] or croak
        "\n\nCould not write to " . $file_strings->[$pos] . " $!\n\n";
        print $out_file join("\n",
            @{$self->relative_coordinates->{$relative_transcript_hash->{$pos}}}
        );
        close $out_file;
    }

	return $file_strings;
}

#sub file_names {
#	my $self = shift;
#	# Create an Array Ref of file strings for the index files to be
#	# written to as they are fetched from UCSC
#	# Use FindBin to set the base for the file string
#	my $file_base = "$FindBin::Bin/../static/";
#	# Create the string for the directory where the index files for
#	# this genome will be stored
#	my $directory = $file_base . $self->genome . "_Index/";
#	# If the directory exists, delete is and all of the files contained within
#	if ( -d $directory ) {
#		`rm -rf $directory`;
#	}
#	# Create the directory
#	`mkdir $directory`;
#	my $file_strings = [
#		$directory . $self->genome . "_5Prime_UTR.bed",
#		$directory . $self->genome . "_Exons.bed",
#		$directory . $self->genome . "_Introns.bed",
#		$directory . $self->genome . "_3Prime_UTR.bed",
#		$directory . $self->genome . "_Gene_Body_0_to_10.bed",
#		$directory . $self->genome . "_Gene_Body_10_to_20.bed",
#		$directory . $self->genome . "_Gene_Body_20_to_30.bed",
#		$directory . $self->genome . "_Gene_Body_30_to_40.bed",
#		$directory . $self->genome . "_Gene_Body_40_to_50.bed",
#		$directory . $self->genome . "_Gene_Body_50_to_60.bed",
#		$directory . $self->genome . "_Gene_Body_60_to_70.bed",
#		$directory . $self->genome . "_Gene_Body_70_to_80.bed",
#		$directory . $self->genome . "_Gene_Body_80_to_90.bed",
#		$directory . $self->genome . "_Gene_Body_90_to_100.bed",
#	];
#	# Add the 1Kb iterative locations to the file strings Array Ref
#	for ( my $i = 1; $i <= 10; $i++ ) {
#		unshift ( @$file_strings, $directory . $self->genome . "_$i" .
#			"_Steps_Upstream.bed");
#		push ( @$file_strings, $directory . $self->genome . "_$i" .
#			"_Steps_Downstream.bed");
#	}
#	return $file_strings;
#}
#

=head2 chromosome_sizes_file

This Moose attribute holds the path to the chromosome sizes file for the current
genome.

=cut

has chromosome_sizes_file   =>  (
    is          =>  'ro',
    isa         =>  'Str',
    predicate   =>  'has_chromosome_sizes_file',
    writer      =>  '_set_chromosome_sizes_file',
);

before 'chromosome_sizes_file'  =>  sub {
    my $self = shift;
    unless ( $self->has_chromosome_sizes_file ) {
        $self->_set_chromosome_sizes_file($self->_write_chromosome_sizes);
    }
};

=head2 _write_chromosome_sizes

This subroutine writes the chromosome sizes to file.

=cut

sub _write_chromosome_sizes {
	my $self = shift;

    # Define a directory to write the chromosome sizes file.
    my $directory = "$FindBin::Bin/../static/" . $self->genome_string .
    "_Index/chromosome_sizes_file";
    
	# Make a directory to store the chromosome sizes file if it does not
	# already exist
	if (! -d $directory ) {
		`mkdir -p $directory`;
	}

	# Convert the chromosome sizes information into an Array Ref for easier
	# printing
	my $chromsome_sizes_array = [];
	foreach my $chr (keys %{$self->chromosome_sizes_hash}) {
		push(@$chromsome_sizes_array, 
            join("\t", 
                $chr,
				$self->chromosome_sizes_hash->{$chr}
            )
		);
	}

	# Write the chromosome sizes to file
	my $fh = $directory . '/' . $self->genome_string . '_chromosome_sizes_file';
    open my $chr_size_file, ">", $fh or croak "Could not write to chromosome" .
    " sizes file $fh. Please check that you have proper permissions for this " .
    "location $!\n";
	print $chr_size_file join("\n", @{$chromsome_sizes_array});
    close $chr_size_file;

	return $fh;
}

#
#
#sub empty_genomic_coordinates {
#	my $self = shift;
#	# Pre-declare a Hash Ref for the genomic coordinates
#	my $genomic_coordinates = {
#		'five_prime_utr_coordinates' 	=>	[],
#		'exon_coordinates'				=>	[],
#		'intron_coordinates'			=>	[],
#		'three_prime_utr_coordinates'	=>	[],
#		'decile_coordinates'			=>	{
#			1	=>	[],
#			2	=>	[],
#			3	=>	[],
#			4	=>	[],
#			5	=>	[],
#			6	=>	[],
#			7	=>	[],
#			8	=>	[],
#			9	=>	[],
#			10	=>	[]
#		},
#	};
#	for (my $i = 0; $i < 10; $i++) {
#		$genomic_coordinates->{'Upstream'}{$i} = [];
#		$genomic_coordinates->{'Downstream'}{$i} = [];
#	}
#	return $genomic_coordinates;
#}
#
#sub get_upstream_and_downstream_coordinates {
#	my ($self, $refseq, $chrom_sizes, $genomic_coordinates) = @_;
#	# Iterate through the iteration distances and create a file for each one
#	for ( my $i = 0; $i < 10; $i++ ) {
#		# Use the coordinates for the given accession and extend the
#		# coordinates based on the iterator extension values and within the
#		# bounds of the chromosome size. If the coordinates are valid, push
#		# them on to the end of the extended_coordinates Array Ref.
#		# Pre-declare two integers for the extended start and stop
#		my $upstream_extended_start = 0;
#		my $upstream_extended_stop = 0;
#		my $downstream_extended_start = 0;
#		my $downstream_extended_stop = 0;
#		if ( $refseq->{strand} eq '+' ) {
#			$upstream_extended_start = $refseq->{txStart} -
#			($i*1000);
#			$upstream_extended_stop = $refseq->{txStart} -
#			($i*1000) + 999;
#			$downstream_extended_start = $refseq->{txEnd} +
#			($i*1000) - 1000;
#			$downstream_extended_stop = $refseq->{txEnd} +
#			(($i*1000) - 1);
#		} elsif ( $refseq->{strand} eq '-' ) {
#			$upstream_extended_start = $refseq->{txEnd} +
#			($i*1000) - 1000;
#			$upstream_extended_stop = $refseq->{txEnd} +
#			(($i*1000) - 1);
#			$downstream_extended_start = $refseq->{txStart}
#			- ($i*1000);
#			$downstream_extended_stop = $refseq->{txStart}
#			- ($i*1000) + 999;
#		} else {
#			croak "\n\nThere was a problem getting the appropriate database information for the genome specified. 
#			Please check that the UCSC MySQL tables have not changed.\n\n";
#		}
#		# Test to ensure that the extended coordinates are valid within
#		# the constraints of the chromosome
#		if (($downstream_extended_start > 0) && 
#			($downstream_extended_start <= 
#				$chrom_sizes->{$refseq->{chrom}}) &&
#			($downstream_extended_stop > 0) && 
#			($downstream_extended_start <= 
#				$chrom_sizes->{$refseq->{chrom}})) {
#			# Add the coordinates to the Array Ref
#			push( @{$genomic_coordinates->{'Downstream'}{$i}}, 
#				join("\t", $refseq->{chrom},
#					$downstream_extended_start,
#					$downstream_extended_stop, $refseq->{name})
#			);
#		}
#		if (($upstream_extended_start > 0) && 
#			($upstream_extended_start <= 
#				$chrom_sizes->{$refseq->{chrom}}) &&
#			($upstream_extended_stop > 0) && 
#			($upstream_extended_start <= 
#				$chrom_sizes->{$refseq->{chrom}})) {
#			# Add the coordinates to the Array Ref
#			push(@{$genomic_coordinates->{'Upstream'}{$i}}, 
#				join("\t", $refseq->{chrom},
#					$upstream_extended_start, $upstream_extended_stop,
#					$refseq->{name})
#			);
#		}
#	}
#	return $genomic_coordinates;
#}

#sub get_utrs_exon_and_introns {
#	my ($self, $refseq, $genomic_coordinates) = @_;
#	# Test to make sure that the transcription start site and the coding start site
#	# are different, if they are push the coordinates onto the 5'-UTR coordinates
#	# or 3'-UTR coordinates depending on the strand
#	if ( $refseq->{txStart} != $refseq->{cdsStart} ) {
#		if ( $refseq->{strand} eq '+' ) {
#			push(@{$genomic_coordinates->{'five_prime_utr_coordinates'}},
#				join("\t", $refseq->{chrom}, $refseq->{txStart},
#					($refseq->{cdsStart} - 1), $refseq->{name})
#			);
#		} elsif ( $refseq->{strand} eq '-' ) {
#			push(@{$genomic_coordinates->{'three_prime_utr_coordinates'}},
#				join("\t", $refseq->{chrom}, $refseq->{txStart},
#					($refseq->{cdsStart} - 1), $refseq->{name})
#			);
#		}
#	}
#	# Test to make sure that the transcription termination site and the
#	# coding termination site are different, if they are push the
#	# coordinates onto the 5'-UTR coordinates or 3'-UTR coordinates
#	# depending on the strand.
#	if ( $refseq->{txEnd} != $refseq->{cdsEnd} ) {
#		if ( $refseq->{strand} eq '+' ) {
#			push(@{$genomic_coordinates->{'three_prime_utr_coordinates'}},
#				join("\t", $refseq->{chrom}, $refseq->{cdsEnd},
#					($refseq->{txEnd} - 1), $refseq->{name})
#			);
#		} elsif ( $refseq->{strand} eq '-' ) {
#			push(@{$genomic_coordinates->{'five_prime_utr_coordinates'}},
#				join("\t", $refseq->{chrom}, $refseq->{cdsEnd},
#					($refseq->{txEnd} - 1), $refseq->{name})
#			);
#		}
#	}
#	# Extract the coding exon and intron coordinates
#	my @exon_starts = split(/,/, $refseq->{exonStarts});
#	my @exon_ends = split(/,/, $refseq->{exonEnds});
#	if ( $refseq->{strand} eq '+' ) {
#		for ( my $i = 0; $i < @exon_starts; $i++ ) {
#			if ( $exon_starts[$i] && $exon_ends[$i] ) {
#				# Add the exon coordinates to the exon Array Ref
#				push(@{$genomic_coordinates->{'exon_coordinates'}},
#					join("\t", $refseq->{chrom}, $exon_starts[$i],
#						($exon_ends[$i] - 1), $refseq->{name})
#				);
#			}
#		}
#		# Calculate the introns if there are more than one exon start
#		for ( my $i = 0; $i < @exon_ends; $i++ ) {
#			# Unless this is the first exon's coordinates,
#			# calculate the intron coordinates and add them to
#			# the Introns Array Ref.
#			if ( $exon_starts[$i+1] ) {
#				push(@{$genomic_coordinates->{'intron_coordinates'}},
#					join("\t", $refseq->{chrom},
#						$exon_ends[$i], 
#						($exon_starts[$i+1] - 1),
#						$refseq->{name})
#				);
#			}
#		}
#	} elsif ( $refseq->{strand} eq '-' ) {
#		for ( my $i = @exon_starts; $i > 0; $i-- ) {
#			if ( $exon_starts[$i] && $exon_ends[$i] ) {
#				# Add the exon coordinates to the exon Array Ref
#				push(@{$genomic_coordinates->{'exon_coordinates'}},
#					join("\t", $refseq->{chrom}, $exon_starts[$i],
#						($exon_ends[$i]-1), $refseq->{name})
#				);
#			}
#		}
#		# Calculate the introns if there are more than one exon start
#		for ( my $i = (@exon_starts-1); $i > 0; $i-- ) {
#			# Unless this is the first exon's coordinates,
#			# calculate the intron coordinates and add them to
#			# the Introns Array Ref.
#			if ( $exon_ends[($i-1)] ) {
#				push(@{$genomic_coordinates->{'intron_coordinates'}},
#					join("\t", $refseq->{chrom},
#						($exon_ends[($i-1)]), 
#						($exon_starts[$i] -1),
#						$refseq->{name})
#				);
#			}
#		}
#	}
#	return $genomic_coordinates;
#}

#sub get_decile_coordinates {
#	my ($self, $refseq, $genomic_coordinates) = @_;
#	# Calculate the length of the gene body, and divide it into 10
#	# approximately equal lengths.
#	my $gene_body_length = $refseq->{txEnd} - $refseq->{txStart};
#	my $decile_length = int(($gene_body_length / 10) + 0.5);
#	if ( $refseq->{strand} eq '+' ) {
#		for ( my $decile = 1; $decile < 10; $decile++ ) {
#			my $decile_start = $refseq->{txStart} + ($decile_length *
#				($decile-1));
#			my $decile_stop = $decile_start + $decile_length - 1;
#			push (@{$genomic_coordinates->{'decile_coordinates'}{$decile}},
#				join("\t", $refseq->{chrom}, $decile_start, $decile_stop,
#					$refseq->{name})
#			);
#		}
#		my $tenth_decile_start = (($refseq->{txStart} + (9 * $decile_length)) <
#			$refseq->{txEnd} ? ($refseq->{txStart} + (9 * $decile_length)) :
#			$refseq->{txEnd});
#		push (@{$genomic_coordinates->{'decile_coordinates'}{10}}, join("\t",
#				$refseq->{chrom}, $tenth_decile_start,
#				($refseq->{txEnd}), $refseq->{name})
#		);
#	} elsif ( $refseq->{strand} eq '-' ) {
#		for ( my $decile = 1; $decile < 10; $decile++ ) {
#			my $decile_stop = $refseq->{txEnd} - ($decile_length *
#				($decile-1)) - 1;
#			my $decile_start = $decile_stop - $decile_length;
#			push (@{$genomic_coordinates->{'decile_coordinates'}{$decile}},
#				join("\t", $refseq->{chrom}, $decile_start, $decile_stop,
#					$refseq->{name})
#			);
#		}
#		my $tenth_decile_end = (($refseq->{txEnd} - (9 * $decile_length)
#			- 1) >
#			$refseq->{txStart} ? ($refseq->{txEnd} - (9 * $decile_length) -
#			1) :
#			$refseq->{txStart});
#		push (@{$genomic_coordinates->{'decile_coordinates'}{10}}, join("\t",
#				$refseq->{chrom}, $refseq->{txStart},
#				$tenth_decile_end, $refseq->{name})
#		);
#	} else {
#		croak "There was a problem fetching the strand for $refseq->{name}
#		from UCSC.";
#	}
#	return $genomic_coordinates;
#}

#sub print_genomic_coordinates {
#	my ($self, $file_strings, $genomic_coordinates) = @_;
#	# Print the upstream and downstream coordinates to file
#	for (my $i = 0; $i < 10; $i++) {
#		open my $upstream_out, ">", $file_strings->[9-$i] or 
#		croak "Could not write to $file_strings->[9-$i] $! \n";
#		print $upstream_out join("\n",
#			@{$genomic_coordinates->{Upstream}{$i}});
#		open my $downstream_out, ">", $file_strings->[24+$i] or 
#		croak "Could not write to $file_strings->[24+$i] $! \n";
#		print $downstream_out join("\n",
#			@{$genomic_coordinates->{Downstream}{$i}});
#	}
#	# Print the 5'-UTR, 3'-UTR, exons, and introns coordinates to file
#	open my $five_prime_utr_out, ">", $file_strings->[10] or 
#	croak "Could not write to $file_strings->[10] $! \n";
#	print $five_prime_utr_out join("\n",
#		@{$genomic_coordinates->{five_prime_utr_coordinates}});
#	open my $three_prime_utr_out, ">", $file_strings->[13] or 
#	croak "Could not write to $file_strings->[13] $! \n";
#	print $three_prime_utr_out join("\n",
#		@{$genomic_coordinates->{three_prime_utr_coordinates}});
#	open my $exons_out, ">", $file_strings->[11] or 
#	croak "Could not write to $file_strings->[11] $! \n";
#	print $exons_out join("\n",
#		@{$genomic_coordinates->{exon_coordinates}});
#	open my $introns_out, ">", $file_strings->[12] or 
#	croak "Could not write to $file_strings->[12] $! \n";
#	print $introns_out join("\n",
#		@{$genomic_coordinates->{intron_coordinates}});
#	# Print the decile coordinates to file
#	for (my $i = 1; $i <= 10; $i++) {
#		open my $decile_out, ">", $file_strings->[13+$i] or
#		croak "Could not write to $file_strings->[13+$i] $! \n";
#		print $decile_out join("\n",
#			@{$genomic_coordinates->{decile_coordinates}{$i}});
#	}
#}

1; 
