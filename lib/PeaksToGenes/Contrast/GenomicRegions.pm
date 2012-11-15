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

	# Convert the lists of test genes and background genes into Hash Refs
	my $test_ids = $self->array_to_hash($self->test_genes);
	my $background_ids = $self->array_to_hash($self->background_genes);

	# Run the PeaksToGenes::Contrast::GenomicRegions::all_regions
	# subroutine to return Hash Refs of all genomic regions information for
	# the given data set
	my $genomic_regions_all_data =
	$self->all_regions($genomic_regions_structure);

	# Run the PeaksToGenes::Contrast::GenomicRegions::get_peaks
	# subroutine to return an Array Ref of peaks per Kb per genomic region
	$genomic_regions_structure =
	$self->get_peaks($genomic_regions_structure, $genomic_regions_all_data,
		$test_ids, $background_ids);

	return $genomic_regions_structure;

}

sub array_to_hash {
	my ($self, $array) = @_;

	# Pre-declare a Hash Ref to hold the ids
	my $hash = {};

	# Iterate through the array, storing the ids in the Hash Ref
	foreach my $id (@$array) {
		$hash->{$id} = 1;
	}

	return $hash;
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

sub all_regions {
	my ($self, $genomic_regions_structure) = @_;

	# Get the experiment id
	my $experiment_id = $self->schema->resultset('Experiment')->find(
		{
			experiment	=>	$self->name
		}
	)->id;

	if ( ! $experiment_id ) {
		croak "The experiment name " . $self->name . " was not found in "
		. "the PeaksToGenes database\n\n" unless ( $experiment_id == 0 );
	}

	# Pre-declare a Hash Ref to hold the genomic regions data
	my $genomic_regions_all_data = {};

	foreach my $location ( keys
		%{$genomic_regions_structure->{test_genes}}) {

		foreach my $table_type ( keys
			%{$genomic_regions_structure->{test_genes}{$location}}) {

			# Get the table name from the table dispatch
			my $table = $self->table_dispatch->{$location}{$table_type};

			# Get the result set from the PeaksToGenes database
			# corresponding to the current location and user-defined
			# experiment
			my $current_location_result_set =
			$self->schema->resultset($table)->search(
				{
					name	=>	$experiment_id
				}
			);

			$current_location_result_set->result_class('DBIx::Class::ResultClass::HashRefInflator');

			$genomic_regions_all_data->{$location}{$table_type} =
			$current_location_result_set;

		}

	}

	return $genomic_regions_all_data;
}

sub get_peaks {
	my ($self, $genomic_regions_structure, $genomic_regions_all_data,
		$test_ids, $background_ids) = @_;

	# Create an instance of Parallel::ForkManager with the number of
	# threads allowed set to the number of processors defined by the user
	my $pm = Parallel::ForkManager->new($self->processors);

	# Define a subroutine to be run at the end of each thread
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$genomic_regions_structure->{test_genes}{$data_structure->{'location'}}{$data_structure->{'table_type'}}
			= $data_structure->{'test_genes_data'};
			$genomic_regions_structure->{background_genes}{$data_structure->{'location'}}{$data_structure->{'table_type'}}
			= $data_structure->{'background_genes_data'};
		}
	);

	foreach my $location ( keys %$genomic_regions_all_data ) {
		foreach  my $table_type ( keys
			%{$genomic_regions_all_data->{$location}} ) {

			# Start a new thread if one is available
			$pm->start and next;

			# Pre-declare Array Refs for the test genes and background
			# genes respectively
			my $test_data = [];
			my $background_data = [];

			my $column = $location . "_" . $table_type;

			while ( my $location_result =
				$genomic_regions_all_data->{$location}{$table_type}->next)
			{
				if (  $test_ids->{$location_result->{gene}} ) {
					if ( $table_type eq 'number_of_peaks' ) {
						if ( $location_result->{$column} ) {
							push(@$test_data, $location_result->{$column});
						} else {
							push(@$test_data, 0);
						}
					} elsif ( $table_type eq 'peaks_information' ) {
						if ( $location_result->{$column} ) {
							push(@$test_data,
								@{$self->parse_peaks_information($location_result->{$column})});
						} else {
							push(@$test_data, 0);
						}
					}
				} elsif ( $background_ids->{$location_result->{gene}} ) {
					if ( $table_type eq 'number_of_peaks' ) {
						if ( $location_result->{$column} ) {
							push(@$background_data, $location_result->{$column});
						} else {
							push(@$background_data, 0);
						}
					} elsif ( $table_type eq 'peaks_information' ) {
						if ( $location_result->{$column} ) {
							push(@$background_data,
								@{$self->parse_peaks_information($location_result->{$column})});
						} else {
							push(@$background_data, 0);
						}
					}
				}
			}

			# Fill the test and background gene lists with zeros for the
			# genes that are not found in the PeaksToGenes database
			for (my $i = @$test_data; $i < @{$self->test_genes}; $i++) {
				push(@$test_data, 0);
			}
			for (my $i = @$background_data; $i <
				@{$self->background_genes}; $i++) {
				push(@$background_data, 0);
			}

			$pm->finish(0,
				{
					table_type				=>	$table_type,
					location				=>	$location,
					test_genes_data			=>	$test_data,
					background_genes_data	=>	$background_data,
				}
			);
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
