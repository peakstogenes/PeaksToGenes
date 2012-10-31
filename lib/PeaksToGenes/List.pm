package PeaksToGenes::List 0.001;

use Moose;
use Carp;
use Data::Dumper;

has schema	=>	(
	is			=>	'ro',
	isa			=>	'PeaksToGenes::Schema',
	required	=>	1,
);

sub list_all_experiments {
	my $self = shift;

	#  Extract the experiment column from the experiments table of the
	#  PeaksToGenes database, and print the names for the user.

	if ( $self->schema->resultset('Experiment')->get_column('experiment') ) {
		my @experiments =
		$self->schema->resultset('Experiment')->get_column('experiment')->all;
		if ( @experiments >= 1 ) {
			print "\n\nThe following experiment names are found in the PeaksToGenes database:\n\t",
			join("\n\t", @experiments), "\n\n";
		} else {
			print "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
		}
	} else {
		croak "\n\nThere are no experiments annotated in your PeaksToGenes database\n\n";
	}
}

1;
