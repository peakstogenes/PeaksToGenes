
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
package PeaksToGenes::Schema::Result::Experiment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::Experiment

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<experiments>

=cut

__PACKAGE__->table("experiments");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 genome_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 experiment

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "experiment",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<experiment_unique>

=over 4

=item * L</experiment>

=back

=cut

__PACKAGE__->add_unique_constraint("experiment_unique", ["experiment"]);

=head1 RELATIONS

=head2 downstream_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::DownstreamNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "downstream_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::DownstreamNumberOfPeaks",
  { "foreign.name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_body_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "gene_body_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks",
  { "foreign.name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 transcript_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::TranscriptNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "transcript_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::TranscriptNumberOfPeaks",
  { "foreign.name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 upstream_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "upstream_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks",
  { "foreign.name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-12-14 17:46:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SHTWE7pdr1QNTea650+GYw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
