package PeaksToGenes::Update 0.001;
use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Update::Delete;
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

my $file_base = "$FindBin::Bin/../";

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
	# Create an instance of PeaksToGenes::Update::Delete
	my $delete_genome = PeaksToGenes::Update::Delete->new(
		genome	=>	$self->genome,
		schema	=>	$self->schema,
	);
	# Run the PeaksToGenes::Update::Delete delete subroutine to
	# delete any instances of the user-defined genome to update
	$delete_genome->delete;
	# Create an instance on PeaksToGenes::Update::UCSC
	my $ucsc = PeaksToGenes::Update::UCSC->new(
		genome	=>	$self->genome,
	);
	# Run the PeaksToGenes::Update::UCSC fetch_tables subroutine
	# to download the minimal base tables for the user-defined
	# genome
	my $base_files = $ucsc->fetch_tables;
	# Create a Hash Ref to insert into the available_genomes tables
	my $available_genomes_insert = [
		{
			genome	=>	$self->genome,
			_100K_Upstream_Peaks_File	=>	$base_files->[0],
			_50K_Upstream_Peaks_File	=>	$base_files->[1],
			_25K_Upstream_Peaks_File	=>	$base_files->[2],
			_10K_Upstream_Peaks_File	=>	$base_files->[3],
			_5K_Upstream_Peaks_File	=>	$base_files->[4],
			_Promoters_Peaks_File	=>	$base_files->[5],
			_5Prime_UTR_Peaks_File	=>	$base_files->[6],
			_Exons_Peaks_File	=>	$base_files->[7],
			_Introns_Peaks_File	=>	$base_files->[8],
			_3Prime_UTR_Peaks_File	=>	$base_files->[9],
			_2_5K_Downstream_Peaks_File	=>	$base_files->[10],
			_5K_Downstream_Peaks_File	=>	$base_files->[11],
			_10K_Downstream_Peaks_File	=>	$base_files->[12],
			_25K_Downstream_Peaks_File	=>	$base_files->[13],
			_50K_Downstream_Peaks_File	=>	$base_files->[14],
			_100K_Downstream_Peaks_File	=>	$base_files->[15],
		}
	];
	# Create an instance of the AvailableGenome results set and insert files
	my $available_genomes_results_set = $self->schema->resultset('AvailableGenome');
	$available_genomes_results_set->populate($available_genomes_insert);
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
