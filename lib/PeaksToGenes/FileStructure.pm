package PeaksToGenes::FileStructure 0.001;
use Moose;
use Carp;
use FindBin;
use Data::Dumper;

=head1 NAME

PeaksToGenes::FileStructure

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
using the PeaksToGenes::FileStructure class.

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
);

my $file_base = "$FindBin::Bin/../";

=head1 SUBROUTINES/METHODS

=head2 test_and_extract

This subroutine is called by the main PeaksToGenes class. Using
the PeaksToGenes::Schema database, and the user-defined genome,
this subroutine tests to make sure that the user-defined genome
exists in the database. If the user-defined genome exists in the
database, return to the user a Hash Ref of information about the
database including an ArrayRef of file locations for the index.

=cut

sub test_and_extract {
	my $self = shift;
	# Create an Annotatedpeak results set
	my $annotated_peaks_result_set = $self->schema->resultset('Annotatedpeak');
	# Search the Annotatedpeak results set for the user-defined name
	my $annotated_peaks_search_results = $annotated_peaks_result_set->search(
		{
			name	=>	$self->name
		}
	);
	# If the name is already used in the database, return an error to the user
	while ( my $annotated_peaks_search_result = $annotated_peaks_search_results->next ) {
		die "The user-defined experiment name: " . $self->name . ". Is already in use. Either delete those entries in the database or choose another experiment name.\n\n";
	}
	# Create an AvailableGenome results set
	my $available_genomes_result_set = $self->schema->resultset('AvailableGenome');
	# Search the AvailableGenome results set for the user-defined genome
	my $available_genomes_search_results = $available_genomes_result_set->search(
		{
			genome	=>	$self->genome
		}
	);
	# Pre-declare an Array Ref to hold the file structure
	my $genome_info = [];
	# Iterate through the returned rows (there should only be one) and extract the
	# relevant information to return to the user
	while ( my $available_genomes_search_result = $available_genomes_search_results->next ) {
		push(@$genome_info, $available_genomes_search_result->_100k_upstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_50k_upstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_25k_upstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_10k_upstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_5k_upstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_promoters_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_5prime_utr_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_exons_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_introns_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_3prime_utr_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_2_5k_downstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_5k_downstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_10k_downstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_25k_downstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_50k_downstream_peaks_file);
		push(@$genome_info, $available_genomes_search_result->_100k_downstream_peaks_file);
	}
	# If the genome is not defined in the search results, return an error message
	# to the user
	unless ( @$genome_info ) {
		die "\n\nThe user-defined genome " . $self->genome . " has not been added to this installation's AvailableGenomes database.\nPlease use the --update function to add your desired database to your installation of PeaksToGenes.\n\n";
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

    perldoc PeaksToGenes::FileStructure


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


1; # End of PeaksToGenes::FileStructure
