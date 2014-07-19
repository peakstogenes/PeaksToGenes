#!/usr/bin/env perl 

# Copyright 2012, 2013 Jason R. Dobson <peakstogenes@gmail.com>
#
# This file is part of peaksToGenes.
#
# peaksToGenes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# peaksToGenes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use utf8;

# Pre-define an Array Ref of Perl modules to be installed by cpanminus
my $packages_to_install = [
	'Moose',
	'Moose::Util::TypeConstraints',
	'MooseX::Getopt',
	'Carp',
	'Data::Dumper',
	'FindBin',
	'File::Which',
	'DBI',
	'DBIx::Class::Schema',
	'DBIx::Class::Core',
	'DBD::SQLite',
	'DBD::mysql',
	'Parallel::ForkManager',
    'Math::BigFloat',
    'Math::GSL',
    'Sort::Rank',
	'Test::More',
];

# Install the packages using cpanminus
foreach my $package (@$packages_to_install) {
	`cpanm $package`;
}

use Test::More;

foreach my $package (@$packages_to_install) {
	require_ok($package);
}

done_testing();
