package PeaksToGenes 0.001;
use Moose;
use Carp;
use Moose::Util::TypeConstraints;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Schema;
use PeaksToGenes::FileStructure;
use PeaksToGenes::BedTools;
use PeaksToGenes::Out;
use PeaksToGenes::Update;
use PeaksToGenes::Update::UCSC;
use PeaksToGenes::Contrast;
use Data::Dumper;

with 'MooseX::Getopt';

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
	where {$_ eq 'annotate' || $_ eq 'contrast' || $_ eq 'list' || $_ eq 'delete' || $_ eq 'update'},
	message { "\n\nThe mode must be set to either \"annotate\", \"contrast\", \"list\" or \"delete\"\n\n"};

has mode	=>	 (
	is				=>	'ro',
	isa				=>	'Valid_Mode',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Mode to use PeaksToGenes in. Valid options: 'annotate' 'contrast' 'list' 'delete' 'update'",
	default			=>	sub {$_ ? lc($_) : croak "\n\nYou must define the mode to run PeaksToGenes in.\nPlease use peaksToGenes.pl --usage to view available options.\n\n"  },
);

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	default		=>	sub {
		my $self = shift;
		my $dsn = "dbi:SQLite:$FindBin::Bin/../db/peakstogenes.db";
		my $schema = PeaksToGenes::Schema->connect($dsn);
		return $schema;
	},
	required	=>	1,
);

has genome	=>	(
	is				=>	'rw',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Genome to annotate peak summits with.",
	default			=>	sub { croak "\n\nYou must provide a genome to annoate the summit file with.\n\n"},
);

has summits	=>	(
	is				=>	'rw',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Path to the summit file",
	default			=>	sub { croak "\n\nYou must provide a path to the summit file.\n\n"},
);

has _intersect_bed_executable	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	documentation	=>	"Location of the intersectBed executable",
	default			=>	sub {
		my $self = shift;
		my $intersect_bed_path = `which intersectBed`;
		chomp($intersect_bed_path);
		if ($intersect_bed_path !~ /intersectBed$/) {
			croak "\n\nPlease make sure that you have installed BedTools, and that it is installed in your \$PATH\n\n";
		} else {
			return $intersect_bed_path;
		}
	},
);

has '_sqlite3_executable'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	documentation	=>	"The location of your installation of SQLite3.",
	default			=>	sub {
		my $self = shift;
		my $sqlite3_path = `which sqlite3`;
		chomp ($sqlite3_path);
		if ($sqlite3_path =~ /sqlite$/) {
			croak "\n\nPlease make sure that you have installed SQLite3, and that is is installed in your \$PATH\n\n";
		}
		return $sqlite3_path;
	},
);

has 'name'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The name of the experimental sample, must be unique",
	default			=>	sub { croak "\n\nYou must provide the unique name of the experimental sample.\n\n" },
);

has 'create_database'	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	"A boolean flag to tell PeaksToGenes to insert into a database or not",
);

has 'genes'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The file path to the list of RefSeq accessions (genes) you wish to extract from the database",
	default			=>	sub { croak "\n\nYou must enter a file name to run in contrast mode\n\n" },
);

has 'contrast_name'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The name of the contrast you are performing.",
	default			=>	sub { croak "\n\nYou must enter a contrast name to run in contrast mode\n\n" },
);

=head2 execute

This is the main subroutine that is executed. It makes calls to subclasses
to process the summits into their respective locations, and then store the
information in an SQLite3 database.


=cut

sub execute {
	my $self = shift;
	$self->mode;
	# Create an instance of PeaksToGenes::Update::UCSC to make sure that
	# the user-defined genome can be used
	my $ucsc = PeaksToGenes::Update::UCSC->new(
		genome	=>	$self->genome,
	);
	unless ( $ucsc->genome_info->{$self->genome} ) {
		croak "\n\nThe user defined genome: ", $self->genome, " is not annotated by RefSeq, please choose another genome\n\n";
	}
	# Based on the mode determined by the user, execute the appropriate series of actions
	# to validate user-input and execute the desired functions
	if ( $self->mode eq 'annotate' ) {
		print "\n\nRunning in annotate mode...\n\n";
		print "Path to intersectBed executable:\t", $self->_intersect_bed_executable, "\n\n";
		print "Path to SQLite3 executable:\t\t", $self->_sqlite3_executable, "\n\n";
		print "User-defined genome to annotate with:\t", $self->genome, "\n\n";
		print "User-defined name of the experiment:\t", $self->name, "\n\n";
		print "User-defined summits file:\t\t", $self->summits, "\n\n";
		# Create an instance of PeaksToGenes::FileStructure to check if the user-defined genome
		# exists. If it does, return a HashRef of information that includes the genome base-name,
		# the genome_id for the many-to-many table relationships, and an ArrayRef of files used 
		# to annotate the genome.
		my $file_structure_test = PeaksToGenes::FileStructure->new(
			schema	=>	$self->schema,
			genome	=>	$self->genome,
			name	=>	$self->name,
		);
		my $genome_information = $file_structure_test->test_and_extract;
		# Create an instance of PeaksToGenes::BedTools
		my $bedtools = PeaksToGenes::BedTools->new(
			genome		=>	$self->genome,
			schema		=>	$self->schema,
			summits		=>	$self->summits,
			index_files	=>	$genome_information,
		);
		# Use the PeaksToGenes::BedTools check_bed_file subroutine to ensure
		# that the user-defined BED file is valid for the genome defined
		$bedtools->check_bed_file;
		# Use the annotate_peaks subroutine to determine the locations of user-defined
		# genomic intervals relative to gene bodies
		my $indexed_peaks = $bedtools->annotate_peaks;
		# Create an instance of PeaksToGenes::Out
		my $out = PeaksToGenes::Out->new(
			indexed_peaks	=>	$indexed_peaks,
			schema			=>	$self->schema,
			name			=>	$self->name,
			ordered_index	=>	$genome_information,
			genome			=>	$self->genome,
		);
		$out->summary_and_out;
		if ( $self->create_database ) {
			$out->insert_peaks;
		}
		print "Operation completed!\n";
	} elsif ( $self->mode eq 'contrast' ) {
		print "\n\nRunning in contrast mode...\n\n";
		# Create an instance of PeaksToGenes::Contrast
		my $contrast = PeaksToGenes::Contrast->new(
			genome			=>	$self->genome,
			schema			=>	$self->schema,
			name			=>	$self->name,
			genes			=>	$self->genes,
			contrast_name	=>	$self->contrast_name,
		);
		# Using PeaksToGenes::Contrast, determine if
		# the name of the user-defined experiment has
		# been indexed in the PeaksToGenes database. Then
		# extract the RefSeq accessions to make sure that
		# each one exists in the database. If there are any
		# errors in either of the first two parameters,
		# throw an error and return it to the user. Once
		# the input has been tested, determine the aggregate
		# number of peaks per relative genomic region based
		# on the user-defined list of accessions.
		my $invalid_accessions = $contrast->test_and_contrast;
		if ( $invalid_accessions ) {
			print "The following accessions were not found in the ", $self->name, " table:\n\n\t", join("\n\t", @$invalid_accessions), "\n\n";
		}
		print "Operation completed!\n";
	} elsif ( $self->mode eq 'list' ) {
		print "\n\nRunning in list mode...\n\n";
	} elsif ( $self->mode eq 'delete' ) {
		print "\n\nRunning in delete mode...\n\n";
	} elsif ( $self->mode eq 'update' ) {
		print "\n\nRunning in update mode...\n\n";
		print "Path to SQLite3 executable:\t\t", $self->_sqlite3_executable, "\n\n";
		print "User-defined genome to annotate with:\t", $self->genome, "\n\n";
		# Create an instance of PeaksToGenes::Update
		my $update = PeaksToGenes::Update->new(
			schema	=>	$self->schema,
			genome	=>	$self->genome,
		);
		# Execute the update functions
		$update->update;
		print "Operation completed successfully!\n";
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
