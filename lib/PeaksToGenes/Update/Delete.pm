package PeaksToGenes::Update::Delete 0.001;
use Moose;
use Carp;
use FindBin;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Update::Delete

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is called by the PeaksToGenes::Update module to
delete instances in AvailableGenomes database matching the
user-defined genome.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::Update::Delete class.

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

=head1 SUBROUTINES/METHODS

=head2 update

This subroutine is called to delete any instances of the user-defined
genome in the AvailableGenomes database.

=cut

sub delete {
	my $self = shift;
	# Create an AvailableGenome results set
	my $available_genomes_result_set = $self->schema->resultset('AvailableGenome');
	# Search the AvailableGenome results set for the user-defined genome
	my $available_genomes_search_results = $available_genomes_result_set->search(
		{
			genome	=>	$self->genome
		}
	);
	# Iterate through the returned rows (there should only be one) and extract the
	# relevant information to return to the user
	while ( my $available_genomes_search_result = $available_genomes_search_results->next ) {
		$available_genomes_search_result->delete;
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

    perldoc PeaksToGenes::Update::Delete


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


1; # End of PeaksToGenes::Update::Delete
