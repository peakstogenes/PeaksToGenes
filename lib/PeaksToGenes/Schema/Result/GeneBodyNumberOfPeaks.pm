
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

use utf8;
package PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<gene_body_number_of_peaks>

=cut

__PACKAGE__->table("gene_body_number_of_peaks");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 genome_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gene

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 _gene_body_0_to_10_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_10_to_20_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_20_to_30_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_30_to_40_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_40_to_50_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_50_to_60_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_60_to_70_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_70_to_80_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_80_to_90_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _gene_body_90_to_100_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gene",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "_gene_body_0_to_10_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_10_to_20_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_20_to_30_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_30_to_40_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_40_to_50_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_50_to_60_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_60_to_70_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_70_to_80_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_80_to_90_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_gene_body_90_to_100_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 genome

Type: belongs_to

Related object: L<PeaksToGenes::Schema::Result::AvailableGenome>

=cut

__PACKAGE__->belongs_to(
  "genome",
  "PeaksToGenes::Schema::Result::AvailableGenome",
  { id => "genome_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 name

Type: belongs_to

Related object: L<PeaksToGenes::Schema::Result::Experiment>

=cut

__PACKAGE__->belongs_to(
  "name",
  "PeaksToGenes::Schema::Result::Experiment",
  { id => "name" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-05 21:56:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bng0vwMJO3lzx/7AOtc7eg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
