package PeaksToGenes::Contrast::GenomicRegions 0.001;

use Moose;
use Carp;
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

has test_genes_chunks	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[ArrayRef[Int]]',
	required	=>	1,
	init_arg	=>	undef,
	default		=>	sub {
		my $self = shift;
		return $self->get_chunks(500, $self->test_genes);
	},
);

has background_genes	=>	(
	is					=>	'ro',
	isa					=>	'ArrayRef[Int]',
	required			=>	1,
);

has background_genes_chunks	=>	(
	is			=>	'ro',
	isa			=>	'ArrayRef[ArrayRef[Int]]',
	required	=>	1,
	init_arg	=>	undef,
	default		=>	sub {
		my $self = shift;
		return $self->get_chunks(500, $self->background_genes);
	},
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

	# Iterate through the structure, and extract the information from the
	# tables
	foreach my $gene_type (keys %$genomic_regions_structure) {
#		print join("\n", @{$self->$gene_type}), "\n";
		foreach my $location (keys
			%{$genomic_regions_structure->{$gene_type}}) {
			foreach my $table_type (keys
				%{$genomic_regions_structure->{$gene_type}{$location}}) {
				my $column_accessor = $location . '_' . $table_type;
				my $table =
				$self->table_dispatch->{$location}{$table_type};
				my $chunk_type = $gene_type . '_chunks';
				foreach my $gene_id_chunk (@{$self->$chunk_type}) {
					my $result_data =
					$self->schema->resultset($table)->search_rs(
						{
							gene	=>	$gene_id_chunk,
						}
					);
					while (my $result_row = $result_data->next) {
						if ( $result_row->$column_accessor ) {
							if ($table_type eq 'number_of_peaks') {
								push
								(@{$genomic_regions_structure->{$gene_type}{$location}{$table_type}},
									$result_row->$column_accessor
								);
							} elsif ( $table_type eq 'peaks_information' )
							{
								# Call the parse_peaks_information
								# subroutine to extract the peak score from
								# the string
								push
								(@{$genomic_regions_structure->{$gene_type}{$location}{$table_type}},
									@{$self->parse_peaks_information($result_row->$column_accessor)}
								);
							}
						}
					}
				}
				# Fill the array with zeros in for genes, which do not
				# have a peak in the current position
				for (my $i =
					@{$genomic_regions_structure->{$gene_type}{$location}{$table_type}};
					$i < @{$self->$gene_type}; $i++) {
					push
					(@{$genomic_regions_structure->{$gene_type}{$location}{$table_type}},
						0
					);
				}
			}
		}
	}
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
			my ($chr, $start, $stop, $name, $score) = split(/:/,
				$string_field);
			push(@$scores, $score);
		}
	} else {
		my ($chr, $start, $stop, $name, $score) = split(/:/, $string);
		push(@$scores, $score);
	}
	return $scores;
}

1;

__END__
