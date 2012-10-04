package PeaksToGenes::Update 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Update::UCSC;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Update

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module is called by the main PeaksToGenes module. It is used to
interact with the UCSC Genome Browser tables to download the minimal
tables to create an index for the user-defined genome. Once the tables
have been downloaded, this module will then create the required index
files to annotate peaks. The AvailableGenomes database will be updated
appropriately based what information is defined by the user.

=cut

=head2 Moose declarations

This section is for declaring Moose objects that can be created when
using the PeaksToGenes::Update class.

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

This is the main subroutine called by the PeaksToGenes module.
It will delete any existing instances of the user-defined genome
in the AvailableGenomes database. Download the required files from
the UCSC Genome Browser. Create the remaining required index files.
Finally, it will update the AvailableGenomes database.

=cut

sub update {
	my $self = shift;
	# Create an instance on PeaksToGenes::Update::UCSC
	my $ucsc = PeaksToGenes::Update::UCSC->new(
		genome	=>	$self->genome,
	);
	# Run the PeaksToGenes::Update::UCSC fetch_tables subroutine
	# to download the minimal base tables for the user-defined
	# genome
	my $base_files = $ucsc->fetch_tables;
	# Run the create_statement subroutine to iterate through the base files
	# and extract the relative location of the index files using a compiled
	# regular expression
	my $available_genomes_insert = $self->create_statement($base_files);
	# Make a call to the update_database subroutine to insert the lines
	# into the database
	$self->update_database($available_genomes_insert);
}

sub create_statement {
	my ($self, $base_files) = @_;
	# Create a Hash Ref to insert into the available_genomes tables
	my $available_genomes_insert = [
		{
			genome	=>	$self->genome,
		}
	];
	# Create a stored regular expression to extract the base table names
	# from each file
	my $genome = $self->genome;
	my $regex_search = qr/static\/($genome)_Index\/($genome)(_.+?)\.bed$/;
	# Iterate through the files created and add them to the insert statement
	foreach my $file_string (@$base_files) {
		if ($file_string =~ m/$regex_search/) {
			$available_genomes_insert->[0]{lc($3) . "_peaks_file"} = $file_string;
		} else {
			die "\n\nCould not match $file_string to pattern. Please check with your installation or version of Perl.\n\n";
		}
	}
	return $available_genomes_insert;
}

sub update_database {
	my ($self, $available_genomes_insert) = @_;
	# Create an instance of the AvailableGenome results set and insert files
	my $available_genomes_results_set = $self->schema->resultset('AvailableGenome');
	$available_genomes_results_set->update_or_create(@$available_genomes_insert);
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Update


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


1; # End of PeaksToGenes::Update
