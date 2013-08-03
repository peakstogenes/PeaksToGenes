
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
# along with peaksToGenes.  If not, see <http://www.gnu.org/licenses/>

package PeaksToGenes::Database 0.001;

use Moose::Role;
use Carp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use PeaksToGenes::Schema;
use Data::Dumper;

=head1 NAME

PeaksToGenes::Database

=head1 AUTHOR

Jason R. Dobson, peakstogenes@gmail.com

=head1 DESCRIPTION

This Moose role is designed to export the methods to access the PeaksToGenes
database through a DBIx::Class object.

=head1 SYNOPSIS

with 'PeaksToGenesDatabase';

$self->schema->....

=cut

=head2 schema

This Moose attribute holds the DBI connection to the PeaksToGenes database.

=cut

has schema	=>	(
    is			=>	'ro',
    isa			=>	'PeaksToGenes::Schema',
    writer		=>	'_set_schema',
    predicate   =>  'has_schema',
);

before  'schema'    =>  sub {
    my $self = shift;
    unless ($self->has_schema) {
        $self->_set_schema($self->_define_schema);
    }
};

sub _define_schema  {
    my $self = shift;
    my $dsn = "dbi:SQLite:$FindBin::Bin/../db/peakstogenes.db";
    my $schema = PeaksToGenes::Schema->connect($dsn, '', '', {
            cascade_delete	=>	1
        }
    );
    return $schema;
}

1;
