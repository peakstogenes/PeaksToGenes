package PeaksToGenes::Out 0.001;
use Moose;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Out

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

=head2 summary_and_out

This subroutine will take the peaks to genes file structure and write
it and a summary to file.

=cut

sub summary_and_out {
	my $self = shift;
	# Pre-declare an Array Ref to hold the peaks to genes info structure
	my $peaks_to_genes = [];
	# Pre-declare a Hash Ref to hold the summary information
	my $summary_hash = {};
	# Create a regular expression string to be used to match the location of each
	# index file
	my $base_regex = "\.\.\/" . $self->genome . "_Index\/" . $self->genome;
	# Iterate through the genes keys in the indexed peaks structure
	foreach my $gene ( keys %{$self->indexed_peaks} ) {
		# Pre-declare an Array Ref to hold the columns for the row corresponding
		# to the current RefSeq accession
		my $row_items = [$gene];
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
			# Add the number of peaks column to the row items
			push(@$row_items, $self->indexed_peaks->{$gene}{$peak_number});
			# Add the number of peaks for this location to the summary file
			$summary_hash->{$location} += $self->indexed_peaks->{$gene}{$peak_number};
		}
		# Iterate through a second time to add the peak locations information to
		# the row items
		foreach my $file_string (@{$self->ordered_index}) {
			# Create a string to hold the relative location
			my $location = '';
			if ($file_string =~ qr/($base_regex)(.+?)\.bed$/ ) {
				$location = $2;
			}
			# Append the information type to the location string
			my $peak_info = $location . '_Peaks_Information';
			# Add the number of peaks column to the row items
			push(@$row_items, $self->indexed_peaks->{$gene}{$peak_info});
		}
		# Push the row items onto the peaks to genes file
		push(@$peaks_to_genes, join("\t", @$row_items));
	}
	# Pre-define an Array Ref to hold the temp summary file
	my $temp_summary_file = [];
	my $summary_file = [];
	# Pre-declare an Array Ref to hold the peaks to genes header info
	my $peaks_to_genes_header = [];
	# Pre-declare an Array Ref to hold the summary file header
	my $summary_header = [];
	# Iterate through the locations in the summary hash by using
	# the ordered index
	foreach my $file_string (@{$self->ordered_index}) {
		# Create a string to hold the relative location
		my $location = '';
		if ($file_string =~ qr/($base_regex)(.+?)\.bed$/ ) {
			$location = $2;
		}
		push(@$temp_summary_file, $summary_hash->{$location});
		push(@$peaks_to_genes_header, $self->genome . $location . "_Number_of_Peaks");
		push(@$summary_header, $self->genome . $location . "_Aggregate_Number_of_Peaks");
	}
	foreach my $file_string (@{$self->ordered_index}) {
		# Create a string to hold the relative location
		my $location = '';
		if ($file_string =~ qr/($base_regex)(.+?)\.bed$/ ) {
			$location = $2;
		}
		push(@$peaks_to_genes_header, $self->genome . $location . "_Peaks_Information");
	}
	# Push the temp summary items onto the summary file
	push(@$summary_file, join("\t", @$temp_summary_file));
	# Add the headers to the front of the out arrays
	unshift(@$summary_file, join("\t", @$summary_header));
	unshift(@$peaks_to_genes, join("\t", @$peaks_to_genes_header));
	# Write the peaks to genes array to file
	open my $peaks_to_genes_out, ">", $self->name . "_Peaks_To_Genes_Full_Table.txt" or die "Could not write to file: " . $self->name . "_Peaks_To_Genes_Full_Table.txt\n\n$!";
	print $peaks_to_genes_out join("\n", @$peaks_to_genes);
	open my $summary_out, ">", $self->name . "_Peaks_To_Genes_Summary_Table.txt" or die "Could not write to file: " . $self->name . "_Peaks_To_Genes_Summary_Table.txt\n\n$!";
	print $summary_out join("\n", @$summary_file);
}

=head2 insert_peaks

This subroutine is called when the user has flagged that they want to permanently
store the peaks to genes information in the database.

=cut

sub insert_peaks {
	my $self = shift;
	# Pre-declare an integer to hold the genome id
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
	while ( my $available_genomes_search_result = $available_genomes_search_results->next ) {
		$genome_id = $available_genomes_search_result->id;
	}
	# Create an Array Ref to hold the insert statement
	my $insert = [];
	# Iterate through the indexed peaks and create insert statments
	foreach my $accession ( keys %{$self->indexed_peaks} ) {
		$self->indexed_peaks->{$accession}{genome_id} = $genome_id;
		$self->indexed_peaks->{$accession}{name} = $self->name;
		$self->indexed_peaks->{$accession}{gene} = $accession;
		push(@$insert, $self->indexed_peaks->{$accession});
	}
	# Create an Annotatedpeak result set
	my $annotated_peak_result_set = $self->schema->resultset('Annotatedpeak');
	$annotated_peak_result_set->populate($insert);
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Out


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

1; # End of PeaksToGenes::Out

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Out


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

1; # End of PeaksToGenes::Out
