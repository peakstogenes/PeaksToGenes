package PeaksToGenes::Annotate::FileStructure 0.001;
use Moose;
use Carp;
use FindBin;

=head1 NAME

PeaksToGenes::Annotate::FileStructure

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module takes the genome from the command line options
and determines which index to use for annotating the locations
of the summits.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::Annotate::FileStructure class.

=cut

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
	lazy		=>	1,
	default		=>	'',
);

=head1 SUBROUTINES/METHODS

=head2 test_and_extract

This subroutine is called by the PeaksToGenes::Annotate class. Using the
PeaksToGenes::Schema database, and the user-defined genome, this subroutine
tests to make sure that the user-defined genome exists in the database. If
the user-defined genome exists in the database, return to the user a Hash
Ref of information about the database including an ArrayRef of file
locations for the index.

=cut

sub test_and_extract {
	my $self = shift;

	# Call the PeaksToGenes::Annotate::FileStructure::test_name subroutine to ensure
	# that the user-defined name has not been used before
	$self->test_name;

	# Call the PeaksToGenes::Annotate::FileStructure::test_genome
	# subroutine to ensure that the user-defined genome has been indexed.
	my $available_genomes_search_result = $self->test_genome;

	# Call the PeaksToGenes::Annotate::FileStructure::get_index_file_names
	# subroutine to extract the names of the index files for the
	# user-defined genome.
	my $genome_info =
	$self->get_index_file_names($available_genomes_search_result);

	# Return the ordered Array Ref of index files to the controller
	# PeaksToGenes module
	return $genome_info;
}

sub test_name {
	my $self = shift;
	# Search the Annotatedpeak results set for the user-defined name
	my $experiment_search_results = $self->schema->resultset('Experiment')->search(
		{
			experiment	=>	$self->name
		}
	);
	# If the name is already used in the database, return an error to the user
	while ( my $experiment_search_result = $experiment_search_results->next ) {
		die "\n\nThe user-defined experiment name: " . $self->name . ". Is already in use. Either delete those entries in the database or choose another experiment name.\n\n";
	}
}

sub test_genome {
	my $self = shift;
	# Search the AvailableGenome results set for the user-defined genome
	my $available_genomes_search_result =
	$self->schema->resultset('AvailableGenome')->find(
		{
			genome	=>	$self->genome
		}
	);
	unless ( $available_genomes_search_result && $available_genomes_search_result->genome eq $self->genome ) {
		croak "\n\nThe user-defined genome " . $self->genome . " has not been indexed. Please use the 'update' function to add the genome.\n\n";
	}
	return $available_genomes_search_result;
}

sub get_index_file_names {
	my ($self, $available_genomes_search_result) = @_;
	# Pre-declare an Array Ref to hold the file structure
	my $genome_info = [];
	push(@$genome_info, $available_genomes_search_result->_5prime_utr_peaks_file);
	push(@$genome_info, $available_genomes_search_result->_exons_peaks_file);
	push(@$genome_info, $available_genomes_search_result->_introns_peaks_file);
	push(@$genome_info, $available_genomes_search_result->_3prime_utr_peaks_file);
	for ( my $i = 0; $i < 100; $i += 10 ) {
		my $location_string = '_gene_body_' . $i . '_to_' . ($i+10) .
		'_peaks_file';
		push(@$genome_info,
			$available_genomes_search_result->$location_string);
	}
	for ( my $i = 1; $i <= 10; $i++ ) {
		my $upstream_file = '_' . $i . 'kb_upstream_peaks_file';
		my $downstream_file = '_' . $i . 'kb_downstream_peaks_file';
		unshift(@$genome_info, $available_genomes_search_result->$upstream_file);
		push(@$genome_info, $available_genomes_search_result->$downstream_file);
	}
	return $genome_info;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Annotate::FileStructure


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


1; # End of PeaksToGenes::Annotate::FileStructure
