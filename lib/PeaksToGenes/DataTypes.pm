
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

package PeaksToGenes::DataTypes 0.001;

# Declare the custom types to be exported for use by other modules in the
# software suite.
use MooseX::Types -declare  =>  [
    qw(
    PositiveInt
    ReadableFile
    WriteableFile
    )
];

use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

# Import builtin types
use MooseX::Types::Moose qw(Int Str);

subtype PositiveInt,
    as Int,
    where { $_ > 0 },
    message { "$_ is not an integer larger than 0" };

subtype ReadableFile,
    as Str,
    where { -r $_ },
    message { "$_ is not a readable file" };

subtype WriteableFile,
    as Str,
    where { -w $_ },
    message {"$_ is not a writable file" };

1;
