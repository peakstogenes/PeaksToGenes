package PeaksToGenes::Out 0.001;
use Moose::Role;
use Carp;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Out

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

Given either the summary array, or the entire PeaksToGenes array,
this module will print each array to a tab-delimited text file.

=head1 SUBROUTINES/METHODS

=cut

sub print_summary_file {
	my ($self, $summary_file, $table_name) = @_;
	my $out_file = $table_name . '_Peaks_To_Genes_Summary.txt';
	open my($out_fh), ">>", $out_file or croak "Could not write to $out_file $!\n";
	foreach my $line (@$summary_file) {
		print $out_fh join("\t", @$line), "\n";
	}
}

sub print_peaks_to_genes_file {
	my ($self, $peaks_to_genes_array, $peaks_to_genes_header, $table_name) = @_;
	my $out_file = $table_name . '_Peaks_To_Genes_Table.txt';
	open my($out_fh), ">>", $out_file or croak "Could not write to $out_file $!\n";
	print $out_fh join("\t", @$peaks_to_genes_header), "\n";
	foreach my $line (@$peaks_to_genes_array) {
		print $out_fh join("\t", @$line), "\n";
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
