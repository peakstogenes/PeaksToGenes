package PeaksToGenes::Annotate 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Annotate::BedTools;
use PeaksToGenes::Annotate::Database;
use PeaksToGenes::Annotate::FileStructure;

=head1 NAME

PeaksToGenes::Annotate

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This is the controller module, which makes the calls to
PeaksToGenes::Annotate::FileStructure, PeaksToGenes::Annotate::BedTools,
and PeaksToGenes::Annotate::Database to align the user-defined genomic
coordinates with the genomic regions for the user-defined genome.

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
);

has bed_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	1,
);

=head2 annotate

The PeaksToGenes::Annotate::annotate subroutine is called by the main
Controller PeaksToGenes to make the appropriate calls and accomplishes the
folloing:

	1. Ensures the experiment name is unique
	2. Ensures that the user-define genome index is installed
	3. Using an ordered Array Ref, calls instersectBed to intersect the
	   user-defined intervals with the genomic index
	4. Parses the intersected  regions:
		a. Stores experimental interval coordinates, name, and score
		b. Stores the number of experimental intervals per genomic
		   interval
		c. Measures the length of each genomic interval, which was
		   overlapped by an experimental interval
	5. Normalize the number of experimental intervals by length of the
	   genomic interval
	6. Store the information in the PeaksToGenes SQLite database.

=cut

sub annotate {
	my $self = shift;
	
	# Create an instance of PeaksToGenes::Annotate::FileStructure, and run
	# the PeaksToGenes::Annotate::FileStructure::test_and_extract
	# subroutine, which ensures the experiment name is unique, the genome
	# index exists, and returns an Array Ref of index file strings.
	my $file_structure = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$self->schema,
		genome	=>	$self->genome,
		name	=>	$self->name,
	);
	my $genome_info = $file_structure->test_and_extract;

	# Create an instance of PeaksToGenes::Annotate::BedTools and run the
	# PeaksToGenes::Annotate::BedTools::annotate_peaks subroutine to check
	# whether the user-defined experiment name has been used, and then uses
	# intersectBed to determine which genomic intervals overlap the
	# experimental intervals and returns the information in a Hash Ref
	my $bedtools = PeaksToGenes::Annotate::BedTools->new(
		schema		=>	$self->schema,
		genome		=>	$self->genome,
		index_files	=>	$genome_info,
		bed_file	=>	$self->bed_file,
		processors	=>	$self->processors,
	);
	my $indexed_peaks = $bedtools->annotate_peaks;

	# Create an instance of PeaksToGenes::Annotate::Database and run the
	# PeaksToGenes::Annotate::Database::parse_and_store subroutine to parse
	# the entries stored in the indexed_peaks Hash Ref into a DBIx insert
	# statement and insert the information into the PeaksToGenes database.
	my $database = PeaksToGenes::Annotate::Database->new(
		schema			=>	$self->schema,
		indexed_peaks	=>	$indexed_peaks,
		name			=>	$self->name,
		ordered_index	=>	$genome_info,
		genome			=>	$self->genome,
		processors		=>	$self->processors,
	);
	$database->parse_and_store;
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


1; # End of PeaksToGenes::Annotate
