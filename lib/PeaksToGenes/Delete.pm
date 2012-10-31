package PeaksToGenes::Delete 0.001;

use Moose;
use Carp;
use Data::Dumper;

has name	=>	(
	is			=>	'ro',
	isa			=>	'Str',
	required	=>	1,
);

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

sub seek_and_destroy {
	my $self = shift;

	# Create an experiment results set searching for the user-defined
	# experiment name
	my $experiment_result_set =
	$self->schema->resultset('Experiment')->find(
		{
			experiment	=>	$self->name,
		}
	);

	if ( $experiment_result_set ) {

		print "\n\nDeleting the ", $self->name, " data.\n\n";

		# Loop through the tables, and delete the rows where the data
		# corresponds to the table
		foreach my $table (qw(UpstreamAnnotation UpstreamNumberOfPeaks
			TranscriptAnnotation TranscriptNumberOfPeaks
			GeneBodyAnnotation GeneBodyNumberOfPeaks
			DownstreamAnnotation DownstreamNumberOfPeaks) ) {
			my $result_set = $self->schema->resultset($table)->search(
				{
					name	=>	$experiment_result_set->id
				}
			)->delete;
		}
		$experiment_result_set->delete;
	} else {
		croak "\n\nCould not find the experiment defined: " . $self->name .
		". Please check that you have entered the correct name.\n\n";
	}
}

1;
