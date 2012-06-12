package PeaksToGenes 0.001;
use Moose;
use Carp;
use Moose::Util::TypeConstraints;
use Data::Dumper;

with 'MooseX::Getopt', 'PeaksToGenes::FileStructure', 'PeaksToGenes::BedTools', 'PeaksToGenes::Database', 'PeaksToGenes::Out';

=head1 NAME

PeaksToGenes

=head1 VERSION

Version 0.001

=cut

=head1 SYNOPSIS

This is the base module for PeaksToGenes.

This module is not designed to be directly accessed by a Perl script,
but rather it should be accessed through the helper Perl script included
in this distribution utlizing command-line options.

=head1 SUBROUTINES/METHODS

=cut

subtype 'Valid_Mode',
	as 'Str',
	where {$_ eq 'annotate' || $_ eq 'contrast' || $_ eq 'list' || $_ eq 'delete'},
	message { "\n\nThe mode must be set to either \"annotate\", \"contrast\", \"list\" or \"delete\"\n\n"};

has mode	=>	 (
	is				=>	'ro',
	isa				=>	'Valid_Mode',
	required		=>	1,
	documentation	=>	"Mode to use PeaksToGenes in. Valid options: 'annotate' 'contrast' 'list' 'delete'",
	default			=>	sub {$_ ? lc($_) : croak "\n\nYou must define the mode to run PeaksToGenes in.\nPlease use peaksToGenes.pl --usage to view available options.\n\n"  },
);

subtype 'Valid_Species',
	as 'Str',
	where {$_ eq 'human' || $_ eq 'mouse' },
	message { "\n\nThe entered string: $_, must be either human or mouse.\n\n"};	

has species	=>	(
	is				=>	'rw',
	isa				=>	'Valid_Species',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Species to annotate peak summits with.",
	default			=>	sub { lc($_) },
);

subtype 'Valid_Summit_File',
	as 'Str',
	where { (-r $_) && ( sub { 
				my $file = $_; 
				open my($fh), "<", $file or croak "Could not open $file\n";
				while (<$file>) {
					my $line = $_;
					chomp($line);
					my ($chr, $start, $stop, $name, $rest_of_line) = split(/\t/, $line);
					unless ( ($chr =~ /^chr\d+/ ) &&
						($start =~ /^\d+$/) &&
						($stop =~ /^\d$/) &&
						( $name ) ) {
						return 0;
					}
				} 
				return 1; } ) },
		message { "\n\nYou must enter a valid bed file that does not have a header line and has the following four columns: \"Chromosome\", \"Start Position\", \"Stop Position\", and \"Peak Name\"\n\n" };

has summits	=>	(
	is				=>	'rw',
	isa				=>	'Valid_Summit_File',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Path to the summit file",
	default			=>	sub { croak "\n\nYou must provide a path to the summit file.\n\n"},
);

my $intersect_bed_executable = sub {
	my $self = shift;
	my $intersectbed = `which intersectBed`;
	chomp ($intersectbed);
	$intersectbed ne '' ? return $intersectbed : croak "\n\nIf your installation of BedTools is not in the \$PATH please provide the location with --executable [PATH_TO_intersectBed]\n\n";
};

subtype 'Valid_IntersectBed',
	as 'Str',
	where { ( -X $_ ) && ( $_ =~ /intersectBed$/ ) },
	message { "\n\nYou must provide a path to an executable intersectBed binary\n\n" };

has executable	=>	(
	is				=>	'rw',
	isa				=>	'Valid_IntersectBed',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Location of the intersectBed executable",
	default			=>	$intersect_bed_executable,
);

my $sqlite3_executeabe = sub {
	my $self = shift;
	my $sqlite3 = `which sqlite3`;
	chomp ($sqlite3);
	$sqlite3 ne '' ? return $sqlite3 : croak "\n\nYou must install SQLite3 into a system-wide path.\n\n";
};

subtype 'Valid_SQLite3',
	as 'Str',
	where { (-X $_) && ( $_ =~ /sqlite3$/ ) },
	message { "\n\nYou must have SQLite3 installed in a system-wide path\n\n" };

has 'SQLite3'	=>	(
	is				=>	'ro',
	isa				=>	'Valid_SQLite3',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The location of your installation of SQLite3.",
	default			=>	$sqlite3_executeabe,
);


has 'name'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The name of the experimental sample, must be unique",
	default			=>	sub { croak "\n\nYou must provide the unique name of the experimental sample.\n\n" },
);

subtype 'database_flag',
	as 'Int',
	where { $_ == 0 || $_ == 1 },
	message { "\n\nYou must enter a boolean flag, either 1 or 0 for the --create_database option\n\n" };

has 'create_database'	=>	(
	is				=>	'rw',
	isa				=>	'database_flag',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"A boolean flag to tell PeaksToGenes to insert into a database or not",
	default			=>	sub { croak "\n\nYou must enter a 1 or 0 for the --create_database flag.\nPlease note: creating a database will take significantly longer.\n\n"; },
);

has 'genes'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The list of genes to extract from the database",
	default			=>	sub { croak "\n\nYou must enter a file name to run in contrast mode\n\n" },
);

=head2 execute

This is the main subroutine that is executed. It makes calls to subclasses
to process the summits into their respective locations, and then store the
information in an SQLite3 database.


=cut

sub execute {
	my ($self) = shift;
	my $mode = $self->mode;
	if ( $mode eq 'annotate' ) {
		print "\n\nRunning in annotate mode...\n\n";
		my $intersectbed = $self->executable;
		my $species = $self->species;
		my $summits = $self->summits;
		my $table_name = $self->name;
		my $index_files = $self->get_index($species);
		my $create_database_flag = $self->create_database;
		print "\nPath to intersectBed executable:\t$intersectbed\n\n";
		$species = lc($species);
		print "User-defined species to annotate with:\t$species\n\n";
		print "User-defined summits file:\t\t$summits\n\n";
		print "User-defined name of the experiment:\t$table_name\n\n";
		print "Locations of index files being used to annotate summits:\n\n\t", join( "\n\t", @$index_files), "\n\n";
		my $annotated_peaks = $self->annotate_peaks($summits, $index_files);
		my ($peaks_to_genes_array, $peaks_to_genes_summary, $peaks_to_genes_header);
		if ($create_database_flag) {
			print "Now inserting the annotated peak information into the $species database.\n\n";
			($peaks_to_genes_array, $peaks_to_genes_summary, $peaks_to_genes_header) = $self->insert_peaks($annotated_peaks, $species, $index_files, $table_name);
			print "Your annotated peak information has been inserted into the database, and can be accessed with the unique experiment name of \"$table_name\".\n\n";
		} else {
			$peaks_to_genes_array = $self->return_array($annotated_peaks, $index_files, $table_name);
			$peaks_to_genes_summary = $self->return_summary($peaks_to_genes_array);
			$peaks_to_genes_header = $self->return_header_line($species);
		}
		print "Now writing the PeaksToGenes table to file\n\n";
		$self->print_peaks_to_genes_file($peaks_to_genes_array, $peaks_to_genes_header, $table_name);
		print "Now writing the PeaksToGenes summary to file\n\n";
		$self->print_summary_file($peaks_to_genes_summary, $table_name);
		print "Operation completed!\n";
	} elsif ( $mode eq 'contrast' ) {
		print "\n\nRunning in contrast mode...\n\n";
		my $species = $self->species;
		my $table_name = $self->name;
		my $contrast_file = $self->genes;
		my ($contrast_summary) = $self->return_contrast($contrast_file, $species, $table_name);
		print "Now writing the contrast summary table to file\n\n";
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
		my $out_file = $table_name . '_Contrast_Genes_From_' . $contrast_file;
		open my($out_fh), ">>", $out_file or croak "Could not write to $out_file\n";
		print $out_fh join("\t", @$return_summary_header), "\n";
		print $out_fh join("\t", @$contrast_summary);
		print "Operation completed!\n";
	} elsif ( $mode eq 'list' ) {
		print "\n\nRunning in list mode...\n\n";
		my $tables = $self->list_all_experiments();
		print "The annotated peaks from the following experiments are stored in the Human database:\n\n";
		foreach my $experiment ( keys %{$tables->{'human database'}} ) {
			print "\t$experiment\n";
		}
		print "\n";
		print "The annotated peaks from the following experiments are stored in the Mouse database:\n\n";
		foreach my $experiment ( keys %{$tables->{'mouse database'}} ) {
			print "\t$experiment\n";
		}
		print "\n";
	} elsif ( $mode eq 'delete' ) {
		print "\n\nRunning in delete mode...\n\n";
		my $name = $self->name;
		my $species = $self->species;
		print "Name of the experimental peaks to delete from the $species database:\n\n\t$name\n\n";
		my $tables = $self->list_all_experiments();
		if ( defined ( $tables->{$species . ' database'}{$name} ) ) {
			print "Deleting $name from $species database..\n\n";
			$self->delete_peaks($name, $species);
			print "Operation completed\n\n";
		} else {
			print "The experiment \"$name\" was not found in the $species database.\nPlease recheck that your peaks are stored in the database.\n\nHint: peaksToGenes.pl --mode list\n\n";
		}
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

    perldoc PeaksToGenes


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

__PACKAGE__->meta->make_immutable;

1; # End of PeaksToGenes
