use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PeaksToGenes',
    AUTHOR              => q{Jason R. Dobson <dobson187@gmail.com>},
    VERSION_FROM        => 'lib/PeaksToGenes.pm',
    ABSTRACT			=> 'Meta-genomic analysis of ChIP-seq datasets',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
		'Moose'							=>	"2.0602",
		'Carp'							=>	"1.25",
		'Moose::Util::TypeConstraints'	=>	"2.0602",
		'Data::Dumper'					=>	"2.131",
		'MooseX::Getopt'				=>	"0.45",
		'Moose::Role'					=>	"2.0602",
		'DBIx::Class::Schema'			=>	0,
		'utf8'							=>	"1.09",
		'DBIx::Class::Core'				=>	0,
		'lib'							=>	"0.63",
		'DBI'							=>	"1.622",
		'DBD::SQLite'					=>	"1.37",
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PeaksToGenes-*' },
);
