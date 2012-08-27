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

=head2 _100k_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _50k_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _25k_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _10k_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5k_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _promoters_peaks_file

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

=head2 _2_5k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _5k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _10k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _25k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _50k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _100k_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome",
  { data_type => "text", is_nullable => 0 },
  "_100k_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_50k_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_25k_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_10k_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5k_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_promoters_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5prime_utr_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_exons_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_introns_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_3prime_utr_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_2_5k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_5k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_10k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_25k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_50k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_100k_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome__100k_upstream_peaks_file__50k_upstream_peaks_file__25k_upstream_peaks_file__10k_upstream_peaks_file__5k_upstream_peaks_file__promoters_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__2_5k_downstream_peaks_file__5k_downstream_peaks_file__10k_downstream_peaks_file__25k_downstream_peaks_file__50k_downstream_peaks_file__100k_downstream_peaks_file_unique>

=over 4

=item * L</genome>

=item * L</_100k_upstream_peaks_file>

=item * L</_50k_upstream_peaks_file>

=item * L</_25k_upstream_peaks_file>

=item * L</_10k_upstream_peaks_file>

=item * L</_5k_upstream_peaks_file>

=item * L</_promoters_peaks_file>

=item * L</_5prime_utr_peaks_file>

=item * L</_exons_peaks_file>

=item * L</_introns_peaks_file>

=item * L</_3prime_utr_peaks_file>

=item * L</_2_5k_downstream_peaks_file>

=item * L</_5k_downstream_peaks_file>

=item * L</_10k_downstream_peaks_file>

=item * L</_25k_downstream_peaks_file>

=item * L</_50k_downstream_peaks_file>

=item * L</_100k_downstream_peaks_file>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "genome__100k_upstream_peaks_file__50k_upstream_peaks_file__25k_upstream_peaks_file__10k_upstream_peaks_file__5k_upstream_peaks_file__promoters_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__2_5k_downstream_peaks_file__5k_downstream_peaks_file__10k_downstream_peaks_file__25k_downstream_peaks_file__50k_downstream_peaks_file__100k_downstream_peaks_file_unique",
  [
    "genome",
    "_100k_upstream_peaks_file",
    "_50k_upstream_peaks_file",
    "_25k_upstream_peaks_file",
    "_10k_upstream_peaks_file",
    "_5k_upstream_peaks_file",
    "_promoters_peaks_file",
    "_5prime_utr_peaks_file",
    "_exons_peaks_file",
    "_introns_peaks_file",
    "_3prime_utr_peaks_file",
    "_2_5k_downstream_peaks_file",
    "_5k_downstream_peaks_file",
    "_10k_downstream_peaks_file",
    "_25k_downstream_peaks_file",
    "_50k_downstream_peaks_file",
    "_100k_downstream_peaks_file",
  ],
);

=head1 RELATIONS

=head2 annotatedpeaks

Type: has_many

Related object: L<PeaksToGenes::Schema::Result::Annotatedpeak>

=cut

__PACKAGE__->has_many(
  "annotatedpeaks",
  "PeaksToGenes::Schema::Result::Annotatedpeak",
  { "foreign.genome_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-26 22:52:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+RZw+Ov3JI5ZrPpjWC6nig


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
