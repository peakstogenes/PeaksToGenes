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

1;

__END__
