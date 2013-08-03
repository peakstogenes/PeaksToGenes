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

=head2 _10_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _9_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _8_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _7_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _6_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _4_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _3_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _2_steps_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _1_steps_upstream_peaks_file

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

=head2 _1_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _2_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _3_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _4_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _6_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _7_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _8_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _9_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _10_steps_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 step_size

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome",
  { data_type => "text", is_nullable => 0 },
  "_10_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_9_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_8_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_7_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_6_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_4_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_2_steps_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_1_steps_upstream_peaks_file",
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
  "_1_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_2_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_4_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_6_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_7_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_8_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_9_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_10_steps_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "step_size",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome_step_size__10_steps_upstream_peaks_file__9_steps_upstream_peaks_file__8_steps_upstream_peaks_file__7_steps_upstream_peaks_file__6_steps_upstream_peaks_file__5_steps_upstream_peaks_file__4_steps_upstream_peaks_file__3_steps_upstream_peaks_file__2_steps_upstream_peaks_file__1_steps_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1_steps_downstream_peaks_file__2_steps_downstream_peaks_file__3_steps_downstream_peaks_file__4_steps_downstream_peaks_file__5_steps_downstream_peaks_file__6_steps_downstream_peaks_file__7_steps_downstream_peaks_file__8_steps_downstream_peaks_file__9_steps_downstream_peaks_file__10_steps_downstream_peaks_file__gene_body_0_to_10_peaks_file__gene_body_10_to_20_peaks_file__gene_body_20_to_30_peaks_file__gene_body_30_to_40_peaks_file__gene_body_40_to_50_peaks_file__gene_body_50_to_60_peaks_file__gene_body_60_to_70_peaks_file__gene_body_70_to_80_peaks_file__gene_body_80_to_90_peaks_file__gene_body_90_to_100_peaks_file_unique>

=over 4

=item * L</genome>

=item * L</step_size>

=item * L</_10_steps_upstream_peaks_file>

=item * L</_9_steps_upstream_peaks_file>

=item * L</_8_steps_upstream_peaks_file>

=item * L</_7_steps_upstream_peaks_file>

=item * L</_6_steps_upstream_peaks_file>

=item * L</_5_steps_upstream_peaks_file>

=item * L</_4_steps_upstream_peaks_file>

=item * L</_3_steps_upstream_peaks_file>

=item * L</_2_steps_upstream_peaks_file>

=item * L</_1_steps_upstream_peaks_file>

=item * L</_5prime_utr_peaks_file>

=item * L</_exons_peaks_file>

=item * L</_introns_peaks_file>

=item * L</_3prime_utr_peaks_file>

=item * L</_1_steps_downstream_peaks_file>

=item * L</_2_steps_downstream_peaks_file>

=item * L</_3_steps_downstream_peaks_file>

=item * L</_4_steps_downstream_peaks_file>

=item * L</_5_steps_downstream_peaks_file>

=item * L</_6_steps_downstream_peaks_file>

=item * L</_7_steps_downstream_peaks_file>

=item * L</_8_steps_downstream_peaks_file>

=item * L</_9_steps_downstream_peaks_file>

=item * L</_10_steps_downstream_peaks_file>

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
  "genome_step_size__10_steps_upstream_peaks_file__9_steps_upstream_peaks_file__8_steps_upstream_peaks_file__7_steps_upstream_peaks_file__6_steps_upstream_peaks_file__5_steps_upstream_peaks_file__4_steps_upstream_peaks_file__3_steps_upstream_peaks_file__2_steps_upstream_peaks_file__1_steps_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1_steps_downstream_peaks_file__2_steps_downstream_peaks_file__3_steps_downstream_peaks_file__4_steps_downstream_peaks_file__5_steps_downstream_peaks_file__6_steps_downstream_peaks_file__7_steps_downstream_peaks_file__8_steps_downstream_peaks_file__9_steps_downstream_peaks_file__10_steps_downstream_peaks_file__gene_body_0_to_10_peaks_file__gene_body_10_to_20_peaks_file__gene_body_20_to_30_peaks_file__gene_body_30_to_40_peaks_file__gene_body_40_to_50_peaks_file__gene_body_50_to_60_peaks_file__gene_body_60_to_70_peaks_file__gene_body_70_to_80_peaks_file__gene_body_80_to_90_peaks_file__gene_body_90_to_100_peaks_file_unique",
  [
    "genome",
    "step_size",
    "_10_steps_upstream_peaks_file",
    "_9_steps_upstream_peaks_file",
    "_8_steps_upstream_peaks_file",
    "_7_steps_upstream_peaks_file",
    "_6_steps_upstream_peaks_file",
    "_5_steps_upstream_peaks_file",
    "_4_steps_upstream_peaks_file",
    "_3_steps_upstream_peaks_file",
    "_2_steps_upstream_peaks_file",
    "_1_steps_upstream_peaks_file",
    "_5prime_utr_peaks_file",
    "_exons_peaks_file",
    "_introns_peaks_file",
    "_3prime_utr_peaks_file",
    "_1_steps_downstream_peaks_file",
    "_2_steps_downstream_peaks_file",
    "_3_steps_downstream_peaks_file",
    "_4_steps_downstream_peaks_file",
    "_5_steps_downstream_peaks_file",
    "_6_steps_downstream_peaks_file",
    "_7_steps_downstream_peaks_file",
    "_8_steps_downstream_peaks_file",
    "_9_steps_downstream_peaks_file",
    "_10_steps_downstream_peaks_file",
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


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-02 12:42:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/Qjxa7PDTp3MIupJbJdBnQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
