use utf8;
package PeaksToGenes::Schema::Result::Annotatedpeak;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::Annotatedpeak

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<annotatedpeaks>

=cut

__PACKAGE__->table("annotatedpeaks");

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

  data_type: 'text'
  is_nullable: 0

=head2 gene

  data_type: 'text'
  is_nullable: 0

=head2 _100k_upstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _50k_upstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _25k_upstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _10k_upstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _5k_upstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _promoters_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _5prime_utr_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _exons_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _introns_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _3prime_utr_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _2_5k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _5k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _10k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _25k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _50k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _100k_downstream_number_of_peaks

  data_type: 'integer'
  is_nullable: 1

=head2 _100k_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _50k_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _25k_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _10k_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _5k_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _promoters_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _5prime_utr_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _exons_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _introns_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _3prime_utr_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _2_5k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _5k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _10k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _25k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _50k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _100k_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "gene",
  { data_type => "text", is_nullable => 0 },
  "_100k_upstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_50k_upstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_25k_upstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_10k_upstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_5k_upstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_promoters_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_5prime_utr_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_exons_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_introns_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_3prime_utr_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_2_5k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_5k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_10k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_25k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_50k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_100k_downstream_number_of_peaks",
  { data_type => "integer", is_nullable => 1 },
  "_100k_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_50k_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_25k_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_10k_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5k_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_promoters_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5prime_utr_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_exons_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_introns_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_3prime_utr_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_2_5k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_10k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_25k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_50k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_100k_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_gene_unique>

=over 4

=item * L</name>

=item * L</gene>

=back

=cut

__PACKAGE__->add_unique_constraint("name_gene_unique", ["name", "gene"]);

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-26 12:20:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fsdBw8OttamRu3afMW7XQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
