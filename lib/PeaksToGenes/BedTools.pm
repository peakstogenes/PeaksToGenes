package PeaksToGenes::BedTools 0.001;
use Moose::Role;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::BedTools

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module provides most of the business logic for the PeaksToGenes
program. Given a bed file of peak summits, and a list of index files,
this module will annotate the locations of the summits relative to
the transcriptional start site of each transcript.

=head1 SUBROUTINES/METHODS

=head2 annotate_peaks

This subroutine is passed the file name of a bed file of summits,
and array reference of index files and makes backticks calls to the
executable intersectBed utility from the BedTools suite of programs.
annotate peaks returns an array reference of hash references for each
transcript.

=cut

sub annotate_peaks {
	my ($self, $summits_file, $index_files) = @_;
	my $return;
	my $indexed_peaks = $self->_create_blank_index($index_files);
	print "Now aligning your peaks to:\n\n";
	foreach my $index_file (@$index_files) {
		my $location;
		if ($index_file =~ /_Index\/(.+?)\.bed$/ ) {
			$location = $1;
		}
		if ($location) {
			print "\t$location\n";
			my $peak_number = $location . '_Number_of_Peaks';
			my $peak_info = $location . '_Peaks_Information';
			my @intersected_peaks = `intersectBed -wb -a $summits_file -b $index_file`;
			foreach my $intersected_peak (@intersected_peaks) {
				chomp ($intersected_peak);
				my ($summit_chr, $summit_start, $summit_end, $summit_name, $summit_score,
					$index_chr, $index_start, $index_stop, $index_name, $index_score,
					$index_strand) = split(/\t/, $intersected_peak);
				my $index_gene;
				if ($index_name =~ /^(\w\w_\d+?)_/) {
					$index_gene = $1;
				}
				if ( $index_gene ) {
					$indexed_peaks->{$index_gene}{$peak_number}++;
					$indexed_peaks->{$index_gene}{$peak_info} .= ' /// ' . join(":", $summit_chr, $summit_start, $summit_start, $summit_name) . ' /// ';
				} else {
					croak "Could not extract a RefSeq accession from $index_name.";
				}
			}
		} else {
			croak "There was a problem determining the location of the index file relative to transcription start site";
		}
	}
	print "\n";
	return $indexed_peaks;
}

sub _create_blank_index {
	my ($self, $index_files) = @_;
	my $indexed_peaks;
	my $genes;
	foreach my $index_file (@$index_files) {
		if ($index_file =~ /Promoters/) {
			open my($promoters), "<", $index_file or croak "Could not open $index_file $! \n";
			while (<$promoters>) {
				my $line = $_;
				chomp ($line);
				my ($chr, $start, $stop, $name, $rest_of_line) = split(/\t/, $line);
				if ( $name =~ /^(\w\w_\d+?)_/ ) {
					push (@$genes, $1);
				}
			}
		}
	}
	foreach my $index_file (@$index_files) {
		foreach my $gene (@$genes) {
			my $index_base;
			if ($index_file =~ /.+?\/.+?_Index\/(.+?)\.bed$/ ) {
				$index_base = $1;
			}
			my $peak_numbers = $index_base . '_Number_of_Peaks';
			$indexed_peaks->{$gene}{$peak_numbers} = 0;
			my $peak_info = $index_base . '_Peaks_Information';
			$indexed_peaks->{$gene}{$peak_info} = '';
		}
	}
	return $indexed_peaks;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::BedTools


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

1; # End of PeaksToGenes::BedTools
