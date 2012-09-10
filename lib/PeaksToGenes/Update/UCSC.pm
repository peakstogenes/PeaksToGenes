package PeaksToGenes::Update::UCSC 0.001;
use Moose;
use Carp;
use FindBin;
use PeaksToGenes::UCSC;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Update::UCSC

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is called by the PeaksToGenes::Update module to
interact with the UCSC Genome MySQL Browser to download the
required minimal base files for the index.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::Update::UCSC class.

=cut

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has genome_info	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[HashRef[Str]]',
	required	=>	1,
	default		=>	sub {
		my $self = shift;
		my $genome_info = {
			hg19	=>	{
				organism	=>	"Human",
				clade		=>	"mammal",
			},
			hg18	=>	{
				organism	=>	"Human",
				clade		=>	"mammal",
			},
			hg17	=>	{
				organism	=>	"Human",
				clade		=>	"mammal",
			},
			hg16	=>	{
				organism	=>	"Human",
				clade		=>	"mammal",
			},
			panTro3	=>	{
				organism	=>	"Chimp",
				clade		=>	"mammal",
			},
			panTro2	=>	{
				organism	=>	"Chimp",
				clade		=>	"mammal",
			},
			panTro1	=>	{
				organism	=>	"Chimp",
				clade		=>	"mammal",
			},
			ponAbe2	=>	{
				organism	=>	"Orangutan",
				clade		=>	"mammal",
			},
			rheMac2	=>	{
				organism	=>	"Rhesus",
				clade		=>	"mammal",
			},
			calJac3	=>	{
				organism	=>	"Marmoset",
				clade		=>	"mammal",
			},
			calJac1	=>	{
				organism	=>	"Marmoset",
				clade		=>	"mammal",
			},
			mm10	=>	{
				organism	=>	"Mouse",
				clade		=>	"mammal",
			},
			mm9	=>	{
				organism	=>	"Mouse",
				clade		=>	"mammal",
			},
			mm8	=>	{
				organism	=>	"Mouse",
				clade		=>	"mammal",
			},
			mm7	=>	{
				organism	=>	"Mouse",
				clade		=>	"mammal",
			},
			rn5	=>	{
				organism	=>	"Rat",
				clade		=>	"mammal",
			},
			rn4	=>	{
				organism	=>	"Rat",
				clade		=>	"mammal",
			},
			rn3	=>	{
				organism	=>	"Rat",
				clade		=>	"mammal",
			},
			cavPor3	=>	{
				organism	=>	"Guinea pig",
				clade		=>	"mammal",
			},
			oryCun2	=>	{
				organism	=>	"Rabbit",
				clade		=>	"mammal",
			},
			oviAri1	=>	{
				organism	=>	"Sheep",
				clade		=>	"mammal",
			},
			bosTau7	=>	{
				organism	=>	"Cow",
				clade		=>	"mammal",
			},
			bosTau6	=>	{
				organism	=>	"Cow",
				clade		=>	"mammal",
			},
			bosTau4	=>	{
				organism	=>	"Cow",
				clade		=>	"mammal",
			},
			bosTau3	=>	{
				organism	=>	"Cow",
				clade		=>	"mammal",
			},
			bosTau2	=>	{
				organism	=>	"Cow",
				clade		=>	"mammal",
			},
			equCab2	=>	{
				organism	=>	"Horse",
				clade		=>	"mammal",
			},
			equCab1	=>	{
				organism	=>	"Horse",
				clade		=>	"mammal",
			},
			felCat4	=>	{
				organism	=>	"Cat",
				clade		=>	"mammal",
			},
			felCat3	=>	{
				organism	=>	"Cat",
				clade		=>	"mammal",
			},
			canFam3	=>	{
				organism	=>	"Dog",
				clade		=>	"mammal",
			},
			canFam2	=>	{
				organism	=>	"Dog",
				clade		=>	"mammal",
			},
			canFam1	=>	{
				organism	=>	"Dog",
				clade		=>	"mammal",
			},
			monDom5	=>	{
				organism	=>	"Opossum",
				clade		=>	"mammal",
			},
			monDom4	=>	{
				organism	=>	"Opossum",
				clade		=>	"mammal",
			},
			monDom1	=>	{
				organism	=>	"Opossum",
				clade		=>	"mammal",
			},
			ornAna1	=>	{
				organism	=>	"Platypus",
				clade		=>	"mammal",
			},
			galGal4	=>	{
				organism	=>	"Chicken",
				clade		=>	"vertebrate",
			},
			galGal3	=>	{
				organism	=>	"Chicken",
				clade		=>	"vertebrate",
			},
			galGal2	=>	{
				organism	=>	"Chicken",
				clade		=>	"vertebrate",
			},
			taeGut1	=>	{
				organism	=>	"Zebra finch",
				clade		=>	"vertebrate",
			},
			xenTro3	=>	{
				organism	=>	"X. tropicalis",
				clade		=>	"vertebrate",
			},
			xenTro2	=>	{
				organism	=>	"X. tropicalis",
				clade		=>	"vertebrate",
			},
			xenTro1	=>	{
				organism	=>	"X. tropicalis",
				clade		=>	"vertebrate",
			},
			danRer7	=>	{
				organism	=>	"Zebrafish",
				clade		=>	"vertebrate",
			},
			danRer6	=>	{
				organism	=>	"Zebrafish",
				clade		=>	"vertebrate",
			},
			danRer5	=>	{
				organism	=>	"Zebrafish",
				clade		=>	"vertebrate",
			},
			danRer4	=>	{
				organism	=>	"Zebrafish",
				clade		=>	"vertebrate",
			},
			danRer3	=>	{
				organism	=>	"Zebrafish",
				clade		=>	"vertebrate",
			},
			fr3	=>	{
				organism	=>	"Fugu",
				clade		=>	"vertebrate",
			},
			fr2	=>	{
				organism	=>	"Fugu",
				clade		=>	"vertebrate",
			},
			fr1	=>	{
				organism	=>	"Fugu",
				clade		=>	"vertebrate",
			},
			gasAcu1	=>	{
				organism	=>	"Stickleback",
				clade		=>	"vertebrate",
			},
			oryLat2	=>	{
				organism	=>	"Medaka",
				clade		=>	"vertebrate",
			},
			dm3	=>	{
				organism	=>	"D. melanogaster",
				clade		=>	"insect",
			},
			dm2	=>	{
				organism	=>	"D. melanogaster",
				clade		=>	"insect",
			},
			dm1	=>	{
				organism	=>	"D. melanogaster",
				clade		=>	"insect",
			},
			ce10	=>	{
				organism	=>	"C. elegans",
				clade		=>	"worm",
			},
			ce6	=>	{
				organism	=>	"C. elegans",
				clade		=>	"worm",
			},
			ce4	=>	{
				organism	=>	"C. elegans",
				clade		=>	"worm",
			},
			ce2	=>	{
				organism	=>	"C. elegans",
				clade		=>	"worm",
			},
			ce10	=>	{
				organism	=>	"C. elegans",
				clade		=>	"worm",
			},
		};
		return $genome_info;
	},
);

has chromosome_sizes	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[Int]',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub	{
		my $self = shift;
		# Connect to the UCSC MySQL Browser
		my $schema = PeaksToGenes::UCSC->connect('dbi:mysql:host=genome-mysql.cse.ucsc.edu;database=' . $self->genome, "genome");
		# Get the chromosome sizes file from UCSC
		my $raw_chrom_sizes = $schema->storage->dbh_do(
			sub {
				my ($storage, $dbh, @args) = @_;
				$dbh->selectall_hashref("SELECT chrom, size FROM chromInfo", ["chrom"]);
			},
		);
		# Pre-declare a Hash Ref to hold the final information for the chromosome sizes
		my $chrom_sizes = {};
		# Parse the chromosome sizes file into an easier to use form
		foreach my $chromosome (keys %$raw_chrom_sizes) {
			$chrom_sizes->{$chromosome} = $raw_chrom_sizes->{$chromosome}{size};
		}
		return $chrom_sizes;
	},
);

=head1 SUBROUTINES/METHODS

=head2 fetch_tables

This subroutine is called by the PeaksToGenes::Update module to
interact with the UCSC Genome MySQL browser to download the minimal
index files in BED format. If this module is unable to download the
required files, it will return an error to the PeaksToGenes::Update
module, otherwise it will return an Array Ref of file names.

=cut

sub fetch_tables {
	my $self = shift;
	# Create an Array Ref of file strings for the index files to be
	# written to as they are fetched from UCSC
	# Use FindBin to set the base for the file string
	my $file_base = "$FindBin::Bin/../static/";
	# Create the string for the directory where the index files for
	# this genome will be stored
	my $directory = $file_base . $self->genome . "_Index/";
	# If the directory exists, delete is and all of the files contained within
	if ( -d $directory ) {
		`rm -rf $directory`;
	}
	# Create the directory
	`mkdir $directory`;
	my $file_strings = [
		$directory . $self->genome . "_5Prime_UTR.bed",
		$directory . $self->genome . "_Exons.bed",
		$directory . $self->genome . "_Introns.bed",
		$directory . $self->genome . "_3Prime_UTR.bed",
	];
	# Add the 1Kb iterative locations to the file strings Array Ref
	for ( my $i = 1; $i <= 100; $i++ ) {
		unshift ( @$file_strings, $directory . $self->genome . "_$i" . "Kb_Upstream.bed");
		push ( @$file_strings, $directory . $self->genome . "_$i" . "Kb_Downstream.bed");
	}
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
	my $schema = PeaksToGenes::UCSC->connect('dbi:mysql:host=genome-mysql.cse.ucsc.edu;database=' . $self->genome, "genome");
	# Extract all of the RefSeq gene coordinates
	my $refseq = $schema->storage->dbh_do(
		sub {
			my ($storage, $dbh, @args) = @_;
			$dbh->selectall_hashref("SELECT $col_string FROM refGene", ["name"]);
		},
	);
	# Get the chromosome sizes file from UCSC
	my $chrom_sizes = $self->chromosome_sizes;
	# Iterate through the iteration distances and create a file for each one
	for ( my $i = 0; $i < 100; $i++ ) {
		# Pre-declare an Array ref to store the extended coordinates for both
		# upstream and downstream extensions
		my $upstream_extended_coordinates = [];
		my $downstream_extended_coordinates = [];
		# Iterate through the Hash Ref of accessions and extend the coordinates
		# based on the iterator extension values and within the bounds of the 
		# chromosome size. If the coordinates are valid, push them on to the
		# end of the extended_coordinates Array Ref
		foreach my $accession ( keys %$refseq ) {
			# Pre-declare two integers for the extended start and stop
			my $upstream_extended_start = 0;
			my $upstream_extended_stop = 0;
			my $downstream_extended_start = 0;
			my $downstream_extended_stop = 0;
			if ( $refseq->{$accession}{strand} eq '+' ) {
				$upstream_extended_start = $refseq->{$accession}{txStart} - ($i*1000);
				$upstream_extended_stop = $refseq->{$accession}{txStart} - ($i*1000) + 1000;
				$downstream_extended_start = $refseq->{$accession}{txEnd} + ($i*1000) - 1000;
				$downstream_extended_stop = $refseq->{$accession}{txEnd} + ($i*1000);
			} elsif ( $refseq->{$accession}{strand} eq '-' ) {
				$upstream_extended_start = $refseq->{$accession}{txEnd} + ($i*1000) - 1000;
				$upstream_extended_stop = $refseq->{$accession}{txEnd} + ($i*1000);
				$downstream_extended_start = $refseq->{$accession}{txStart} - ($i*1000);
				$downstream_extended_stop = $refseq->{$accession}{txStart} - ($i*1000) + 1000;
			} else {
				croak "\n\nThere was a problem getting the appropriate database information for the genome specified. Please check that the UCSC MySQL tables have not changed.\n\n";
			}
			# Test to ensure that the extended coordinates are valid within the constraints of
			# the chromosome
			if (($downstream_extended_start > 0) && ($downstream_extended_start <= $chrom_sizes->{$refseq->{$accession}{chrom}}) &&
				($downstream_extended_stop > 0) && ($downstream_extended_start <= $chrom_sizes->{$refseq->{$accession}{chrom}})) {
				# Add the coordinates to the Array Ref
				push(@$downstream_extended_coordinates, join("\t", $refseq->{$accession}{chrom}, $downstream_extended_start, $downstream_extended_stop, $accession));
			}
			if (($upstream_extended_start > 0) && ($upstream_extended_start <= $chrom_sizes->{$refseq->{$accession}{chrom}}) &&
				($upstream_extended_stop > 0) && ($upstream_extended_start <= $chrom_sizes->{$refseq->{$accession}{chrom}})) {
				# Add the coordinates to the Array Ref
				push(@$upstream_extended_coordinates, join("\t", $refseq->{$accession}{chrom}, $upstream_extended_start, $upstream_extended_stop, $accession));
			}
		}
		# Print the upstream coordinates to file
		open my $upstream_out_fh, ">", $file_strings->[99-$i], or die "Could not write to file: " . $file_strings->[99-$i] . " $!\n";
		print $upstream_out_fh join("\n", @$upstream_extended_coordinates);
		# Print the upstream coordinates to file
		open my $downstream_out_fh, ">", $file_strings->[104 + $i], or die "Could not write to file: " . $file_strings->[104 + $i] . " $!\n";
		print $downstream_out_fh join("\n", @$downstream_extended_coordinates);
	}
	# Loop through the accessions in the RefSeq HashRef, and calculate the 5'-UTR coordinates,
	# Exons, Introns, and 3'-UTR coordinates. Then write them to file.
	# Pre-declare an Array Ref for each type of coordinates
	my $five_prime_utrs = [];
	my $exons = [];
	my $introns = [];
	my $three_prime_utrs = [];
	foreach my $accession (keys %$refseq) {
		# Test to make sure that the transcription start site and the coding start site
		# are different, if they are push the coordinates onto the 5'-UTR coordinates
		# or 3'-UTR coordinates depending on the strand
		if ( $refseq->{$accession}{txStart} != $refseq->{$accession}{cdsStart} ) {
			if ( $refseq->{$accession}{strand} eq '+' ) {
				push(@$five_prime_utrs, join("\t", $refseq->{$accession}{chrom}, $refseq->{$accession}{txStart}, $refseq->{$accession}{cdsStart}, $accession));
			} elsif ( $refseq->{$accession}{strand} eq '-' ) {
				push(@$three_prime_utrs, join("\t", $refseq->{$accession}{chrom}, $refseq->{$accession}{txStart}, $refseq->{$accession}{cdsStart}, $accession));
			}
		}
		# Test to make sure that the transcription termination site and the coding 
		# termination site are different, if they are push the coordinates onto 
		# the 5'-UTR coordinates or 3'-UTR coordinates depending on the strand
		if ( $refseq->{$accession}{txEnd } != $refseq->{$accession}{cdsEnd} ) {
			if ( $refseq->{$accession}{strand} eq '+' ) {
				push(@$three_prime_utrs, join("\t", $refseq->{$accession}{chrom}, $refseq->{$accession}{cdsEnd}, $refseq->{$accession}{txEnd}, $accession));
			} elsif ( $refseq->{$accession}{strand} eq '-' ) {
				push(@$five_prime_utrs, join("\t", $refseq->{$accession}{chrom}, $refseq->{$accession}{cdsEnd}, $refseq->{$accession}{txEnd}, $accession));
			}
		}
		# Extract the coding exon and intron coordinates
		my @exon_starts = split(/,/, $refseq->{$accession}{exonStarts});
		my @exon_ends = split(/,/, $refseq->{$accession}{exonEnds});
		if ( $refseq->{$accession}{strand} eq '+' ) {
			for ( my $i = 0; $i < @exon_starts; $i++ ) {
				if ( $exon_starts[$i] && $exon_ends[$i] ) {
					# Add the exon coordinates to the exon Array Ref
					push(@$exons, join("\t", $refseq->{$accession}{chrom}, $exon_starts[$i], $exon_ends[$i], $accession));
				}
			}
			# Calculate the introns if there are more than one exon start
			if ( @exon_starts > 1 ) {
				for ( my $i = 1; $i < @exon_starts; $i++ ) {
					if ( $exon_starts[$i] && $exon_ends[$i] ) {
						# Unless this is the first exon's coordinates, calculate the intron
						# coordinates and add them to the Introns Array Ref
						if ( $exon_ends[($i-1)] ) {
							push(@$introns, join("\t", $refseq->{$accession}{chrom}, $exon_ends[($i-1)], $exon_starts[$i], $accession));
						}
					}
				}
			}
		} elsif ( $refseq->{$accession}{strand} eq '-' ) {
			for ( my $i = @exon_starts; $i > 0; $i-- ) {
				if ( $exon_starts[$i] && $exon_ends[$i] ) {
					# Add the exon coordinates to the exon Array Ref
					push(@$exons, join("\t", $refseq->{$accession}{chrom}, $exon_starts[$i], $exon_ends[$i], $accession));
				}
			}
			# Calculate the introns if there are more than one exon start
			if ( @exon_starts > 1 ) {
				for ( my $i = @exon_starts; $i > 1; $i-- ) {
					if ( $exon_starts[$i] && $exon_ends[$i] ) {
						# Unless this is the first exon's coordinates, calculate the intron
						# coordinates and add them to the Introns Array Ref
						if ( $exon_ends[($i-1)] ) {
							push(@$introns, join("\t", $refseq->{$accession}{chrom}, $exon_ends[($i-1)], $exon_starts[$i], $accession));
						}
					}
				}
			}
		}
	}
	# Print the coordinates to file
	open my $five_prime_fh, ">", $file_strings->[100], or die "Could not write to file: " . $file_strings->[100] . " $!\n";
	print $five_prime_fh join("\n", @$five_prime_utrs);
	open my $exons_fh, ">", $file_strings->[101], or die "Could not write to file: " . $file_strings->[101] . " $!\n";
	print $exons_fh join("\n", @$exons);
	open my $introns_fh, ">", $file_strings->[102], or die "Could not write to file: " . $file_strings->[102] . " $!\n";
	print $introns_fh join("\n", @$introns);
	open my $three_prime_fh, ">", $file_strings->[103], or die "Could not write to file: " . $file_strings->[103] . " $!\n";
	print $three_prime_fh join("\n", @$three_prime_utrs);
	return $file_strings;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Update::UCSC


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PeaksToGenes>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PeaksToGenes>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PeaksToGenes>

=item * Search CPAN

L<http://search.cpan.org/dist/PeaksToGenes/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jason R. Dobson.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


1; # End of PeaksToGenes::Update::UCSC
