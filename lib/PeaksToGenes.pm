package PeaksToGenes 0.001;
use Moose;
use Carp;
use Moose::Util::TypeConstraints;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Schema;
use PeaksToGenes::Annotate;
use PeaksToGenes::Update;
use PeaksToGenes::Contrast;
use PeaksToGenes::SignalRatio;
use PeaksToGenes::Delete;
use PeaksToGenes::List;
use PeaksToGenes::Matrix;
use File::Which;
use Data::Dumper;

# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.

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

has annotate	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to annotate a dataset and store the results in the PeaksToGenes database',
);

has update	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to install the genomic coordinates for a RefSeq genome',
);

has list	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to print out a list of the experimnetal names of datasets annotated in your installation of PeaksToGenes',
);

has delete	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to delete a dataset from the PeaksToGenes database',
);

has contrast	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to run PeaksToGenes in contrast mode',
);

has signal_ratio	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set the mode to annoate a pair of IP and Input BED-format reads',
);

has matrix			=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Set this mode to export a tab-delimited file of peaks/signal ratios for a set of experiments and relative regions for all defined transcripts',
);

has ip_file	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	documentation	=>	'Signal Ratio mode only. The path to the BED-format file of IP reads',
	required		=>	1,
	lazy			=>	1,
	default			=>	sub {
		croak "\n\nTo run in signal_ratio mode, you must provide the path to the BED-format IP file.\n\n";
	},
);

has input_file	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	documentation	=>	'Signal Ratio mode only. The path to the BED-format file of Input reads',
	required		=>	1,
	lazy			=>	1,
	default			=>	sub {
		croak "\n\nTo run in signal_ratio mode, you must provide the path to the BED-format Input file.\n\n";
	},
);

has scaling_factor	=>	(
	is				=>	'ro',
	isa				=>	'Num',
	default			=>	1,
	documentation	=>	'Signal Ratio mode only. An optional factor, which is used to scale the number of Input reads. The product of the number of input reads and the scaling factor is used as the denominator when calculating the ratio of IP reads. Default: 1.',
);

has anova	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Contrast Mode only. Set this mode to run the ANOVA test in contrast mode',
);

has kruskal_wallis	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Contrast Mode only. Set this mode to run the Kruskal-Wallis nonparametric ANOVA test in contrast mode',
);

has wilcoxon	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Contrast Mode only. Set this mode to run the Wilcoxon (Mann-Whitney) nonparametric ANOVA test in contrast mode',
);

has biserial	=>	(
	is				=>	'ro',
	isa				=>	'Bool',
	documentation	=>	'Contrast Mode only. Set this mode to calculate the point biserial correlation coefficient in contrast mode',
);

has _schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	default		=>	sub {
		my $self = shift;
		my $dsn = "dbi:SQLite:$FindBin::Bin/../db/peakstogenes.db";
		my $schema = PeaksToGenes::Schema->connect($dsn, '', '', {
				cascade_delete	=>	1});
		return $schema;
	},
	required	=>	1,
	reader		=>	'schema',
);

has genome	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The RefSeq genome string corresponding to the data you are working with (hg19, mm9, dm3, etc.)",
	default			=>	sub { croak "\n\nYou must provide the genome corresponding to your experiment.\n\n"},
);

has bed_file	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Annotation Mode only. Path to the BED-format file for annotation",
	default			=>	sub { croak "\n\nYou must provide a path to the BED-format file.\n\n"},
);

has 'name'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"The name of the experimental sample. Must be unique when running in Annotation Mode.",
	default			=>	sub { croak "\n\nYou must provide the name of the experimental sample.\n\n" },
);

has 'matrix_names'	=>	(
	is				=>	'ro',
	isa				=>	'ArrayRef[Str]',
	documentation	=>	'The names of the experimental samples you wish to combine into a matrix file',
	required		=>	1,
	lazy			=>	1,
	default			=>	sub {[]},
);

has 'test_genes'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Contrast Mode only. The file path to the list of RefSeq accessions (genes) you wish to extract from the database as a test set",
	default			=>	sub { croak "\n\nYou must enter a file name for the Test Genes to run in contrast mode\n\n" },
);

has 'background_genes'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	documentation	=>	" Contrast Mode only. (Optional) The file path to the list of RefSeq accessions (genes) you wish to extract from the database as the background set. By defualt, the inverse (rest of the genome) from the list of test genes will be used as the background unless this flag is set",
);

has gene_list		=>	(
	is				=>	'ro',
	isa				=>	'Str',
	documentation	=>	'Matrix mode only. (Optional) The file path to the list of RefSeq accessions (genes) you wish to use to build the matrix file. Default: all genes in RefSeq genome.',
	default			=>	'',
);

has position_limit	=>	(
	is				=>	'ro',
	isa				=>	'Int',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	'Matrix mode only. (Optional) The integer value for the limits (in Kb) to be used upstream and downstream from the TSS and TSS respectively when making the matrix file. Default: 10',
	default			=>	10,
);

has 'contrast_name'	=>	(
	is				=>	'ro',
	isa				=>	'Str',
	required		=>	1,
	lazy			=>	1,
	documentation	=>	"Contrast Mode only. The name of the contrast you are performing.",
	default			=>	sub { croak "\n\nYou must enter a contrast name to run in contrast mode\n\n" },
);

has processors		=>	(
	is				=>	'ro',
	isa				=>	'Int',
	default			=>	1,
	documentation	=>	"The number of processors you would like to run PeaksToGenes with",
);

=head2 execute

This is the main subroutine that is executed. It makes calls to subclasses
to process the summits into their respective locations, and then store the
information in an SQLite3 database.


=cut

sub execute {
	my $self = shift;

	# Run PeaksToGenes::_check_executables to be sure that the required
	# external dependencies can be found and run by PeaksToGenes
	$self->_check_executables;

	# Determine the how the program will be run
	if ( $self->_check_modes > 1 ) {

		# The user has defined more than one mode, so exit.
		croak "\n\nYou can only specify one mode to run in at a time. Please run peaksToGenes.pl --help to see usage\n\n";

	} elsif ( $self->list ) {

		# Run in list mode

		# Create an instance of PeaksToGenes::List and run the
		# PeaksToGenes::List::list_all_experiments subroutine to list all
		# the experiments in the PeaksToGenes database
		my $list = PeaksToGenes::List->new(
			schema	=>	$self->schema
		);

		$list->list_all_experiments;
	} elsif ( $self->delete ) {

		# Run in delete mode

		# Create an instance of PeaksToGenes::Delete and run the
		# PeaksToGenes::Delete::seek_and_destroy subroutine to delete the
		# dataset from the PeaksToGenes database
		my $delete = PeaksToGenes::Delete->new(
			schema	=>	$self->schema,
			name	=>	$self->name,
		);

		$delete->seek_and_destroy;
	} elsif ( $self->update ) {

		# Run in update mode

		# Create an instance of PeaksToGenes::Update and run the
		# PeaksToGenes::Update::update subroutine to fetch, create, and
		# install the required files for PeaksToGenes
		my $update = PeaksToGenes::Update->new(
			schema		=>	$self->schema,
			genome		=>	$self->genome,
			processors	=>	$self->processors,
		);

		$update->update;

	} elsif ( $self->annotate ) {

		# Run in annotate mode

		# Create an instance of PeaksToGenes::Annotate and run
		# PeaksToGenes::Annotate::annotate to create a meta-gene profile of
		# the dataset and insert this profile into the PeaksToGenes
		# database
		my $annotate = PeaksToGenes::Annotate->new(
			schema		=>	$self->schema,
			genome		=>	$self->genome,
			name		=>	$self->name,
			bed_file	=>	$self->bed_file,
			processors	=>	$self->processors,
		);

		$annotate->annotate;

	} elsif ( $self->contrast ) {

		# Run in contrast mode

		print "\n\nRunning in contrast mode...\n\n";

		# Create an instance of PeaksToGenes::Contrast and run the
		# PeaksToGenes::Contrast::test_and_contrast subroutine
		if ( $self->background_genes ) {
			my $contrast = PeaksToGenes::Contrast->new(
				schema				=>	$self->schema,
				genome				=>	$self->genome,
				name				=>	$self->name,
				test_genes_fh		=>	$self->test_genes,
				background_genes_fh	=>	$self->background_genes,
				contrast_name		=>	$self->contrast_name,
				processors			=>	$self->processors,
				statistical_tests	=>	{
					anova			=>	$self->anova,
					wilcoxon		=>	$self->wilcoxon,
					kruskal_wallis	=>	$self->kruskal_wallis,
					point_biserial	=>	$self->biserial
				}
			);

			$contrast->test_and_contrast;
		} else {
			my $contrast = PeaksToGenes::Contrast->new(
				schema				=>	$self->schema,
				genome				=>	$self->genome,
				name				=>	$self->name,
				test_genes_fh		=>	$self->test_genes,
				contrast_name		=>	$self->contrast_name,
				processors			=>	$self->processors,
				statistical_tests	=>	{
					anova			=>	$self->anova,
					wilcoxon		=>	$self->wilcoxon,
					kruskal_wallis	=>	$self->kruskal_wallis,
					point_biserial	=>	$self->biserial
				}
			);

			$contrast->test_and_contrast;
		}
	} elsif ( $self->signal_ratio ) {

		# Run in signal_ratio mode

		# Create an instance of PeaksToGenes::SignalRatio and run the
		# PeaksToGenes::SignalRatio::create_bed_file subroutine to check
		# the user-defined BED-format files, and then calculate the ratio
		# of IP reads to Input reads. The ratios will be reported in
		# BED-format.
		my $signal_ratio = PeaksToGenes::SignalRatio->new(
			ip_file			=>	$self->ip_file,
			input_file		=>	$self->input_file,
			scaling_factor	=>	$self->scaling_factor,
			schema			=>	$self->schema,
			name			=>	$self->name,
			genome			=>	$self->genome,
			processors		=>	$self->processors,
		);

		$signal_ratio->index_signal_ratio;

	} elsif ( $self->matrix ) { 

		# Run in matrix mode
		
		# Create an instance of PeaksToGenes::Matrix and run the
		# PeaksToGenes::Matrix::create_matrix subroutine to extract the
		# information for each dataset, and print the information to a
		# tab-delimited file
		my $matrix = PeaksToGenes::Matrix->new(
			matrix_names	=>	$self->matrix_names,
			schema			=>	$self->schema,
			genome			=>	$self->genome,
			gene_list		=>	$self->gene_list,
			position_limit	=>	$self->position_limit,
		);

		$matrix->create_matrix;
	} else {
		croak "\n\nYou must set a mode to run PeaksToGenes in. Use peakToGenes.pl --help for more information\n\n";
	}
}

sub _check_executables {
	my $self = shift;

	# Check to make sure that MySQL, SQLite and intersectBed are installed
	# and are found in the $PATH. If they are not, kill the program and
	# inform the user.
	my $intersectbed_path = which('intersectBed');
	croak 'BedTools is either not installed, or is not found in the $PATH' 
		unless ( -X -x $intersectbed_path );
	my $sqlite_path = which('sqlite3');
	croak 'SQLite3 is either not installed or is not found in the $PATH'
		unless (-X -x $sqlite_path);
	my $mysql_path = which('mysql');
	croak 'MySQL is either not installed or is not found in the $PATH'
		unless (-X -x $mysql_path);
}

sub _check_modes {
	my $self = shift;

	# Count the number of modes the user has defined and return an integer
	# for the number of modes defined

	# Pre-define an integer value for the number of modes defined
	my $bool_test = 0;

	if ( $self->delete ) {
		$bool_test++;
	}
	if ( $self->list ) {
		$bool_test++;
	}
	if ( $self->annotate ) {
		$bool_test++;
	}
	if ( $self->update ) {
		$bool_test++;
	}
	if ( $self->contrast ) {
		$bool_test++;
	}
	if ( $self->signal_ratio ) {
		$bool_test++;
	}
	if ( $self->matrix ) {
		$bool_test++;
	}

	return $bool_test;
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
