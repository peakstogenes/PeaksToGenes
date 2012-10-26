package PeaksToGenes::Contrast::GenomicRegions 0.001;

use Moose;
use Carp;
use PeaksToGenes::Annotate::FileStructure;
use Parallel::ForkManager;
use Data::Dumper;

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

has test_genes	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[Int]',
	required	=>	1,
);

has background_genes	=>	(
	is					=>	'ro',
	isa					=>	'ArrayRef[Int]',
	required			=>	1,
);

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has table_dispatch	=>	(
	is			=>	'ro',
	isa			=>	'HashRef[HashRef[Str]]',
	required	=>	1,
	init_arg	=>	undef,
	default		=>	sub {
		my $self = shift;
		my $table_dispatch = {
			'_5prime_utr'	=>	{
				'peaks_information'	=>	'TranscriptAnnotation',
				'number_of_peaks'	=>	'TranscriptNumberOfPeaks',
			},
			'_3prime_utr'	=>	{
				'peaks_information'	=>	'TranscriptAnnotation',
				'number_of_peaks'	=>	'TranscriptNumberOfPeaks',
			},
			'_exons'	=>	{
				'peaks_information'	=>	'TranscriptAnnotation',
				'number_of_peaks'	=>	'TranscriptNumberOfPeaks',
			},
			'_introns'	=>	{
				'peaks_information'	=>	'TranscriptAnnotation',
				'number_of_peaks'	=>	'TranscriptNumberOfPeaks',
			},
		};
		for (my $i = 1; $i <= 100; $i++) {
			$table_dispatch->{'_' . $i . 'kb_upstream'} = {
				'peaks_information'	=>	'UpstreamAnnotation',
				'number_of_peaks'	=>	'UpstreamNumberOfPeaks',
			};
			$table_dispatch->{'_' . $i . 'kb_downstream'} = {
				'peaks_information'	=>	'DownstreamAnnotation',
				'number_of_peaks'	=>	'DownstreamNumberOfPeaks',
			};
		}
		for (my $i = 0; $i < 100; $i +=10) {
			$table_dispatch->{'_gene_body_' . $i . '_to_' . ($i+10)} = {
				'peaks_information'	=>	'GeneBodyAnnotation',
				'number_of_peaks'	=>	'GeneBodyNumberOfPeaks',
			}
		}
		return $table_dispatch;
	},
);

has base_regex	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
	default		=>	sub {
		my $self = shift;
		# Create a regular expression string to be used to match the
		# location of each index file.
		my $base_regex = "\.\.\/" . $self->genome . "_Index\/" .
		$self->genome;
		return $base_regex;
	}
);

has genome	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	default		=>	1,
);

sub extract_genomic_regions {
	my $self = shift;


	# Create a Hash Ref of Hash Refs of Hash Refs of Array Refs to hold the
	# information extracted from the tables by calling
	# PeaksToGenes::Contrast::GenomicRegions::create_blank_index.
	my $genomic_regions_structure = $self->create_blank_index;

	# Run the PeaksToGenes::Contrast::GenomicRegions::get_peaks
	# subroutine to return an Array Ref of peaks per Kb per genomic region
	$genomic_regions_structure =
	$self->get_peaks($genomic_regions_structure);

	return $genomic_regions_structure;

}

sub get_chunks {
	my ($self, $chunk_number, $array) = @_;
	my $return_array_ref = [];
	my $i = 1;
	my $current_array_ref = [];
	for my $value (@$array) {
		if ($i % $chunk_number) {
			push(@$current_array_ref, $value);
		} else {
			push(@$return_array_ref, $current_array_ref);
			$current_array_ref = [];
			push(@$current_array_ref, $value);
		}
		$i++;
	}
	push(@$return_array_ref, $current_array_ref);
	return $return_array_ref;
}

sub create_blank_index {
	my $self = shift;

	# The index will be defined as a follows:
	# 	Primary Hash Refs:
	#
	# 		Test Genes
	# 		Background Genes
	#
	# 		Secondary Hash Refs:
	#
	# 			Genomic Regions
	#
	# 			Tertiary Hash Refs:
	#
	# 				Peak Numbers
	# 				Peak Scores
	#
	# 				Array Refs of Numbers/Scores
	my $genomic_regions_structure = {
		'test_genes'			=>	{},
		'background_genes'		=>	{},
	};

	# Pre-declare the structure for the upstream and downstream genomic
	# regions
	foreach my $gene_type (keys %$genomic_regions_structure) {
		for (my $i = 1; $i <= 100; $i++) {
			$genomic_regions_structure->{$gene_type}{'_' . $i .
			'kb_downstream'}{'number_of_peaks'} = [];
			$genomic_regions_structure->{$gene_type}{'_' . $i .
			'kb_downstream'}{'peaks_information'} = [];
			$genomic_regions_structure->{$gene_type}{'_' . $i .
			'kb_upstream'}{'number_of_peaks'} = [];
			$genomic_regions_structure->{$gene_type}{'_' . $i .
			'kb_upstream'}{'peaks_information'} = [];
		}
		# Pre-declare the structure for the gene body decile regions
		for (my $i = 0; $i < 100; $i +=10) {
			$genomic_regions_structure->{$gene_type}{'_gene_body_' . $i .
			'_to_' . ($i+10)}{'number_of_peaks'} = [];
			$genomic_regions_structure->{$gene_type}{'_gene_body_' . $i .
			'_to_' . ($i+10)}{'peaks_information'} = [];
		}
		# Pre-declare the structure for the transcript regions
		foreach my $location (qw( _5prime_utr _exons _introns _3prime_utr )) {
			$genomic_regions_structure->{$gene_type}{$location}{'peaks_information'}
			= [];
			$genomic_regions_structure->{$gene_type}{$location}{'number_of_peaks'}
			= [];
		}
	}
	return $genomic_regions_structure;
}

sub get_peaks {
	my ($self, $genomic_regions_structure) = @_;

	# Get the experiment ID from the Experiment result set
	my $experiment_id = $self->schema->resultset('Experiment')->find(
		{
			experiment	=>	$self->name
		}
	)->id;

	# Pre-declare a Hash Ref to hold the result sets for each table
	my $hash_ref_of_result_sets = {};

	# Make an initial pass through the structure and extract result sets
	# for the experiment for each table in a hash
	foreach my $location (keys
		%{$genomic_regions_structure->{test_genes}}) {
		foreach my $table_type (keys
			%{$genomic_regions_structure->{test_genes}{$location}}) {
			my $table =
			$self->table_dispatch->{$location}{$table_type};

			# Fetch the entire result set matching for the table and store
			# it in the Hash Ref
			$hash_ref_of_result_sets->{$location}{$table_type} =
				$self->schema->resultset($table)->search(
					{
						name	=>	$experiment_id
					}
			);

		}
	}

	# Create an instance of Parallel::ForkManager with the number of
	# threads allowed set to the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be run at the end of each thread
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$genomic_regions_structure->{$data_structure->{'gene_type'}}{$data_structure->{'location'}}{$data_structure->{'table_type'}}
			= $data_structure->{'data'};
		}
	);


	# Iterate through the structure, and extract the information from the
	# tables
	foreach my $location (keys
		%{$genomic_regions_structure->{test_genes}}) {
		foreach my $table_type (keys
			%{$genomic_regions_structure->{test_genes}{$location}}) {

			my $column_accessor = $location . '_' . $table_type;
			my $table =
			$self->table_dispatch->{$location}{$table_type};

			# Iterate through the gene types 
			foreach my $gene_type ( qw( test_genes background_genes ) ) {

				# If there are threads available, start a new one
				$pm->start and next;

				# Create a local Array Ref to store the data values
				# temporarily
				my $data_array = [];

				foreach my $gene_id_chunk (@{$self->get_chunks(900,
					$self->$gene_type)}) {

					# Extract the data from the result set corresponding to
					# the genes of interest
					my $result_data =
					$hash_ref_of_result_sets->{$location}{$table_type}->search(
						{
							gene	=>	$gene_id_chunk
						}
					);

					my @result_column =
					$result_data->get_column($column_accessor)->all;

					if ( $table_type eq 'number_of_peaks' ) {
						foreach my $result (@result_column) {
							push(@$data_array, $result) 
								if (
									$result && $result =~ /\d/
								);
						}
					} else {
						foreach my $result (@result_column) {
							push(@$data_array,
								@{$self->parse_peaks_information($result)}) if
							$result;
						}
					}

#					while (my $result_row = $result_data->next) {
#						if ( $result_row->$column_accessor ) {
#							if ($table_type eq 'number_of_peaks') {
#								push
#								(@$data_array,
#									$result_row->$column_accessor
#								) if ( $result_row->$column_accessor =~
#									/\d/);
#							} else {
#								# Call the parse_peaks_information
#								# subroutine to extract the peak score from
#								# the string
#								push
#								(@$data_array,
#									@{$self->parse_peaks_information($result_row->$column_accessor)}
#								);
#							}
#						}
#					}
				}

				# Fill the array with zeros in for genes, which do not
				# have a peak in the current position
				for (my $i = @$data_array;
					$i < @{$self->$gene_type}; $i++) {
					push
					(@$data_array,
						0
					);
				}
				$pm->finish(0,
					{
						gene_type	=>	$gene_type,
						location	=>	$location,
						table_type	=>	$table_type,
						data		=>	$data_array,
					}
				);
			}
		}
	}

	$pm->wait_all_children;

	return $genomic_regions_structure;
}

sub parse_peaks_information {
	my ($self, $string) = @_;

	# Pre-declare an Array Ref to hold the scores to return
	my $scores = [];

	# Remove the leading and trailing ' /// ' field delimiters
	$string =~ s/^\s\/\/\/\s//;
	$string =~ s/\s\/\/\/\s$//;

	# If there is more than one annotation left, split the fields by the
	# delimiter
	if ( $string =~ /\s\/\/\/\s/ ) {
		my @string_fields = split(/\s\/\/\/\s/, $string);
		foreach my $string_field (@string_fields) {
			if ( $string_field && $string_field =~ /:/ ) {
				my ($chr, $start, $stop, $name, $score) = split(/:/,
					$string_field);
				push(@$scores, $score) if ($score =~ /\d/);
			}
		}
	} else {
		if ( $string && $string =~ /\d/ ) {
			my ($chr, $start, $stop, $name, $score) = split(/:/, $string);
			push(@$scores, $score) if ($score =~ /\d/);
		}
	}
	return $scores;
}

sub get_ordered_index {
	my $self = shift;

	# Create an instance of PeaksToGenes::Annotate::FileStructure in order
	# to use the
	# PeaksToGenes::Annotate::FileStructure::get_index_file_names
	# subroutine to return an Array Ref of file names. These file names
	# will be used to produce the column names of the structures for the
	# statistics results
	my $file_structure = PeaksToGenes::Annotate::FileStructure->new(
		schema	=>	$self->schema,
		genome	=>	$self->genome,
	);
	my $available_genome_search_result = $file_structure->test_genome;
	my $genomic_index =
	$file_structure->get_index_file_names(
		$available_genome_search_result);

	# Use the PeakToGenes::Contrast::GenomicRegions::parse_file_strings
	# subroutine to extract the locations from the file strings
	my $genomic_locations = $self->parse_file_strings($genomic_index);

	return $genomic_locations;

}

sub parse_file_strings {
	my ($self, $genomic_index) = @_;

	# Pre-define an Array Ref to store the parse locations
	my $genomic_locations = [];

	# Copy the base regular expression into a scalar
	my $base_regex = $self->base_regex;

	# Iterate through the file string, extracting the base and adding it to
	# the Array Ref of genomic locations
	foreach my $index_file (@$genomic_index) {
		if ($index_file =~ qr/($base_regex)(.+?)\.bed$/ ) {
			push(@$genomic_locations, $2);
		} else {
			croak "There was a problem using regular expressions to extract the location from the file $index_file\n\n";
		}
	}

	return $genomic_locations;

}

1;

__END__
