package PeaksToGenes::Contrast::Genes 0.001;
use Moose;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Contrast::Genes  

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is called by the PeaksToGenes::Contrast controller module to
extract lists of test genes and background genes to be used for statistical
tests of enrichment.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::Contrast::Genes class.

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

has test_genes_fh	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
);

has background_genes_fh	=>	(
	is					=>	'ro',
	isa					=>	'Str',
);

=head1 SUBROUTINES/METHODS

=head2 get_genes

This is the main subroutine called by the PeaksToGenes::Contrast controller
class. This subroutine will return to the controller Array Refs of valid
test genes, invalid test genes (if found), valid background genes, and
invalid background genes (if found). 

=cut

sub get_genes {
	my $self = shift;

	# Call PeaksToGenes::Contrast::Genes::all_genes to get a
	# DBIx::Class::ResultSet of all genes corresponding to the genome
	# defined by the user
	my $all_genes_result_set = $self->all_genes;

	# Call PeaksToGenes::Contrast::Genes::extract_genes to extract an Array
	# Ref of transcript ID's for the valid accessions, and an Array Ref of
	# RefSeq accessions not found in the list of accessions for the
	# user-defined genome.
	my ($valid_test_ids, $invalid_test_accessions) =
	$self->extract_genes($self->test_genes_fh, $all_genes_result_set);

	# If the PeaksToGenes::Contrast::Genes::background_genes_fh	has been
	# set, extract the valid and invalid accessions using
	# PeaksToGenes::Contrast::Genes::extract_genes, otherwise use the
	# PeaksToGenes::Contrast::Genes::default_background subroutine to
	# define a background of all genes not defined as test genes
	if ( $self->background_genes_fh ) {
		my ($valid_background_ids, $invalid_background_accessions) =
		$self->extract_genes($self->background_genes_fh,
			$all_genes_result_set);
		return ($valid_test_ids, $invalid_test_accessions,
			$valid_background_ids, $invalid_background_accessions);
	} else {
		my $valid_background_ids =
		$self->default_background($valid_test_ids, $all_genes_result_set);
		return ($valid_test_ids, $invalid_test_accessions,
			$valid_background_ids, []);
	}
}

sub all_genes {
	my $self = shift;

	# Get the genome ID from the AvailableGenome table
	my $genome_id = $self->schema->resultset('AvailableGenome')->find(
		{
			genome	=>	$self->genome,
		}
	)->id or croak "Could not find genome: " . $self->genome . 
	". Please check that you have entered a genome, which is valid and " .
	"annotated in the PeaksToGenes database\n\n";

	# Fetch the result set from the Transcript table
	my $all_genes_result_set =
	$self->schema->resultset('Transcript')->search(
		{
			genome_id	=>	$genome_id,
		}
	);
	if ( $all_genes_result_set->next ) {
		$all_genes_result_set->reset;
		return $all_genes_result_set;
	} else {
		croak "The genes for the genome: " . $self->genome .
		" could not be found. Please check that this genome is ".
		"correct\n\n";
	}
}

sub extract_genes {
	my ($self, $fh, $all_genes_result_set) = @_;

	# Pre-declare Array Refs for the valid ID and the invalid accessions
	my $valid_ids = [];
	my $invalid_accessions = [];

	# Open the user-defined file, iterate through the accessions, and
	# extract the IDs from the result set. If found, push the ID onto the
	# valid_ids Array Ref, if not found push the accession onto the
	# invalid_accessions Array Ref
	open my $file, "<", $fh or croak "Could not read from $fh please check"
	. " that this is a readable file $! \n\n";
	while (<$file>) {
		my $accession = $_;
		chomp($accession);
		my $transcript_id;
	   eval { 
		   $transcript_id = $all_genes_result_set->find(
				{
					transcript	=>	$accession,
				}
			)->id;
		};
		$transcript_id ? push(@$valid_ids, $transcript_id) :
		push(@$invalid_accessions, $accession);
	}
	return ($valid_ids, $invalid_accessions);
}

sub default_background {
	my ($self, $valid_test_ids, $all_genes_result_set) = @_;

	# Create a Hash Ref of transcript IDs that are in the test list
	my $test_ids = {};
	foreach my $valid_test_id (@$valid_test_ids) {
		$test_ids->{$valid_test_id} = 1;
	}

	# Pre-declare an Array Ref to hold the valid_background_ids
	my $valid_background_ids = [];

	# Iterate through the all_genes_result_set and if the transcript ID is
	# not in the test_ids Hash Ref, push it onto the valid_background_ids
	# Array Ref
	while ( my $all_genes_result_line = $all_genes_result_set->next ) {
		unless ( $test_ids->{$all_genes_result_line->id} ) {
			push(@$valid_background_ids, $all_genes_result_line->id);
		}
	}
	return $valid_background_ids;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Contrast::Genes


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


1; # End of PeaksToGenes::Contrast::Genes
