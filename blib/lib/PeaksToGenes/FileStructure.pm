package PeaksToGenes::FileStructure 0.001;
use Moose::Role;
use Carp;

=head1 NAME

PeaksToGenes::FileStructure

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module takes the species from the command line options
and determines which index to use for annotating the locations
of the summits.


=cut

my $human_index = [                 
	"static/Human_Index/Human_100K_Upstream.bed",
	"static/Human_Index/Human_50K_Upstream.bed",
	"static/Human_Index/Human_25K_Upstream.bed",
	"static/Human_Index/Human_10K_Upstream.bed",
	"static/Human_Index/Human_5K_Upstream.bed",
	"static/Human_Index/Human_Promoters.bed",
	"static/Human_Index/Human_5Prime_UTR.bed",
	"static/Human_Index/Human_Exons.bed",
	"static/Human_Index/Human_Introns.bed",
	"static/Human_Index/Human_3Prime_UTR.bed",
	"static/Human_Index/Human_2.5K_Downstream.bed",
	"static/Human_Index/Human_5K_Downstream.bed",
	"static/Human_Index/Human_10K_Downstream.bed",
	"static/Human_Index/Human_25K_Downstream.bed",
	"static/Human_Index/Human_50K_Downstream.bed",
	"static/Human_Index/Human_100K_Downstream.bed",
];

my $mouse_index = [                 
	"static/Mouse_Index/Mouse_100K_Upstream.bed",
	"static/Mouse_Index/Mouse_50K_Upstream.bed",
	"static/Mouse_Index/Mouse_25K_Upstream.bed",
	"static/Mouse_Index/Mouse_10K_Upstream.bed",
	"static/Mouse_Index/Mouse_5K_Upstream.bed",
	"static/Mouse_Index/Mouse_Promoters.bed",
	"static/Mouse_Index/Mouse_5Prime_UTR.bed",
	"static/Mouse_Index/Mouse_Exons.bed",
	"static/Mouse_Index/Mouse_Introns.bed",
	"static/Mouse_Index/Mouse_3Prime_UTR.bed",
	"static/Mouse_Index/Mouse_2.5K_Downstream.bed",
	"static/Mouse_Index/Mouse_5K_Downstream.bed",
	"static/Mouse_Index/Mouse_10K_Downstream.bed",
	"static/Mouse_Index/Mouse_25K_Downstream.bed",
	"static/Mouse_Index/Mouse_50K_Downstream.bed",
	"static/Mouse_Index/Mouse_100K_Downstream.bed",
];

=head1 SUBROUTINES/METHODS

=head2 get_index

This method returns a previously defined array reference
of the locations of index files. get_index makes a call
to the private subroutine _can_open_files, which does
a check to ensure that the files can be opened by Perl.

=cut

sub get_index {
	my ($self, $index_species) = @_;
	if ( $index_species eq 'human' ) {
		return $self->_can_open_files($human_index);
	} elsif ( $index_species eq 'mouse' ) {
		return $self->_can_open_files($mouse_index);
	} else {
		croak "There was a problem in the get_index subroutine returning the proper index of genomic locations.";
	}
}

sub _can_open_files {
	my ($self, $index_files) = @_;
	foreach my $index_file (@$index_files) {
		croak "Could not read from required index file: $index_file" unless (-r $index_file);
	}
	return $index_files;
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
