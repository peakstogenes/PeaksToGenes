
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

package PeaksToGenes::Annotate::Database 0.001;
use Moose;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Annotate::Database

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is designed to parse the entries stored in the Hash Ref
returned by PeaksToGenes::Annotate::BedTools, normalize the number of
experimental intervals per Kb, and store the information in the
PeaksToGenes SQLite database.

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

=head2 parse_and_store

This subroutine is the main function called by the PeaksToGenes::Annotate
controller class.

=cut

sub parse_and_store {
	my $self = shift;

	# Run the PeaksToGenes::Annotate::Database::extract_genome_id
	# subroutine to extract the genome id key for the user-defined genome.
	my $genome_id = $self->extract_genome_id;

	# Run the PeaksToGenes::Annotate::Database::parse_row_items function to
	# return an Array Ref for the peaks_to_genes summary table and a
	# DBIx::Class insert statement.
	my $insert = $self->parse_row_items($genome_id);
	
	# Run the PeaksToGenes::Annotate::Database::insert_peaks subroutine to insert the
	# extracted information into the PeaksToGenes database.
	$self->insert_peaks($insert);
}

sub parse_row_items {
	my ($self, $genome_id) = @_;

	# Pre-declare an Array Ref inside a Hash Ref to hold the insert lines
	# for each table:
	my $insert = {
		genome_id	=>	$genome_id,
		experiment	=>	$self->name,
		gene_body_numbers_of_peaks	=>	[],
		downstream_numbers_of_peaks	=>	[],
		upstream_numbers_of_peaks	=>	[],
		transcript_numbers_of_peaks	=>	[],
	};

	# Copy the base regular expression into a scalar string
	my $base_regex = $self->base_regex;
	
	# Iterate through the genes keys in the indexed peaks structure
	foreach my $accession ( keys %{$self->indexed_peaks} ) {

		# Search for the transcript id from the transcripts table
		my $transcript_id = $self->extract_transcript_id($accession,
			$genome_id);

		# Pre-define a Hash Ref for each type of insert for this line
		my $upstream_number_of_peaks_insert_line = {
			gene		=>	$transcript_id,
			genome_id	=>	$genome_id,
		};
		my $downstream_number_of_peaks_insert_line = {
			gene		=>	$transcript_id,
			genome_id	=>	$genome_id,
		};
		my $gene_body_number_of_peaks_insert_line = {
			gene		=>	$transcript_id,
			genome_id	=>	$genome_id,
		};
		my $transcript_number_of_peaks_insert_line = {
			gene		=>	$transcript_id,
			genome_id	=>	$genome_id,
		};

		# Add the 3'-UTR number of peaks to the transcript information
		# insert lines
		if (
			$self->indexed_peaks->{$accession}{_3Prime_UTR_Number_of_Peaks}
			) {
			$transcript_number_of_peaks_insert_line->{_3prime_utr_number_of_peaks} =
			$self->indexed_peaks->{$accession}{_3Prime_UTR_Number_of_Peaks};
		} else {
			$transcript_number_of_peaks_insert_line->{_3prime_utr_number_of_peaks}
			= 0;
		}

		# Add the 5'-UTR peak information and number of peaks to the
		# transcript information insert lines
		if (
			$self->indexed_peaks->{$accession}{_5Prime_UTR_Number_of_Peaks}
			) {
			$transcript_number_of_peaks_insert_line->{_5prime_utr_number_of_peaks} =
			$self->indexed_peaks->{$accession}{_5Prime_UTR_Number_of_Peaks};
		} else {
			$transcript_number_of_peaks_insert_line->{_5prime_utr_number_of_peaks}
			= 0;
		}

		# Add the exons peak information and number of peaks to the
		# transcript information insert lines
		if ( $self->indexed_peaks->{$accession}{_Exons_Number_of_Peaks} ) {
			$transcript_number_of_peaks_insert_line->{_exons_number_of_peaks} =
			$self->indexed_peaks->{$accession}{_Exons_Number_of_Peaks};
		} else {
			$transcript_number_of_peaks_insert_line->{_exons_number_of_peaks}
			= 0;
		}

		# Add the introns peak information and number of peaks to the
		# transcript information insert lines
		$transcript_number_of_peaks_insert_line->{_introns_number_of_peaks} =
		$self->indexed_peaks->{$accession}{_Introns_Number_of_Peaks};

		# Iterate by decile to add the decile peak information and number
		# of peaks to the gene body insert lines
		for (my $i = 0; $i < 100; $i += 10) {
			if ( $self->indexed_peaks->{$accession}{'_Gene_Body_' . $i .
				'_to_' . ($i + 10) . '_Number_of_Peaks'} ) {
				$gene_body_number_of_peaks_insert_line->{'_gene_body_' . $i .
				'_to_' . ($i + 10) . '_number_of_peaks'} =
				$self->indexed_peaks->{$accession}{'_Gene_Body_' . $i . '_to_'
				. ($i + 10) . '_Number_of_Peaks'};
			} else {
				$gene_body_number_of_peaks_insert_line->{'_gene_body_' . $i .
				'_to_' . ($i + 10) . '_number_of_peaks'} = 0;
			}
		}

		# Iterate through the upstream and downstream locations and add the
		# peaks information and number of peaks to the upstream and
		# downstream peaks insert lines
		for ( my $i = 1; $i <= 10; $i++ ) {

			if ( $self->indexed_peaks->{$accession}{'_' . $i .
				'Kb_Upstream_Number_of_Peaks'} ) {
				$upstream_number_of_peaks_insert_line->{'_' . $i .
				'kb_upstream_number_of_peaks'} =
				$self->indexed_peaks->{$accession}{'_' . $i .
				'Kb_Upstream_Number_of_Peaks'};
			} else {
				$upstream_number_of_peaks_insert_line->{'_' . $i .
				'kb_upstream_number_of_peaks'} = 0;
			}

			if ( $self->indexed_peaks->{$accession}{'_' . $i .
				'Kb_Downstream_Number_of_Peaks'} ) {
				$downstream_number_of_peaks_insert_line->{'_' . $i .
				'kb_downstream_number_of_peaks'} =
				$self->indexed_peaks->{$accession}{'_' . $i .
				'Kb_Downstream_Number_of_Peaks'};
			} else {
				$downstream_number_of_peaks_insert_line->{'_' . $i .
				'kb_downstream_number_of_peaks'} = 0;
			}
		}

		# Add the lines to the insert statement
		push(@{$insert->{gene_body_numbers_of_peaks}},
			$gene_body_number_of_peaks_insert_line);
		push(@{$insert->{upstream_numbers_of_peaks}},
			$upstream_number_of_peaks_insert_line);
		push(@{$insert->{downstream_numbers_of_peaks}},
			$downstream_number_of_peaks_insert_line);
		push(@{$insert->{transcript_numbers_of_peaks}},
			$transcript_number_of_peaks_insert_line);

	}

	# Return the insert statement to the main subroutine
	return $insert;
}

=head2 insert_peaks

This subroutine is called to insert the DBIx statement into the database

=cut

sub insert_peaks {
	my ($self, $insert) = @_;

	# Because the insert statement can be quite large, use the transaction
	# scope guard to increase the speed of the transaction by turning off a
	# few failsafe mechanisms.
	my $guard = $self->schema->txn_scope_guard;

	$self->schema->resultset('Experiment')->populate([$insert]);

	# After the transaction is complete, it is necessary to explicitly
	# commit the transaction
	$guard->commit;
	
}

sub extract_genome_id {
	my $self = shift;

	# Search the AvailableGenome result set for the id that corresponds
	# to the user-defined genome
	my $available_genomes_search_results =
	$self->schema->resultset('AvailableGenome')->find(
		{
			genome	=>	$self->genome
		}
	);
	
	# Return the genomic index id number
	if ( $available_genomes_search_results ) {
		return $available_genomes_search_results->id;
	} else {
		croak "\n\nThere was a problem extracting the " .
		"genome ID from the PeaksToGenes database. " .
		"Please run the update function and try again. " .
		"If the problem persists, please contact the authors" .
		"\n\n";

	}
}

sub extract_transcript_id {
	my ($self, $accession, $genome_id) = @_;

	# Search for the transcript id from the transcripts table
	my $transcript_search_result =
	$self->schema->resultset('Transcript')->find(
		{
			transcript	=>	$accession,
			genome_id	=>	$genome_id
		}
	);

	if ( $transcript_search_result ) {
		return $transcript_search_result->id;
	} else {
		croak "\n\nThere was a problem extracting the transcript ID from" .
		" the PeaksToGenes database. Please run the 'update' function and"
		. " try again. If the problem persists, please contact the authors"
		. "\n\n";
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

    perldoc PeaksToGenes::Annotate::Database


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

1; # End of PeaksToGenes::Annotate::Database

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Annotate::Database


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

1; # End of PeaksToGenes::Annotate::Database
