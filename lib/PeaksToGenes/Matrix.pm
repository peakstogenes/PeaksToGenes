package PeaksToGenes::Matrix 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Matrix::Database;
use Data::Dumper;

has matrix_names	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[Str]',
	required	=>	1,
);

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

has gene_list	=>	(
	is			=>	'ro',
	isa			=>	'Str',
);

has position_limit	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	10,
);

sub create_matrix {
	my $self = shift;

	# Run PeaksToGenes::Matrix::get_genome_id to fetch the genome ID from
	# the PeaksToGenes database and to ensure that the genome entered is
	# valid
	my $genome_id = $self->get_genome_id;

	# Run PeaksToGenes::Matrix::get_experiment_ids to fetch the experiment
	# IDs for the user-defined experiment names
	my $experiment_ids_hash = $self->get_experiment_ids($genome_id);

	# Run PeaksToGenes::Matrix::get_transcript_ids to extract the
	# transcript IDs for the transcripts defined by the user or all the
	# transcripts in the genome by default.
	my $transcript_ids_hash = $self->get_transcript_ids($genome_id);

	# Create an instance of PeaksToGenes::Matrix::Database and run
	# PeaksToGenes::Matrix::Database::extract_from_database to return an
	# Array Ref matrix of peaks/signal ratios per relative genomic region
	# for each experiment defined for each accession
	my $database = PeaksToGenes::Matrix::Database->new(
		genome_id			=>	$genome_id,
		schema				=>	$self->schema,
		experiment_id_hash	=>	$experiment_ids_hash,
		experiment_id_array	=>	$self->matrix_names,
		transcript_id_hash	=>	$transcript_ids_hash,
		position_limit		=>	$self->position_limit,
	);
	
	my $matrix_array_ref = $database->extract_from_database;

	# Print the matrix_array_ref to file
	my $matrix_fh = join("_", @{$self->matrix_names}, 'matrix_file') . '.txt';
	open my $matrix_file, ">", $matrix_fh or croak 
	"\n\nCould not print to $matrix_fh. Please check that this is a valid file name and that you have permission to write to the current directory.\n\n";
	print $matrix_file join("\n", @$matrix_array_ref);
	close $matrix_file;
}

sub get_genome_id {
	my $self = shift;

	my $genome_id_search =
	$self->schema->resultset('AvailableGenome')->find(
		{
			genome	=>	$self->genome
		}
	);
	if ( $genome_id_search && $genome_id_search->id ) {
		return $genome_id_search->id;
	} else {
		croak "\n\nThe genome entered: " . $self->genome 
		. " is not found in the PeaksToGenes database. " .
		"Please check that you have entered the genome correctly\n\n";
	}
}

sub get_experiment_ids {
	my ($self, $genome_id) = @_;

	# Pre-declare a Hash Ref to hold the experiment names and experiment
	# IDs
	my $experiment_ids_hash = {};

	# Make sure that there is at least one experiment name defined in the
	# matrix_names Array Ref
	if ( ! @{$self->matrix_names} ) {
		croak "\n\nYou must define at least one experiment name as '--matrix_names [name]'\n\n";
	} else {

		# Iterate through the experiment names defined in matrix_names, and
		# extract the experiment ID for each one. If the experiment name
		# defined is not found, exit the program and inform the user.
		foreach my $experiment_name (@{$self->matrix_names}) {

			my $experiment_id_search =
			$self->schema->resultset('Experiment')->find(
				{
					genome_id	=>	$genome_id,
					experiment	=>	$experiment_name,
				}
			);

			if ( $experiment_id_search && $experiment_id_search->id ) {
				$experiment_ids_hash->{$experiment_name} =
				$experiment_id_search->id;
			} else {
				croak "\n\nThe experiment name: $experiment_name could not be found annotated for the genome you have defined. Please run peaksToGenes.pl --list to see the experiments which have been annotated, and ensure that you have chosen to appropriate genome.\n\n";
			}
		}
	}

	return $experiment_ids_hash;
}

sub get_transcript_ids {
	my ($self, $genome_id) = @_;

	# Pre-declare a Hash Ref to hold the RefSeq accessions and their
	# PeaksToGenes transcript IDs
	my $transcript_ids_hash = {};

	# If the user has defined a file of RefSeq accessions to be used to
	# build the matrix, use these accessions to extract the transcript IDs
	# from the PeaksToGenes database
	if ( $self->gene_list ) {

		# Define a line number to be returned to the user if the accession
		# defined on a given line is not found in the genome defined
		my $line_number = 1;

		# Open the file defined by the user, iterate through the lines,
		# extracting the transcript ID for each accession in the file.
		# Cease execution if the accession is not valid.
		open my $refseq_file, "<", $self->gene_list or croak "\n\nCould " .
		"not open " . $self->gene_list . ". Please check that the file you"
		. " have entered is correct, and that you have permission to read "
		. "it\n\n";
		while (<$refseq_file>) {
			my $accession = $_;
			chomp($accession);

			my $transcript_id_result =
			$self->schema->resultset('Transcript')->find(
				{
					genome_id	=>	$genome_id,
					transcript	=>	$accession
				}
			);

			if ( $transcript_id_result && $transcript_id_result->id ) {
				$transcript_ids_hash->{$transcript_id_result->id} =
				$accession;
			} else {
				# Print the accessions to STDOUT
				print "\t$accession\n";
			}

			$line_number++;
		}
		close $refseq_file;
	} else {

		# Otherwise, extract the transcript IDs for all genes in the given
		# RefSeq genome.
		my $current_genome_transcripts =
		$self->schema->resultset('Transcript')->search(
			{
				genome_id	=>	$genome_id
			}
		);

		while ( my $current_genome_transcript =
			$current_genome_transcripts->next ) {
			$transcript_ids_hash->{$current_genome_transcript->id}
			= $current_genome_transcript->transcript;
		}
	}

	return $transcript_ids_hash;
}

1;
