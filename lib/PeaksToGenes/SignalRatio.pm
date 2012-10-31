package PeaksToGenes::SignalRatio 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Annotate::FileStructure;
use PeaksToGenes::Annotate::BedTools;
use PeaksToGenes::SignalRatio::BedTools;
use Data::Dumper;

has ip_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has input_file	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has scaling_factor	=>	(
	is			=>	'ro',
	isa			=>	'Num',
	required	=>	1,
);

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

sub index_signal_ratio {
	my $self = shift;

	# Run the PeaksToGenes::SignalRatio::get_genomic_index subroutine to
	# get an Array Ref of genomic index files
	my $genomic_index = $self->get_genomic_index;

	# Run the PeaksToGenes::SignalRatio::check_files subroutine to be sure
	# that each user-defined BED-format file of reads is valid
	$self->check_files;

	# Run the PeaksToGenes::SignalRatio::merge_files subroutine to merge
	# the overlapping reads and return the string where the temporary files
	# have been written
	my ($merged_ip_file, $merged_input_file) = $self->merge_files;

	# Create an instance of PeaksToGenes::SignalRatio::BedTools and run
	# PeaksToGenes::SignalRatio::BedTools::annotate_signal_ratio to return
	# a Hash Ref of genomic signal ratio data
	my $bedtools = PeaksToGenes::SignalRatio::BedTools->new(
		input_file		=>	$merged_ip_file,
		ip_file			=>	$merged_input_file,
		genome			=>	$self->genome,
		genomic_index	=>	$genomic_index,
		scaling_factor	=>	$self->scaling_factor,
		processors		=>	$self->processors,
	);

	my $indexed_signal_ratios = $bedtools->annotate_signal_ratio;

	unlink ($merged_ip_file);
	unlink ($merged_input_file);

	# Create an instance of PeaksToGenes::Annotate::Database and run the
	# PeaksToGenes::Annotate::Database::parse_and_store subroutine to
	# insert the information into the PeaksToGenes database
	my $database = PeaksToGenes::Annotate::Database->new(
		schema			=>	$self->schema,
		indexed_peaks	=>	$indexed_signal_ratios,
		name			=>	$self->name,
		ordered_index	=>	$genomic_index,
		genome			=>	$self->genome,
		processors		=>	$self->processors,
	);
	$database->parse_and_store;

}

sub get_genomic_index {
	my $self = shift;

	# Create an instance of PeaksToGenes::Annotate::FileStructure and run
	# the PeaksToGenes::Annotate::FileStructure::Test_and_extract
	# subroutine to return an ordered Array Ref of index files
	# corresponding to the user-defined genome.
	my $genomic_index_fetcher = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$self->schema,
		genome	=>	$self->genome,
		name	=>	$self->name,
	);

	my $genomic_index = $genomic_index_fetcher->test_and_extract;

	return $genomic_index;
}

sub check_files {
	my $self = shift;

	# Create an instance of PeaksToGenes::Annotate::BedTools and use the
	# PeaksToGenes::Annotate::BedTools::check_bed_file for both the IP and
	# Input files to make sure that the files are correctly formatted
	my $ip_bed_checker = PeaksToGenes::Annotate::BedTools->new(
		schema		=>	$self->schema,
		genome		=>	$self->genome,
		bed_file	=>	$self->ip_file,
	);

	$ip_bed_checker->check_bed_file;

	my $input_bed_checker = PeaksToGenes::Annotate::BedTools->new(
		schema		=>	$self->schema,
		genome		=>	$self->genome,
		bed_file	=>	$self->input_file,
	);

	$input_bed_checker->check_bed_file;

}

sub merge_files {
	my $self = shift;

	# Create a temporary file to store the merged BED-format files
	my $merged_ip_file = "$FindBin::Bin/../" . $self->name .
	'_merged_ip_file.bed';

	my $merged_input_file = "$FindBin::Bin/../" . $self->name .
	'_merged_input_file.bed';

	# Copy the input and IP files into strings
	my $unmerged_ip_file = $self->ip_file;
	my $unmerged_input_file = $self->input_file;

	# Run mergeBed to merge the overlapping read intervals and add the
	# scores together
	`mergeBed -scores sum -i $unmerged_ip_file > $merged_ip_file`;
	`mergeBed -scores sum -i $unmerged_input_file > $merged_input_file`;

	return ($merged_ip_file, $merged_input_file);
}

1;
