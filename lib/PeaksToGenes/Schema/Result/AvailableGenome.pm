
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
package PeaksToGenes::Schema::Result::AvailableGenome;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::AvailableGenome

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<available_genomes>

=cut

__PACKAGE__->table("available_genomes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 genome

  data_type: 'text'
  is_nullable: 0

=head2 _10kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _9kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _8kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _7kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _6kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _4kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _3kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _2kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _1kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5prime_utr_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _exons_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _introns_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _3prime_utr_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_0_to_10_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_10_to_20_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_20_to_30_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_30_to_40_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_40_to_50_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_50_to_60_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_60_to_70_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_70_to_80_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_80_to_90_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_90_to_100_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _1kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _2kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _3kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _4kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _6kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _7kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _8kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _9kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _10kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome",
  { data_type => "text", is_nullable => 0 },
  "_10kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_9kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_8kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_7kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_6kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_4kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_2kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_1kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5prime_utr_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_exons_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_introns_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3prime_utr_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_0_to_10_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_10_to_20_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_20_to_30_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_30_to_40_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_40_to_50_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_50_to_60_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_60_to_70_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_70_to_80_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_80_to_90_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_90_to_100_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_1kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_2kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_4kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_6kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_7kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_8kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_9kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_10kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome__10kb_upstream_peaks_file__9kb_upstream_peaks_file__8kb_upstream_peaks_file__7kb_upstream_peaks_file__6kb_upstream_peaks_file__5kb_upstream_peaks_file__4kb_upstream_peaks_file__3kb_upstream_peaks_file__2kb_upstream_peaks_file__1kb_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1kb_downstream_peaks_file__2kb_downstream_peaks_file__3kb_downstream_peaks_file__4kb_downstream_peaks_file__5kb_downstream_peaks_file__6kb_downstream_peaks_file__7kb_downstream_peaks_file__8kb_downstream_peaks_file__9kb_downstream_peaks_file__10kb_downstream_peaks_file__gene_body_0_to_10_peaks_file__gene_body_10_to_20_peaks_file__gene_body_20_to_30_peaks_file__gene_body_30_to_40_peaks_file__gene_body_40_to_50_peaks_file__gene_body_50_to_60_peaks_file__gene_body_60_to_70_peaks_file__gene_body_70_to_80_peaks_file__gene_body_80_to_90_peaks_file__gene_body_90_to_100_peaks_file_unique>

=over 4

=item * L</genome>

=item * L</_10kb_upstream_peaks_file>

=item * L</_9kb_upstream_peaks_file>

=item * L</_8kb_upstream_peaks_file>

=item * L</_7kb_upstream_peaks_file>

=item * L</_6kb_upstream_peaks_file>

=item * L</_5kb_upstream_peaks_file>

=item * L</_4kb_upstream_peaks_file>

=item * L</_3kb_upstream_peaks_file>

=item * L</_2kb_upstream_peaks_file>

=item * L</_1kb_upstream_peaks_file>

=item * L</_5prime_utr_peaks_file>

=item * L</_exons_peaks_file>

=item * L</_introns_peaks_file>

=item * L</_3prime_utr_peaks_file>

=item * L</_1kb_downstream_peaks_file>

=item * L</_2kb_downstream_peaks_file>

=item * L</_3kb_downstream_peaks_file>

=item * L</_4kb_downstream_peaks_file>

=item * L</_5kb_downstream_peaks_file>

=item * L</_6kb_downstream_peaks_file>

=item * L</_7kb_downstream_peaks_file>

=item * L</_8kb_downstream_peaks_file>

=item * L</_9kb_downstream_peaks_file>

=item * L</_10kb_downstream_peaks_file>

=item * L</_gene_body_0_to_10_peaks_file>

=item * L</_gene_body_10_to_20_peaks_file>

=item * L</_gene_body_20_to_30_peaks_file>

=item * L</_gene_body_30_to_40_peaks_file>

=item * L</_gene_body_40_to_50_peaks_file>

=item * L</_gene_body_50_to_60_peaks_file>

=item * L</_gene_body_60_to_70_peaks_file>

=item * L</_gene_body_70_to_80_peaks_file>

=item * L</_gene_body_80_to_90_peaks_file>

=item * L</_gene_body_90_to_100_peaks_file>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "genome__10kb_upstream_peaks_file__9kb_upstream_peaks_file__8kb_upstream_peaks_file__7kb_upstream_peaks_file__6kb_upstream_peaks_file__5kb_upstream_peaks_file__4kb_upstream_peaks_file__3kb_upstream_peaks_file__2kb_upstream_peaks_file__1kb_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1kb_downstream_peaks_file__2kb_downstream_peaks_file__3kb_downstream_peaks_file__4kb_downstream_peaks_file__5kb_downstream_peaks_file__6kb_downstream_peaks_file__7kb_downstream_peaks_file__8kb_downstream_peaks_file__9kb_downstream_peaks_file__10kb_downstream_peaks_file__gene_body_0_to_10_peaks_file__gene_body_10_to_20_peaks_file__gene_body_20_to_30_peaks_file__gene_body_30_to_40_peaks_file__gene_body_40_to_50_peaks_file__gene_body_50_to_60_peaks_file__gene_body_60_to_70_peaks_file__gene_body_70_to_80_peaks_file__gene_body_80_to_90_peaks_file__gene_body_90_to_100_peaks_file_unique",
  [
    "genome",
    "_10kb_upstream_peaks_file",
    "_9kb_upstream_peaks_file",
    "_8kb_upstream_peaks_file",
    "_7kb_upstream_peaks_file",
    "_6kb_upstream_peaks_file",
    "_5kb_upstream_peaks_file",
    "_4kb_upstream_peaks_file",
    "_3kb_upstream_peaks_file",
    "_2kb_upstream_peaks_file",
    "_1kb_upstream_peaks_file",
    "_5prime_utr_peaks_file",
    "_exons_peaks_file",
    "_introns_peaks_file",
    "_3prime_utr_peaks_file",
    "_1kb_downstream_peaks_file",
    "_2kb_downstream_peaks_file",
    "_3kb_downstream_peaks_file",
    "_4kb_downstream_peaks_file",
    "_5kb_downstream_peaks_file",
    "_6kb_downstream_peaks_file",
    "_7kb_downstream_peaks_file",
    "_8kb_downstream_peaks_file",
    "_9kb_downstream_peaks_file",
    "_10kb_downstream_peaks_file",
    "_gene_body_0_to_10_peaks_file",
    "_gene_body_10_to_20_peaks_file",
    "_gene_body_20_to_30_peaks_file",
    "_gene_body_30_to_40_peaks_file",
    "_gene_body_40_to_50_peaks_file",
    "_gene_body_50_to_60_peaks_file",
    "_gene_body_60_to_70_peaks_file",
    "_gene_body_70_to_80_peaks_file",
    "_gene_body_80_to_90_peaks_file",
    "_gene_body_90_to_100_peaks_file",
  ],
);

=head1 RELATIONS

=head2 chromosome_sizes

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::ChromosomeSize>

=cut

__PACKAGE__->has_many(
  "chromosome_sizes",
  "PeaksToGenes::Schema::Result::ChromosomeSize",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 downstream_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::DownstreamNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "downstream_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::DownstreamNumberOfPeaks",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 experiments

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::Experiment>

=cut

__PACKAGE__->has_many(
  "experiments",
  "PeaksToGenes::Schema::Result::Experiment",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_body_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "gene_body_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::GeneBodyNumberOfPeaks",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcript_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::TranscriptNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "transcript_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::TranscriptNumberOfPeaks",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transcripts

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "PeaksToGenes::Schema::Result::Transcript",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 upstream_numbers_of_peaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks>

=cut

__PACKAGE__->has_many(
  "upstream_numbers_of_peaks",
  "PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-12-14 17:46:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:G6K7O0qD6FVj34v1Yx6QUw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
