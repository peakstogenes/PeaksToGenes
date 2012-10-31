package PeaksToGenes::Update::UCSC 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
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

	# Check to make sure that the genome defined by the user is a valid
	# RefSeq genome
	unless ( $self->genome_info->{$self->genome} ) {
		croak "\n\nThe genome you have entered: " .
		$self->genome . " is not a valid RefSeq genome. Please check to make sure you have entered it correctly.\n\n";
	}

	# Use the file_names subroutine to create a folder in the static
	# directory for the genome to be updated. This will also delete any
	# existing folder. The file names are returned in the form of an Array
	# Ref
	my $file_strings = $self->file_names;

	# Write the chromosome sizes to file 
	my $chromosome_sizes_fh = $self->write_chromosome_sizes;

	# Use the get_gene_body_coordinates subroutine to interact with the
	# UCSC MySQL server and return the gene coordinates in the form of a
	# Hash Ref
	my $refseq = $self->get_gene_body_coordinates;

	# Get the chromosome sizes file from UCSC
	my $chrom_sizes = $self->chromosome_sizes;

	# Make a call to the empty_genomic_coordinates subroutine to create a
	# structure to store the genomic coordinates in
	my $genomic_coordinates = $self->empty_genomic_coordinates;

	# Iterate through the accessions returned from UCSC and calculate the
	# coordinates needed for the upstream, downstream, UTRs, exons,
	# introns, and gene body positions.
	foreach my $accession (keys %$refseq) {
		# Make a call to the get_upstream_and_downstream_coordinates
		# subroutine to add to the genomic_coordinates Hash Ref of Array
		# Refs of coordinates.
		$genomic_coordinates =
		$self->get_upstream_and_downstream_coordinates($refseq->{$accession},$chrom_sizes,
			$genomic_coordinates);

		# Make a call to the get_utrs_exon_and_introns subroutine to add
		# the coordinates to the genomic_coordinates Hash Ref of Array Refs
		# of coordinates
		$genomic_coordinates =
		$self->get_utrs_exon_and_introns($refseq->{$accession},
			$genomic_coordinates);

		# Make a call to the get_gene_body_coordinates subroutine to add
		# the coordinates to the genomic_coordinates Hash Ref of Array Refs
		# of coordinates
		$genomic_coordinates =
		$self->get_decile_coordinates($refseq->{$accession},
			$genomic_coordinates);
	}
	# Make a call to the print_genomic_coordinates subroutine to print the
	# coordinates to BED-format files in the static directory
	$self->print_genomic_coordinates($file_strings, $genomic_coordinates);
	return ($file_strings, $chromosome_sizes_fh);
}

sub file_names {
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
		$directory . $self->genome . "_Gene_Body_0_to_10.bed",
		$directory . $self->genome . "_Gene_Body_10_to_20.bed",
		$directory . $self->genome . "_Gene_Body_20_to_30.bed",
		$directory . $self->genome . "_Gene_Body_30_to_40.bed",
		$directory . $self->genome . "_Gene_Body_40_to_50.bed",
		$directory . $self->genome . "_Gene_Body_50_to_60.bed",
		$directory . $self->genome . "_Gene_Body_60_to_70.bed",
		$directory . $self->genome . "_Gene_Body_70_to_80.bed",
		$directory . $self->genome . "_Gene_Body_80_to_90.bed",
		$directory . $self->genome . "_Gene_Body_90_to_100.bed",
	];
	# Add the 1Kb iterative locations to the file strings Array Ref
	for ( my $i = 1; $i <= 100; $i++ ) {
		unshift ( @$file_strings, $directory . $self->genome . "_$i" .
			"Kb_Upstream.bed");
		push ( @$file_strings, $directory . $self->genome . "_$i" .
			"Kb_Downstream.bed");
	}
	return $file_strings;
}

sub write_chromosome_sizes {
	my $self = shift;

	my $directory = "$FindBin::Bin/../static/" . $self->genome .
	"_Index/chromosome_sizes_file";
	# Make a directory to store the chromosome sizes file if it does not
	# already exist
	if (! -d $directory ) {
		`mkdir -p $directory`;
	}

	# Convert the chromosome sizes information into an Array Ref for easier
	# printing
	my $chromsome_sizes_array = [];
	foreach my $chr (keys %{$self->chromosome_sizes}) {
		push(@$chromsome_sizes_array, join("\t", $chr,
				$self->chromosome_sizes->{$chr})
		);
	}

	# Write the chromosome sizes to file
	my $fh = $directory . '/' . $self->genome . '_chromosome_sizes_file';
	open my $chr_size_file, ">", $fh or croak "Could not write to chromosome sizes file $fh. Please check that you have proper permissions for this location $!\n";
	print $chr_size_file join("\n", @$chromsome_sizes_array);

	return $fh;
}

sub get_gene_body_coordinates {
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
		. $self->genome, "genome");
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

sub empty_genomic_coordinates {
	my $self = shift;
	# Pre-declare a Hash Ref for the genomic coordinates
	my $genomic_coordinates = {
		'five_prime_utr_coordinates' 	=>	[],
		'exon_coordinates'				=>	[],
		'intron_coordinates'			=>	[],
		'three_prime_utr_coordinates'	=>	[],
		'decile_coordinates'			=>	{
			1	=>	[],
			2	=>	[],
			3	=>	[],
			4	=>	[],
			5	=>	[],
			6	=>	[],
			7	=>	[],
			8	=>	[],
			9	=>	[],
			10	=>	[]
		},
	};
	for (my $i = 0; $i < 100; $i++) {
		$genomic_coordinates->{'Upstream'}{$i} = [];
		$genomic_coordinates->{'Downstream'}{$i} = [];
	}
	return $genomic_coordinates;
}

sub get_upstream_and_downstream_coordinates {
	my ($self, $refseq, $chrom_sizes, $genomic_coordinates) = @_;
	# Iterate through the iteration distances and create a file for each one
	for ( my $i = 0; $i < 100; $i++ ) {
		# Use the coordinates for the given accession and extend the
		# coordinates based on the iterator extension values and within the
		# bounds of the chromosome size. If the coordinates are valid, push
		# them on to the end of the extended_coordinates Array Ref.
		# Pre-declare two integers for the extended start and stop
		my $upstream_extended_start = 0;
		my $upstream_extended_stop = 0;
		my $downstream_extended_start = 0;
		my $downstream_extended_stop = 0;
		if ( $refseq->{strand} eq '+' ) {
			$upstream_extended_start = $refseq->{txStart} -
			($i*1000);
			$upstream_extended_stop = $refseq->{txStart} -
			($i*1000) + 999;
			$downstream_extended_start = $refseq->{txEnd} +
			($i*1000) - 1000;
			$downstream_extended_stop = $refseq->{txEnd} +
			(($i*1000) - 1);
		} elsif ( $refseq->{strand} eq '-' ) {
			$upstream_extended_start = $refseq->{txEnd} +
			($i*1000) - 1000;
			$upstream_extended_stop = $refseq->{txEnd} +
			(($i*1000) - 1);
			$downstream_extended_start = $refseq->{txStart}
			- ($i*1000);
			$downstream_extended_stop = $refseq->{txStart}
			- ($i*1000) + 999;
		} else {
			croak "\n\nThere was a problem getting the appropriate database information for the genome specified. 
			Please check that the UCSC MySQL tables have not changed.\n\n";
		}
		# Test to ensure that the extended coordinates are valid within
		# the constraints of the chromosome
		if (($downstream_extended_start > 0) && 
			($downstream_extended_start <= 
				$chrom_sizes->{$refseq->{chrom}}) &&
			($downstream_extended_stop > 0) && 
			($downstream_extended_start <= 
				$chrom_sizes->{$refseq->{chrom}})) {
			# Add the coordinates to the Array Ref
			push( @{$genomic_coordinates->{'Downstream'}{$i}}, 
				join("\t", $refseq->{chrom},
					$downstream_extended_start,
					$downstream_extended_stop, $refseq->{name})
			);
		}
		if (($upstream_extended_start > 0) && 
			($upstream_extended_start <= 
				$chrom_sizes->{$refseq->{chrom}}) &&
			($upstream_extended_stop > 0) && 
			($upstream_extended_start <= 
				$chrom_sizes->{$refseq->{chrom}})) {
			# Add the coordinates to the Array Ref
			push(@{$genomic_coordinates->{'Upstream'}{$i}}, 
				join("\t", $refseq->{chrom},
					$upstream_extended_start, $upstream_extended_stop,
					$refseq->{name})
			);
		}
	}
	return $genomic_coordinates;
}

sub get_utrs_exon_and_introns {
	my ($self, $refseq, $genomic_coordinates) = @_;
	# Test to make sure that the transcription start site and the coding start site
	# are different, if they are push the coordinates onto the 5'-UTR coordinates
	# or 3'-UTR coordinates depending on the strand
	if ( $refseq->{txStart} != $refseq->{cdsStart} ) {
		if ( $refseq->{strand} eq '+' ) {
			push(@{$genomic_coordinates->{'five_prime_utr_coordinates'}},
				join("\t", $refseq->{chrom}, $refseq->{txStart},
					($refseq->{cdsStart} - 1), $refseq->{name})
			);
		} elsif ( $refseq->{strand} eq '-' ) {
			push(@{$genomic_coordinates->{'three_prime_utr_coordinates'}},
				join("\t", $refseq->{chrom}, $refseq->{txStart},
					($refseq->{cdsStart} - 1), $refseq->{name})
			);
		}
	}
	# Test to make sure that the transcription termination site and the
	# coding termination site are different, if they are push the
	# coordinates onto the 5'-UTR coordinates or 3'-UTR coordinates
	# depending on the strand.
	if ( $refseq->{txEnd} != $refseq->{cdsEnd} ) {
		if ( $refseq->{strand} eq '+' ) {
			push(@{$genomic_coordinates->{'three_prime_utr_coordinates'}},
				join("\t", $refseq->{chrom}, $refseq->{cdsEnd},
					($refseq->{txEnd} - 1), $refseq->{name})
			);
		} elsif ( $refseq->{strand} eq '-' ) {
			push(@{$genomic_coordinates->{'five_prime_utr_coordinates'}},
				join("\t", $refseq->{chrom}, $refseq->{cdsEnd},
					($refseq->{txEnd} - 1), $refseq->{name})
			);
		}
	}
	# Extract the coding exon and intron coordinates
	my @exon_starts = split(/,/, $refseq->{exonStarts});
	my @exon_ends = split(/,/, $refseq->{exonEnds});
	if ( $refseq->{strand} eq '+' ) {
		for ( my $i = 0; $i < @exon_starts; $i++ ) {
			if ( $exon_starts[$i] && $exon_ends[$i] ) {
				# Add the exon coordinates to the exon Array Ref
				push(@{$genomic_coordinates->{'exon_coordinates'}},
					join("\t", $refseq->{chrom}, $exon_starts[$i],
						($exon_ends[$i] - 1), $refseq->{name})
				);
			}
		}
		# Calculate the introns if there are more than one exon start
		for ( my $i = 0; $i < @exon_ends; $i++ ) {
			# Unless this is the first exon's coordinates,
			# calculate the intron coordinates and add them to
			# the Introns Array Ref.
			if ( $exon_starts[$i+1] ) {
				push(@{$genomic_coordinates->{'intron_coordinates'}},
					join("\t", $refseq->{chrom},
						$exon_ends[$i], 
						($exon_starts[$i+1] - 1),
						$refseq->{name})
				);
			}
		}
	} elsif ( $refseq->{strand} eq '-' ) {
		for ( my $i = @exon_starts; $i > 0; $i-- ) {
			if ( $exon_starts[$i] && $exon_ends[$i] ) {
				# Add the exon coordinates to the exon Array Ref
				push(@{$genomic_coordinates->{'exon_coordinates'}},
					join("\t", $refseq->{chrom}, $exon_starts[$i],
						($exon_ends[$i]-1), $refseq->{name})
				);
			}
		}
		# Calculate the introns if there are more than one exon start
		for ( my $i = (@exon_starts-1); $i > 0; $i-- ) {
			# Unless this is the first exon's coordinates,
			# calculate the intron coordinates and add them to
			# the Introns Array Ref.
			if ( $exon_ends[($i-1)] ) {
				push(@{$genomic_coordinates->{'intron_coordinates'}},
					join("\t", $refseq->{chrom},
						($exon_ends[($i-1)]), 
						($exon_starts[$i] -1),
						$refseq->{name})
				);
			}
		}
	}
	return $genomic_coordinates;
}

sub get_decile_coordinates {
	my ($self, $refseq, $genomic_coordinates) = @_;
	# Calculate the length of the gene body, and divide it into 10
	# approximately equal lengths.
	my $gene_body_length = $refseq->{txEnd} - $refseq->{txStart};
	my $decile_length = int(($gene_body_length / 10) + 0.5);
	if ( $refseq->{strand} eq '+' ) {
		for ( my $decile = 1; $decile < 10; $decile++ ) {
			my $decile_start = $refseq->{txStart} + ($decile_length *
				($decile-1));
			my $decile_stop = $decile_start + $decile_length - 1;
			push (@{$genomic_coordinates->{'decile_coordinates'}{$decile}},
				join("\t", $refseq->{chrom}, $decile_start, $decile_stop,
					$refseq->{name})
			);
		}
		my $tenth_decile_start = (($refseq->{txStart} + (9 * $decile_length)) <
			$refseq->{txEnd} ? ($refseq->{txStart} + (9 * $decile_length)) :
			$refseq->{txEnd});
		push (@{$genomic_coordinates->{'decile_coordinates'}{10}}, join("\t",
				$refseq->{chrom}, $tenth_decile_start,
				($refseq->{txEnd}), $refseq->{name})
		);
	} elsif ( $refseq->{strand} eq '-' ) {
		for ( my $decile = 1; $decile < 10; $decile++ ) {
			my $decile_stop = $refseq->{txEnd} - ($decile_length *
				($decile-1)) - 1;
			my $decile_start = $decile_stop - $decile_length;
			push (@{$genomic_coordinates->{'decile_coordinates'}{$decile}},
				join("\t", $refseq->{chrom}, $decile_start, $decile_stop,
					$refseq->{name})
			);
		}
		my $tenth_decile_end = (($refseq->{txEnd} - (9 * $decile_length)
			- 1) >
			$refseq->{txStart} ? ($refseq->{txEnd} - (9 * $decile_length) -
			1) :
			$refseq->{txStart});
		push (@{$genomic_coordinates->{'decile_coordinates'}{10}}, join("\t",
				$refseq->{chrom}, $refseq->{txStart},
				$tenth_decile_end, $refseq->{name})
		);
	} else {
		croak "There was a problem fetching the strand for $refseq->{name}
		from UCSC.";
	}
	return $genomic_coordinates;
}

sub print_genomic_coordinates {
	my ($self, $file_strings, $genomic_coordinates) = @_;
	# Print the upstream and downstream coordinates to file
	for (my $i = 0; $i < 100; $i++) {
		open my $upstream_out, ">", $file_strings->[99-$i] or 
		croak "Could not write to $file_strings->[99-$i] $! \n";
		print $upstream_out join("\n",
			@{$genomic_coordinates->{Upstream}{$i}});
		open my $downstream_out, ">", $file_strings->[114+$i] or 
		croak "Could not write to $file_strings->[114+$i] $! \n";
		print $downstream_out join("\n",
			@{$genomic_coordinates->{Downstream}{$i}});
	}
	# Print the 5'-UTR, 3'-UTR, exons, and introns coordinates to file
	open my $five_prime_utr_out, ">", $file_strings->[100] or 
	croak "Could not write to $file_strings->[100] $! \n";
	print $five_prime_utr_out join("\n",
		@{$genomic_coordinates->{five_prime_utr_coordinates}});
	open my $three_prime_utr_out, ">", $file_strings->[103] or 
	croak "Could not write to $file_strings->[103] $! \n";
	print $three_prime_utr_out join("\n",
		@{$genomic_coordinates->{three_prime_utr_coordinates}});
	open my $exons_out, ">", $file_strings->[101] or 
	croak "Could not write to $file_strings->[101] $! \n";
	print $exons_out join("\n",
		@{$genomic_coordinates->{exon_coordinates}});
	open my $introns_out, ">", $file_strings->[102] or 
	croak "Could not write to $file_strings->[102] $! \n";
	print $introns_out join("\n",
		@{$genomic_coordinates->{intron_coordinates}});
	# Print the decile coordinates to file
	for (my $i = 1; $i <= 10; $i++) {
		open my $decile_out, ">", $file_strings->[103+$i] or
		croak "Could not write to $file_strings->[103+$i] $! \n";
		print $decile_out join("\n",
			@{$genomic_coordinates->{decile_coordinates}{$i}});
	}
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
