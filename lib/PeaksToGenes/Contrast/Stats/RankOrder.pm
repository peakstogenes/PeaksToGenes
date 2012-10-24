package PeaksToGenes::Contrast::Stats::RankOrder 0.001;

use Moose;
use Carp;
use Parallel::ForkManager;

has genomic_regions_structure	=>	(
	is			=>	'ro',
	isa			=>	'HashRef',
	required	=>	1,
);

has processors	=>	(
	is			=>	'ro',
	isa			=>	'Int',
	required	=>	1,
);

sub rank_order_genomic_regions {
	my $self = shift;

	# Pre-declare a Hash Ref to store the rank ordered arrays
	my $rank_ordered_genomic_regions = {};

	# Create a new instance of Parallel::ForkManager allowing the number of
	# threads utilized to be the number of processors the user has defined
	my $pm = new Parallel::ForkManager($self->processors);

	# Define a subroutine that will be run when each fork terminates so
	# that the ordered arrays are properly stored in the
	# rank_order_genomic_regions Hash Ref
	$pm->run_on_finish(
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump,
				$data_structure) = @_;
			$rank_ordered_genomic_regions->{$data_structure->{'genomic_region'}}{$data_structure->{'data_type'}}
			= $data_structure->{'rank_array'};
		}
	);

	# Iterate through the genomic_regions_structure, for each region and
	# type, create a rank sum array
	foreach my $genomic_region (keys
		%{$self->genomic_regions_structure->{'test_genes'}} ) {

		foreach my $type ( keys
			%{$self->genomic_regions_structure->{'test_genes'}{$genomic_region}}
			) {

			# Start a new thread if available
			$pm->start and next;

			# Send the arrays for the test_genes and background_genes to
			# the
			# PeaksToGenes::Contrast::Stats::RankOrder::get_ranked_array
			# subroutine, which will return an Array Ref containing the
			# ranked values
			my $ranked_array = $self->get_ranked_array(
				$self->genomic_regions_structure->{'test_genes'}{$genomic_region}{$type},
				$self->genomic_regions_structure->{'background_genes'}{$genomic_region}{$type}
			);

			$pm->finish(0, 
				{
					'genomic_region'	=>	$genomic_region,
					'data_type'			=>	$type,
					'rank_array'		=>	$ranked_array
				}
			);

		}
	}

	$pm->wait_all_children;

	return $rank_ordered_genomic_regions;
}

sub get_ranked_array {
	my ($self, $test_array, $background_array) = @_;


	# Make sure the values in each array are numerical and store them in a
	# array of Hash Refs where the name key is either 'test' or 'background'
	my $unranked_array = [];

	$unranked_array = $self->extract_array($test_array, $unranked_array, 'test');
	$unranked_array = $self->extract_array($background_array, $unranked_array, 'background');	
	my $extract = sub {
		my $item = shift;
		return $item->{score};
	};

	my $position = 1;

	my @temp_array = sort {

		# Sort on score then on the originally defined position
		$a->[0] <=> $b->[0] || $a->[1] <=> $b->[1]
	} map {
		# Create an array of score, original position and peak value/score
		[ $extract->( $_ ), $position++, $_ ]
	} @$unranked_array;

	# Assign ranks to the array
	my $ranked_array = [];
	for my $i ( 0 .. $#temp_array ) {
		if ( $i == 0 || $temp_array[$i]->[0] != $temp_array[($i - 1)]->[0]
			) {
			push(@$ranked_array, [$i + 1]);
		}

		push(@{ $ranked_array->[-1] }, $temp_array[$i]->[2]);
	}

	# Unwrap the groups
	my $rank_ordered_array = [];
	for my $group (@$ranked_array) {
		my $rank = shift @$group;
		my $many = ( @$group > 1 ) ? '=' : '';
		for my $number ( @$group ) {
			push (@$rank_ordered_array, [ $rank, $many, $number ]);
		}
	}

	return $rank_ordered_array;
}

sub extract_array {
	my ($self, $array, $unranked_array, $key) = @_;

	# Extract the numerical values from the array and store them in the
	# hash by their key value

	foreach my $value (@$array) {
		push(@$unranked_array, {score => $value, name => $key});
	}

	return $unranked_array;
}

1;
