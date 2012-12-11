package PeaksToGenes::Matrix::Database 0.001;

use Moose;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

has genome_id	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide a genome ID number corresponding to the genome of interest.\n\n" },
);

has schema		=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide PeaksToGenes::Matrix::Database with a PeaksToGenes::Schema object to access the database.\n\n" },
);

has experiment_id_hash	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[Int]',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide a Hash Ref of experiment names as keys and experiment IDs as values.\n\n" },
);

has experiment_id_array	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[Str]',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide an Array Ref of experiment names in the order in which you would like them to appear in the matrix from left to right.\n\n" },
);

has transcript_id_hash	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[Str]',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide a Hash Ref of transcript IDs as keys and transcript accessions as values.\n\n" },
);

has position_limit	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
	lazy		=>	1,
	default		=>	sub { croak "\n\nYou must provide an integer value for the limits of the matrix.\n\n" },
);

sub extract_from_database {
	my $self = shift;

	# Pre-declare a Hash Ref to hold the number of reads / signal ratio per
	# relative genomic region for each experiment
	my $relative_regions_hash = {};

	# The structure of the relative_regions_hash is as follows:
	# The primary keys are the experiment names.
	# The secondary keys are the RefSeq accessions.
	# The tertiary keys are the relative locations
	# The values found defined by the key-series: experiment name =>
	# RefSeq accessions => relative genomic region => number of reads /
	# signal ratio

	# Pre-declare four Array Refs to hold the ordered locations for the gene
	# body as well as for the upstream and downstream relative locations
	# (restricted by the position_limit)
	my $all_ordered_locations = [];
	my $gene_body_locations = [];
	for ( my $i = 0; $i < 100; $i += 10 ) {
		push( @$gene_body_locations, "_gene_body_" . $i . "_to_" . ($i +
				10)
			. "_number_of_peaks"
		);
		push( @$all_ordered_locations, "_gene_body_" . $i . "_to_" . ($i +
				10)
			. "_number_of_peaks"
		);
	}
	my $upstream_locations = [];
	my $downstream_locations = [];
	croak "\n\nYou must define the limits of the matrix as greater than or equal to 1 (Kb) and less than or equal to 100 (Kb).\n\n" 
	unless ( $self->position_limit >= 1 && $self->position_limit <= 100 );
	for ( my $i = 1; $i <= $self->position_limit; $i++ ) {
		push(@$upstream_locations, '_' . $i .
			'kb_upstream_number_of_peaks');
		unshift(@$all_ordered_locations, '_' . $i .
			'kb_upstream_number_of_peaks');
		push(@$downstream_locations, '_' . $i .
			'kb_downstream_number_of_peaks');
		push(@$all_ordered_locations, '_' . $i .
			'kb_downstream_number_of_peaks');
	}

	# Define a Hash Ref of table names as keys and Array Refs of relative
	# locations (column names)
	my $table_name_hash = {
		'UpstreamNumberOfPeaks'		=>	$upstream_locations,
		'GeneBodyNumberOfPeaks'		=>	$gene_body_locations,
		'DownstreamNumberOfPeaks'	=>	$downstream_locations,
	};

	# Iterate through the experiments defined in the experiment_id_hash,
	# iterate through the relative locations, and extract the data for the
	# transcripts defined. All data will be stored in the
	# relative_regions_hash
	foreach my $experiment_name ( keys %{$self->experiment_id_hash} ) {

		foreach my $table_name ( keys %$table_name_hash ) {

			my $accession_data =
			$self->schema->resultset($table_name)->search(
				{
					genome_id	=>	$self->genome_id,
					name		=>
					$self->experiment_id_hash->{$experiment_name},
				}
			);

			# Inflate the DBIx::Class::ResultSet into a Hash Ref for speed
			$accession_data->result_class('DBIx::Class::ResultClass::HashRefInflator');

			# Iterate through the rows returned. If the row corresponding
			# to a defined accession is found, add the information to the
			# relative_regions_hash Hash Ref.
			while ( my $accesion_result = $accession_data->next ) {

				if ( $self->transcript_id_hash->{$accesion_result->{gene}}
					) {
					foreach my $column_name (
						@{$table_name_hash->{$table_name}} ) {

						# If there is a value associated with the relative
						# region for the given transcript, add it to the
						# relative_regions_hash Hash Ref, otherwise return
						# 0.
						if ( $accesion_result->{$column_name} ) {
							$relative_regions_hash->{$experiment_name}{$self->transcript_id_hash->{$accesion_result->{gene}}}{$column_name}
							= $accesion_result->{$column_name};
						} else {
							$relative_regions_hash->{$experiment_name}{$self->transcript_id_hash->{$accesion_result->{gene}}}{$column_name}
							= 0;
						}
					}
				}
			}
		}
	}

	# Reformat the relative_regions_hash Hash Ref into an Array Ref for
	# easy printing

	# Pre-declare an Array Ref to hold the matrix
	my $matrix_array_ref = [];

	# Pre-declare an Array ref to hold the header line for the
	# matrix_array_ref
	my $header_line = [];

	push(@$header_line, 'Accession');

	# Populate the rest of the header line
	foreach my $experiment_name ( @{$self->experiment_id_array} ) {
		foreach my $relative_location ( @$all_ordered_locations ) {
			push(@$header_line, $experiment_name . $relative_location);
		}
	}

	# Add the header line to the matrix_array_ref
	push(@$matrix_array_ref, join("\t", @$header_line));

	# Iterate through the accessions, the ordered experiment names in
	# experiment_id_array, then the ordered relative locations in
	# all_ordered_locations. Create an array ref for each "line", and then
	# add it to the matrix_array_ref
	foreach my $accession_id ( keys %{$self->transcript_id_hash} ) {

		# Pre-declare an Array Ref to hold the contents of the current line
		# associated with the transcript
		my $current_line = [];

		# Add the RefSeq accession to the current row
		push(@$current_line, $self->transcript_id_hash->{$accession_id});

		foreach my $experiment_name ( @{$self->experiment_id_array} ) {
			foreach my $relative_location ( @$all_ordered_locations ) {
				if
				($relative_regions_hash->{$experiment_name}{$self->transcript_id_hash->{$accession_id}}{$relative_location})
				{
					push(@$current_line,
						$relative_regions_hash->{$experiment_name}{$self->transcript_id_hash->{$accession_id}}{$relative_location}
					);
				} else {
					push(@$current_line, 0);
				}
			}
		}

		# Add the current line to the matrix_array_ref
		push(@$matrix_array_ref, join("\t", @$current_line));
	}

	return $matrix_array_ref;
}

1;
