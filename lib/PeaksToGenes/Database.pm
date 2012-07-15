package PeaksToGenes::Database 0.001;
use Moose::Role;
use PeaksToGenes::Schema;
use Carp;
use Data::Dumper;
use FindBin;

=head1 NAME

PeaksToGenes::Database

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This module provides an interface to the database containing the
annotated peaks.

=head1 SUBROUTINES/METHODS

=cut

sub _database_location {
	my $self = shift;
	my $db = "$FindBin::Bin/../db/peakstogenes.db";
	return $db;
}

sub insert_peaks {
	my ($self, $annotated_peaks, $species, $index_files, $table_name) = @_;
	my $db = $self->_database_location;
	my $schema = PeaksToGenes::Schema->connect("dbi:SQLite:$db");
	my $database_name = $self->return_database($species);
	my $array_table = $self->return_array($annotated_peaks, $index_files, $table_name);
	my $array_summary = $self->return_summary($array_table);
	my $header_line = $self->return_header_line($species);
	$schema->populate($database_name, [$header_line, @$array_table]);
	return ($array_table, $array_summary, $header_line);
}

sub return_contrast {
	my ($self, $contrast_file, $species, $table_name) = @_;
	my ($valid_accessions, $invalid_accessions, $contrast_summary);
	for (my $i = 0; $i < 15; $i++) {
		$contrast_summary->[$i] = 0;
	}
	my $db = $self->_database_location;
	my $schema = PeaksToGenes::Schema->connect("dbi:SQLite:$db");
	my $database_name = $self->return_database($species);
	print "\nTable name: $table_name\n\n";
	print "\nDatabase name: $database_name\n\n";
	my $result_set = $schema->resultset("$database_name")->search({ 'name'	=>	$table_name});
	while ( my $result_line = $result_set->next ) {
		$valid_accessions->{$result_line->gene} = 1;
	}
	open my($file), "<", $contrast_file or croak "\n\nCould not open file \"$contrast_file\". Please check to ensure that you have entered the correct path to your contrast file.\n\n";
	my $line = 1;
	while (<$file>) {
		my $accession = $_;
		my $accession_to_test;
		($accession =~ /(\w\w_\d+)/) ? $accession_to_test = $1 : croak "\n\nThe accession \"$accession\" on line $line of your file $contrast_file is not in the valid form of a RefSeq RNA accession\n\n";
		my $result_rows = $result_set->search({ 'gene'	=>	$accession_to_test});
		defined($valid_accessions->{$accession_to_test}) ? $contrast_summary = $self->extract_contrast_rows($result_rows, $species, $contrast_summary) : push(@$invalid_accessions, $line . "\t\t" . $accession_to_test);
		$line++;
	}
	if ( @$invalid_accessions ) {
		print "The following accessions in the file $contrast_file were not found in the $species database for the $table_name set of peaks:\n\n";
		print "\tLine Number\tAccession\n";
		print "\t", join("\n\t", @$invalid_accessions), "\n\n";
	}
	return ($contrast_summary);
}

sub extract_contrast_rows {
	my ($self, $result_rows, $species, $contrast_summary) = @_;
	if ( $species eq 'human' ) {
		while ( my $result_row = $result_rows->next ) {
			$contrast_summary->[0] += $result_row->human_100k_upstream_number_of_peaks;
			$contrast_summary->[1] += $result_row->human_50k_upstream_number_of_peaks;
			$contrast_summary->[2] += $result_row->human_25k_upstream_number_of_peaks;
			$contrast_summary->[3] += $result_row->human_10k_upstream_number_of_peaks;
			$contrast_summary->[4] += $result_row->human_5k_upstream_number_of_peaks;
			$contrast_summary->[5] += $result_row->human_promoters_number_of_peaks;
			$contrast_summary->[6] += $result_row->human_5prime_utr_number_of_peaks;
			$contrast_summary->[7] += $result_row->human_exons_number_of_peaks;
			$contrast_summary->[8] += $result_row->human_introns_number_of_peaks;
			$contrast_summary->[9] += $result_row->human_3prime_utr_number_of_peaks;
			$contrast_summary->[10] += $result_row->human_2_5k_downstream_number_of_peaks;
			$contrast_summary->[11] += $result_row->human_5k_downstream_number_of_peaks;
			$contrast_summary->[12] += $result_row->human_10k_downstream_number_of_peaks;
			$contrast_summary->[13] += $result_row->human_25k_downstream_number_of_peaks;
			$contrast_summary->[14] += $result_row->human_50k_downstream_number_of_peaks;
			$contrast_summary->[15] += $result_row->human_100k_downstream_number_of_peaks;
		}
	} elsif ($species eq 'mouse') {
		while ( my $result_row = $result_rows->next ) {
			$contrast_summary->[0] += $result_row->mouse_100k_upstream_number_of_peaks;
			$contrast_summary->[1] += $result_row->mouse_50k_upstream_number_of_peaks;
			$contrast_summary->[2] += $result_row->mouse_25k_upstream_number_of_peaks;
			$contrast_summary->[3] += $result_row->mouse_10k_upstream_number_of_peaks;
			$contrast_summary->[4] += $result_row->mouse_5k_upstream_number_of_peaks;
			$contrast_summary->[5] += $result_row->mouse_promoters_number_of_peaks;
			$contrast_summary->[6] += $result_row->mouse_5prime_utr_number_of_peaks;
			$contrast_summary->[7] += $result_row->mouse_exons_number_of_peaks;
			$contrast_summary->[8] += $result_row->mouse_introns_number_of_peaks;
			$contrast_summary->[9] += $result_row->mouse_3prime_utr_number_of_peaks;
			$contrast_summary->[10] += $result_row->mouse_2_5k_downstream_number_of_peaks;
			$contrast_summary->[11] += $result_row->mouse_5k_downstream_number_of_peaks;
			$contrast_summary->[12] += $result_row->mouse_10k_downstream_number_of_peaks;
			$contrast_summary->[13] += $result_row->mouse_25k_downstream_number_of_peaks;
			$contrast_summary->[14] += $result_row->mouse_50k_downstream_number_of_peaks;
			$contrast_summary->[15] += $result_row->mouse_100k_downstream_number_of_peaks;
		}
	} else {
		croak "\n\nThe species was not properly named.\n\n";
	}
	return $contrast_summary;
}

sub return_database {
	my ($self, $species) = @_;
	if ($species eq 'mouse') {
		return 'Mouseannotatedpeak';
	} elsif ( $species eq 'human') {
		return 'Humanannotatedpeak';
	} else {
		croak "There was a problem determining the table to utilize based on the species.";
	}
}

sub return_array {
	my ($self, $annotated_peaks, $index_files, $table_name) = @_;
	my $return_array;
	foreach my $gene ( keys %$annotated_peaks ) {
		my $gene_line;
		push (@$gene_line, $table_name, $gene);
		foreach my $index_file (@$index_files) {
			my $location;
			if ($index_file =~ /_Index\/(.+?)\.bed/ ) {
				$location = $1;
			}
			if ($location) {
				my $peak_number = $location . '_Number_of_Peaks';
				push (@$gene_line, $annotated_peaks->{$gene}{$peak_number});
			} else {
				croak "Unable to extract the location from the index file.";
			}
		}
		foreach my $index_file (@$index_files) {
			my $location;
			if ($index_file =~ /_Index\/(.+?)\.bed/ ) {
				$location = $1;
			}
			if ($location) {
				my $peak_info = $location . '_Peaks_Information';
				push (@$gene_line, $annotated_peaks->{$gene}{$peak_info});
			} else {
				croak "Unable to extract the location from the index file.";
			}
		}
		push (@$return_array, $gene_line);
	}
	return $return_array;
}

sub return_header_line {
	my ($self, $species) = @_;
	my $header_line;
	push (@$header_line, 'name', 'gene');
	my $sqlite_index = [
		'_100k_upstream_number_of_peaks',
		'_50k_upstream_number_of_peaks',
		'_25k_upstream_number_of_peaks',
		'_10k_upstream_number_of_peaks',
		'_5k_upstream_number_of_peaks',
		'_promoters_number_of_peaks',
		'_5prime_utr_number_of_peaks',
		'_exons_number_of_peaks',
		'_introns_number_of_peaks',
		'_3prime_utr_number_of_peaks',
		'_2_5k_downstream_number_of_peaks',
		'_5k_downstream_number_of_peaks',
		'_10k_downstream_number_of_peaks',
		'_25k_downstream_number_of_peaks',
		'_50k_downstream_number_of_peaks',
		'_100k_downstream_number_of_peaks',
		'_100k_upstream_peaks_information',
		'_50k_upstream_peaks_information',
		'_25k_upstream_peaks_information',
		'_10k_upstream_peaks_information',
		'_5k_upstream_peaks_information',
		'_promoters_peaks_information',
		'_5prime_utr_peaks_information',
		'_exons_peaks_information',
		'_introns_peaks_information',
		'_3prime_utr_peaks_information',
		'_2_5k_downstream_peaks_information',
		'_5k_downstream_peaks_information',
		'_10k_downstream_peaks_information',
		'_25k_downstream_peaks_information',
		'_50k_downstream_peaks_information',
		'_100k_downstream_peaks_information'
	];
	foreach my $location (@$sqlite_index) {
		push(@$header_line, '"' . $species . $location . '"');
	}
	return $header_line;
}

sub return_summary {
	my ($self, $array_table) = @_;
	my $return_summary_header = [
		'100Kb Upstream Peaks',
		'50Kb Upstream Peaks',
		'25Kb Upstream Peaks',
		'10Kb Upstream Peaks',
		'5Kb Upstream Peaks',
		'Promoter Peaks',
		'5\'-UTR Peaks',
		'Exon Peaks',
		'Intron Peaks',
		'3\'-UTR Peaks',
		'2.5Kb Downstream Peaks',
		'5Kb Downstream Peaks',
		'10Kb Downstream Peaks',
		'25Kb Downstream Peaks',
		'50Kb Downstream Peaks',
		'100Kb Downstream Peaks',
	];
	my $return_summary = [
		0, 0, 0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0, 0, 0,
	];
	foreach my $line (@$array_table) {
		for ( my $i = 2; $i < 18; $i++ ) {
			$return_summary->[($i-2)] += $line->[$i];
		}
	}
	my $return;
	push (@$return, $return_summary_header, $return_summary);
	return $return;
}

sub list_all_experiments {
	my $self = shift;
	my $db = $self->_database_location;
	my $schema = PeaksToGenes::Schema->connect("dbi:SQLite:$db");
	my $return;
	$return->{'human database'} = {};
	$return->{'mouse database'} = {};
	my $human_rs = $schema->resultset('Humanannotatedpeak')->search(
		{},
		{
			columns	=>	[ 'name' ],
			distinct	=>	1
		}
	);
	while (my $experiment = $human_rs->next) {
		$return->{'human database'}{$experiment->name} = 1;
	}
	my $mouse_rs = $schema->resultset('Mouseannotatedpeak')->search(
		{},
		{
			columns	=>	[ 'name' ],
			distinct	=>	1
		}
	);
	while (my $experiment = $mouse_rs->next) {
		$return->{'mouse database'}{$experiment->name} = 1;
	}
	return $return;
}

sub delete_peaks {
	my ($self, $name, $species) = @_;
	my $database = $self->return_database($species);
	my $db = $self->_database_location;
	my $schema = PeaksToGenes::Schema->connect("dbi:SQLite:$db");
	my $delete_rs = $schema->resultset($database)->search(
		{
			'name'	=>	$name
		}
	);
	$delete_rs->delete_all;
}

=head1 AUTHOR

Jason R. Dobson, C<< <dobson187 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-peakstogenes at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PeaksToGenes>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PeaksToGenes::Database


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

1; # End of PeaksToGenes::Database
