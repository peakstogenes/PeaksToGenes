package PeaksToGenes::Database 0.001;
use Moose;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Database

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This Module will insert the peaks to genes information in the database if
desired by the user.

It will also print the peaks to genes information and a summary table to
file.

=head1 SUBROUTINES/METHODS

=cut

=head2 Moose declarations

This section holds the moose constructor declarations

=cut

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has indexed_peaks	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has ordered_index	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[Str]',
	required	=>	1,
);

has genome			=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has base_regex	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
	default		=>	sub {
		my $self = shift;
		# Create a regular expression string to be used to match the
		# location of each index file.
		my $base_regex = "\.\.\/" . $self->genome . "_Index\/" .
		$self->genome;
		return $base_regex;
	}
);

has deciles_summary_hash	=>	(
	is				=>	'ro',
	isa				=>	'HashRef',
	required		=>	1,
	default			=>	sub {
		my $self = shift;
		my $summary_hash = {};
		return $summary_hash;
	},
);

has transcript_regions_summary_hash	=>	(
	is				=>	'ro',
	isa				=>	'HashRef',
	required		=>	1,
	default			=>	sub {
		my $self = shift;
		my $summary_hash = {};
		return $summary_hash;
	},
);


=head2 summary_and_out

This subroutine will take the peaks to genes file structure and write
it and a summary to file.

=cut

sub summary_and_out {
	my $self = shift;

	# Run the PeaksToGenes::Database::extract_genome_id subroutine to extract
	# the genome id key for the user-defined genome
	my $genome_id = $self->extract_genome_id;

	# Run the PeaksToGenes::Database::parse_row_items function to return an
	# Array Ref for the peaks_to_genes summary table and a DBIx::Class
	# insert statement.
	my $insert = $self->parse_row_items($genome_id);
	
	# Run the PeaksToGenes::Database::insert_peaks subroutine to insert the
	# extracted information into the PeaksToGenes database.
	$self->insert_peaks($insert);
#
#	# Run the PeaksToGenes::Database::create_header_lines_and_parse_summary
#	# subroutine to parse the summary file and return a header for the
#	# peaks to genes table and a summary file table
#	my ($peaks_to_genes_header, $transcript_regions_summary_file,
#		$deciles_summary_file) =
#	$self->create_header_lines_and_parse_summary;
#
#	# Add the headers to the front of the out arrays
#	unshift(@$peaks_to_genes, join("\t", @$peaks_to_genes_header));
#
#	# Write the peaks to genes array to file
#	open my $peaks_to_genes_out, ">", $self->name .
#	"_Peaks_To_Genes_Full_Table.txt" or die "Could not write to file: " .
#	$self->name . "_Peaks_To_Genes_Full_Table.txt\n\n$!";
#	print $peaks_to_genes_out join("\n", @$peaks_to_genes);
#
#	# Write the transcript regions summary array to file
#	open my $transcript_regions_summary_out, ">", $self->name .
#	"_Peaks_To_Genes_Transcript_Regions_Summary_Table.txt" or die 
#	"Could not write to file: " . $self->name .
#	"_Peaks_To_Genes_Transcript_Regions_Summary_Table.txt\n\n$!";
#	print $transcript_regions_summary_out join("\n",
#		@$transcript_regions_summary_file);
#
#	# Write the deciles summary array to files
#	open my $deciles_summary_out, ">", $self->name .
#	"_Peaks_To_Genes_Deciles_Summary_Table.txt" or die 
#	"Could not write to file: " . $self->name .
#	"_Peaks_To_Genes_Deciles_Summary_Table.txt\n\n$!";
#	print $deciles_summary_out join("\n",
#		@$deciles_summary_file);
}

sub parse_row_items {
	my ($self, $genome_id) = @_;

	# Pre-declare an Array Ref inside a Hash Ref to hold the insert lines
	# for each table:
	my $insert = {
		genome_id	=>	$genome_id,
		experiment	=>	$self->name,
		gene_body_annotations		=>	[],
		gene_body_numbers_of_peaks	=>	[],
		downstream_annotations		=>	[],
		downstream_numbers_of_peaks	=>	[],
		upstream_annotations		=>	[],
		upstream_numbers_of_peaks	=>	[],
		transcript_annotations		=>	[],
		transcript_numbers_of_peaks	=>	[],
	};

	# Copy the base regular expression into a scalar string
	my $base_regex = $self->base_regex;

	# Iterate through the genes keys in the indexed peaks structure
	foreach my $accession ( keys %{$self->indexed_peaks} ) {

		# Iterate through the ordered index and extract the required information
		# from the indexed_peaks Hash Ref
		foreach my $file_string (@{$self->ordered_index}) {

			# Create a string to hold the relative location
			my $location = '';
			if ($file_string =~ qr/($base_regex)(.+?)\.bed$/ ) {
				$location = $2;
			}

			# Append the information type to the location string
			my $peak_number = $location . '_Number_of_Peaks';
			my $peak_info = $location . '_Peaks_Information';

			# Add the number of peaks column to the row items
			if ( $self->indexed_peaks->{$accession}{$location .
				'_Interval_Size'}  &&
				$self->indexed_peaks->{$accession}{$location .
				'_Interval_Size'} > 0 ) {
				# Normalize the number of peaks found in the interval to
				# peaks per Kb in place
				$self->indexed_peaks->{$accession}{$peak_number} /=
				($self->indexed_peaks->{$accession}{$location .
					'_Interval_Size'} / 1000);
			}
		}

		# Pre-declare a Hash Ref for each type of insert for this line
		my $upstream_annotation_insert_line = {};
		my $downstream_annotation_insert_line = {};
		my $transcript_annotation_insert_line = {};
		my $gene_body_annotation_insert_line = {};
		my $upstream_number_of_peaks_insert_line = {};
		my $downstream_number_of_peaks_insert_line = {};
		my $gene_body_number_of_peaks_insert_line = {};
		my $transcript_number_of_peaks_insert_line = {};

		# Search for the transcript id from the transcripts table
		my $transcript_id = $self->extract_transcript_id($accession);

		$gene_body_annotation_insert_line->{gene} = $transcript_id;
		$gene_body_annotation_insert_line->{genome_id} = $genome_id;

		$gene_body_number_of_peaks_insert_line->{gene} = $transcript_id;
		$gene_body_number_of_peaks_insert_line->{genome_id} = $genome_id;

		$upstream_annotation_insert_line->{gene} = $transcript_id;
		$upstream_annotation_insert_line->{genome_id} = $genome_id;

		$downstream_annotation_insert_line->{gene} = $transcript_id;
		$downstream_annotation_insert_line->{genome_id} = $genome_id;

		$transcript_annotation_insert_line->{gene} = $transcript_id;
		$transcript_annotation_insert_line->{genome_id} = $genome_id;
		
		$upstream_number_of_peaks_insert_line->{gene} = $transcript_id;
		$upstream_number_of_peaks_insert_line->{genome_id} = $genome_id;


		$downstream_number_of_peaks_insert_line->{gene} = $transcript_id;
		$downstream_number_of_peaks_insert_line->{genome_id} = $genome_id;

		$transcript_number_of_peaks_insert_line->{gene} = $transcript_id;
		$transcript_number_of_peaks_insert_line->{genome_id} = $genome_id;


		$transcript_number_of_peaks_insert_line->{_3prime_utr_number_of_peaks} =
		$self->indexed_peaks->{$accession}{_3Prime_UTR_Number_of_Peaks};
		$transcript_annotation_insert_line->{_3prime_utr_peaks_information} =
		$self->indexed_peaks->{$accession}{_3Prime_UTR_Peaks_Information};

		$transcript_number_of_peaks_insert_line->{_5prime_utr_number_of_peaks} =
		$self->indexed_peaks->{$accession}{_5Prime_UTR_Number_of_Peaks};
		$transcript_annotation_insert_line->{_5prime_utr_peaks_information} =
		$self->indexed_peaks->{$accession}{_5Prime_UTR_Peaks_Information};

		$transcript_number_of_peaks_insert_line->{_exons_number_of_peaks} =
		$self->indexed_peaks->{$accession}{_Exons_Number_of_Peaks};
		$transcript_annotation_insert_line->{_exons_peaks_information} =
		$self->indexed_peaks->{$accession}{_Exons_Peaks_Information};

		$transcript_number_of_peaks_insert_line->{_introns_number_of_peaks} =
		$self->indexed_peaks->{$accession}{_Introns_Number_of_Peaks};
		$transcript_annotation_insert_line->{_introns_peaks_information} =
		$self->indexed_peaks->{$accession}{_Introns_Peaks_Information};

		for (my $i = 0; $i < 100; $i += 10) {
			$gene_body_number_of_peaks_insert_line->{'_gene_body_' . $i .
			'_to_' . ($i + 10) . '_number_of_peaks'} =
			$self->indexed_peaks->{$accession}{'_Gene_Body_' . $i . '_to_'
			. ($i + 10) . '_Number_of_Peaks'};
			$gene_body_annotation_insert_line->{'_gene_body_' . $i . '_to_'
			. ($i + 10) . '_peaks_information'} =
			$self->indexed_peaks->{$accession}{'_Gene_Body_' . $i . '_to_'
			. ($i + 10) . '_Peaks_Information'};
		}

		for ( my $i = 1; $i <= 100; $i++ ) {

			$upstream_annotation_insert_line->{'_' . $i .
			'kb_upstream_peaks_information'} =
			$self->indexed_peaks->{$accession}{'_' . $i .
			'Kb_Upstream_Peaks_Information'};

			$downstream_annotation_insert_line->{'_' . $i .
			'kb_downstream_peaks_information'} =
			$self->indexed_peaks->{$accession}{'_' . $i .
			'Kb_Downstream_Peaks_Information'};

			$upstream_number_of_peaks_insert_line->{'_' . $i .
			'kb_upstream_number_of_peaks'} =
			$self->indexed_peaks->{$accession}{'_' . $i .
			'Kb_Upstream_Number_of_Peaks'};

			$downstream_number_of_peaks_insert_line->{'_' . $i .
			'kb_downstream_number_of_peaks'} =
			$self->indexed_peaks->{$accession}{'_' . $i .
			'Kb_Downstream_Number_of_Peaks'};

		}

		# Add the insert lines to the insert statements
		push(@{$insert->{upstream_annotations}},
			$upstream_annotation_insert_line);
		push(@{$insert->{downstream_annotations}},
			$downstream_annotation_insert_line);
		push(@{$insert->{transcript_annotations}},
			$transcript_annotation_insert_line);
		push(@{$insert->{gene_body_annotations}},
			$gene_body_annotation_insert_line);
		push(@{$insert->{gene_body_numbers_of_peaks}},
			$gene_body_number_of_peaks_insert_line);
		push(@{$insert->{upstream_numbers_of_peaks}},
			$upstream_number_of_peaks_insert_line);
		push(@{$insert->{downstream_numbers_of_peaks}},
			$downstream_number_of_peaks_insert_line);
		push(@{$insert->{transcript_numbers_of_peaks}},
			$transcript_number_of_peaks_insert_line);

	}

	return $insert;
}

=head2 insert_peaks

This subroutine is called to insert the DBIx statement into the database

=cut

sub insert_peaks {
	my ($self, $insert) = @_;

	my $guard = $self->schema->txn_scope_guard;

	$self->schema->resultset('Experiment')->populate([$insert]);

	$guard->commit;
	
}

sub extract_genome_id {
	my $self = shift;

	# Pre-define an integer to hold the genome id
	my $genome_id = 0;

	# Create an AvailableGenome result set
	my $available_genomes_result_set = $self->schema->resultset('AvailableGenome');

	# Search the AvailableGenome result set for the id that corresponds
	# to the user-defined genome
	my $available_genomes_search_results = $available_genomes_result_set->search(
		{
			genome	=>	$self->genome
		}
	);

	# Extract the genome id
	while ( my $available_genomes_search_result =
		$available_genomes_search_results->next ) {
		$genome_id = $available_genomes_search_result->id;
	}

	return $genome_id;
}

sub extract_transcript_id {
	my ($self, $accession) = @_;
	# Search for the transcript id from the transcripts table
	my $transcript_search_result =
	$self->schema->resultset('Transcript')->find(
		{
			transcript	=>	$accession
		}
	);
	return $transcript_search_result->id;
}
	

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Database


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

1; # End of PeaksToGenes::Database

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Database


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

1; # End of PeaksToGenes::Database
