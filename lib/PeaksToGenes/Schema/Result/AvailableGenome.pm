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

=head2 _100kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _99kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _98kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _97kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _96kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _95kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _94kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _93kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _92kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _91kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _90kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _89kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _88kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _87kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _86kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _85kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _84kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _83kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _82kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _81kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _80kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _79kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _78kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _77kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _76kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _75kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _74kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _73kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _72kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _71kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _70kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _69kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _68kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _67kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _66kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _65kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _64kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _63kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _62kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _61kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _60kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _59kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _58kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _57kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _56kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _55kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _54kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _53kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _52kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _51kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _50kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _49kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _48kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _47kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _46kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _45kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _44kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _43kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _42kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _41kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _40kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _39kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _38kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _37kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _36kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _35kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _34kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _33kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _32kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _31kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _30kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _29kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _28kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _27kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _26kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _25kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _24kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _23kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _22kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _21kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _20kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _19kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _18kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _17kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _16kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _15kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _14kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _13kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _12kb_upstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _11kb_upstream_peaks_file

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

=head2 _gene_body_10_to_20_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_20_to_30_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_30_to_40_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_40_to_50_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_50_to_60_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_60_to_70_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_70_to_80_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_80_to_90_file

  data_type: 'text'
  is_nullable: 0

=head2 _gene_body_90_to_100_file

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

=head2 _11kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _12kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _13kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _14kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _15kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _16kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _17kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _18kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _19kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _20kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _21kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _22kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _23kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _24kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _25kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _26kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _27kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _28kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _29kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _30kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _31kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _32kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _33kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _34kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _35kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _36kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _37kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _38kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _39kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _40kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _41kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _42kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _43kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _44kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _45kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _46kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _47kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _48kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _49kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _50kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _51kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _52kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _53kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _54kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _55kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _56kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _57kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _58kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _59kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _60kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _61kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _62kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _63kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _64kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _65kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _66kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _67kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _68kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _69kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _70kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _71kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _72kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _73kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _74kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _75kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _76kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _77kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _78kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _79kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _80kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _81kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _82kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _83kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _84kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _85kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _86kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _87kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _88kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _89kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _90kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _91kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _92kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _93kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _94kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _95kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _96kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _97kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _98kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _99kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=head2 _100kb_downstream_peaks_file

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome",
  { data_type => "text", is_nullable => 0 },
  "_100kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_99kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_98kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_97kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_96kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_95kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_94kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_93kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_92kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_91kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_90kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_89kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_88kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_87kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_86kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_85kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_84kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_83kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_82kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_81kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_80kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_79kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_78kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_77kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_76kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_75kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_74kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_73kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_72kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_71kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_70kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_69kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_68kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_67kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_66kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_65kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_64kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_63kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_62kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_61kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_60kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_59kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_58kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_57kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_56kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_55kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_54kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_53kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_52kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_51kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_50kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_49kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_48kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_47kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_46kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_45kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_44kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_43kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_42kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_41kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_40kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_39kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_38kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_37kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_36kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_35kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_34kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_33kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_32kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_31kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_30kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_29kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_28kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_27kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_26kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_25kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_24kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_23kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_22kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_21kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_20kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_19kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_18kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_17kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_16kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_15kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_14kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_13kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_12kb_upstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_11kb_upstream_peaks_file",
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
  "_gene_body_10_to_20_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_20_to_30_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_30_to_40_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_40_to_50_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_50_to_60_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_60_to_70_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_70_to_80_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_80_to_90_file",
  { data_type => "text", is_nullable => 0 },
  "_gene_body_90_to_100_file",
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
  "_11kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_12kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_13kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_14kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_15kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_16kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_17kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_18kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_19kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_20kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_21kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_22kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_23kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_24kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_25kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_26kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_27kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_28kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_29kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_30kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_31kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_32kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_33kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_34kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_35kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_36kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_37kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_38kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_39kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_40kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_41kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_42kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_43kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_44kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_45kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_46kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_47kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_48kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_49kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_50kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_51kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_52kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_53kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_54kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_55kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_56kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_57kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_58kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_59kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_60kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_61kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_62kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_63kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_64kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_65kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_66kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_67kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_68kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_69kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_70kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_71kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_72kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_73kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_74kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_75kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_76kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_77kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_78kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_79kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_80kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_81kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_82kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_83kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_84kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_85kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_86kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_87kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_88kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_89kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_90kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_91kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_92kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_93kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_94kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_95kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_96kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_97kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_98kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_99kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
  "_100kb_downstream_peaks_file",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome__100kb_upstream_peaks_file__99kb_upstream_peaks_file__98kb_upstream_peaks_file__97kb_upstream_peaks_file__96kb_upstream_peaks_file__95kb_upstream_peaks_file__94kb_upstream_peaks_file__93kb_upstream_peaks_file__92kb_upstream_peaks_file__91kb_upstream_peaks_file__90kb_upstream_peaks_file__89kb_upstream_peaks_file__88kb_upstream_peaks_file__87kb_upstream_peaks_file__86kb_upstream_peaks_file__85kb_upstream_peaks_file__84kb_upstream_peaks_file__83kb_upstream_peaks_file__82kb_upstream_peaks_file__81kb_upstream_peaks_file__80kb_upstream_peaks_file__79kb_upstream_peaks_file__78kb_upstream_peaks_file__77kb_upstream_peaks_file__76kb_upstream_peaks_file__75kb_upstream_peaks_file__74kb_upstream_peaks_file__73kb_upstream_peaks_file__72kb_upstream_peaks_file__71kb_upstream_peaks_file__70kb_upstream_peaks_file__69kb_upstream_peaks_file__68kb_upstream_peaks_file__67kb_upstream_peaks_file__66kb_upstream_peaks_file__65kb_upstream_peaks_file__64kb_upstream_peaks_file__63kb_upstream_peaks_file__62kb_upstream_peaks_file__61kb_upstream_peaks_file__60kb_upstream_peaks_file__59kb_upstream_peaks_file__58kb_upstream_peaks_file__57kb_upstream_peaks_file__56kb_upstream_peaks_file__55kb_upstream_peaks_file__54kb_upstream_peaks_file__53kb_upstream_peaks_file__52kb_upstream_peaks_file__51kb_upstream_peaks_file__50kb_upstream_peaks_file__49kb_upstream_peaks_file__48kb_upstream_peaks_file__47kb_upstream_peaks_file__46kb_upstream_peaks_file__45kb_upstream_peaks_file__44kb_upstream_peaks_file__43kb_upstream_peaks_file__42kb_upstream_peaks_file__41kb_upstream_peaks_file__40kb_upstream_peaks_file__39kb_upstream_peaks_file__38kb_upstream_peaks_file__37kb_upstream_peaks_file__36kb_upstream_peaks_file__35kb_upstream_peaks_file__34kb_upstream_peaks_file__33kb_upstream_peaks_file__32kb_upstream_peaks_file__31kb_upstream_peaks_file__30kb_upstream_peaks_file__29kb_upstream_peaks_file__28kb_upstream_peaks_file__27kb_upstream_peaks_file__26kb_upstream_peaks_file__25kb_upstream_peaks_file__24kb_upstream_peaks_file__23kb_upstream_peaks_file__22kb_upstream_peaks_file__21kb_upstream_peaks_file__20kb_upstream_peaks_file__19kb_upstream_peaks_file__18kb_upstream_peaks_file__17kb_upstream_peaks_file__16kb_upstream_peaks_file__15kb_upstream_peaks_file__14kb_upstream_peaks_file__13kb_upstream_peaks_file__12kb_upstream_peaks_file__11kb_upstream_peaks_file__10kb_upstream_peaks_file__9kb_upstream_peaks_file__8kb_upstream_peaks_file__7kb_upstream_peaks_file__6kb_upstream_peaks_file__5kb_upstream_peaks_file__4kb_upstream_peaks_file__3kb_upstream_peaks_file__2kb_upstream_peaks_file__1kb_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1kb_downstream_peaks_file__2kb_downstream_peaks_file__3kb_downstream_peaks_file__4kb_downstream_peaks_file__5kb_downstream_peaks_file__6kb_downstream_peaks_file__7kb_downstream_peaks_file__8kb_downstream_peaks_file__9kb_downstream_peaks_file__10kb_downstream_peaks_file__11kb_downstream_peaks_file__12kb_downstream_peaks_file__13kb_downstream_peaks_file__14kb_downstream_peaks_file__15kb_downstream_peaks_file__16kb_downstream_peaks_file__17kb_downstream_peaks_file__18kb_downstream_peaks_file__19kb_downstream_peaks_file__20kb_downstream_peaks_file__21kb_downstream_peaks_file__22kb_downstream_peaks_file__23kb_downstream_peaks_file__24kb_downstream_peaks_file__25kb_downstream_peaks_file__26kb_downstream_peaks_file__27kb_downstream_peaks_file__28kb_downstream_peaks_file__29kb_downstream_peaks_file__30kb_downstream_peaks_file__31kb_downstream_peaks_file__32kb_downstream_peaks_file__33kb_downstream_peaks_file__34kb_downstream_peaks_file__35kb_downstream_peaks_file__36kb_downstream_peaks_file__37kb_downstream_peaks_file__38kb_downstream_peaks_file__39kb_downstream_peaks_file__40kb_downstream_peaks_file__41kb_downstream_peaks_file__42kb_downstream_peaks_file__43kb_downstream_peaks_file__44kb_downstream_peaks_file__45kb_downstream_peaks_file__46kb_downstream_peaks_file__47kb_downstream_peaks_file__48kb_downstream_peaks_file__49kb_downstream_peaks_file__50kb_downstream_peaks_file__51kb_downstream_peaks_file__52kb_downstream_peaks_file__53kb_downstream_peaks_file__54kb_downstream_peaks_file__55kb_downstream_peaks_file__56kb_downstream_peaks_file__57kb_downstream_peaks_file__58kb_downstream_peaks_file__59kb_downstream_peaks_file__60kb_downstream_peaks_file__61kb_downstream_peaks_file__62kb_downstream_peaks_file__63kb_downstream_peaks_file__64kb_downstream_peaks_file__65kb_downstream_peaks_file__66kb_downstream_peaks_file__67kb_downstream_peaks_file__68kb_downstream_peaks_file__69kb_downstream_peaks_file__70kb_downstream_peaks_file__71kb_downstream_peaks_file__72kb_downstream_peaks_file__73kb_downstream_peaks_file__74kb_downstream_peaks_file__75kb_downstream_peaks_file__76kb_downstream_peaks_file__77kb_downstream_peaks_file__78kb_downstream_peaks_file__79kb_downstream_peaks_file__80kb_downstream_peaks_file__81kb_downstream_peaks_file__82kb_downstream_peaks_file__83kb_downstream_peaks_file__84kb_downstream_peaks_file__85kb_downstream_peaks_file__86kb_downstream_peaks_file__87kb_downstream_peaks_file__88kb_downstream_peaks_file__89kb_downstream_peaks_file__90kb_downstream_peaks_file__91kb_downstream_peaks_file__92kb_downstream_peaks_file__93kb_downstream_peaks_file__94kb_downstream_peaks_file__95kb_downstream_peaks_file__96kb_downstream_peaks_file__97kb_downstream_peaks_file__98kb_downstream_peaks_file__99kb_downstream_peaks_file__100kb_downstream_peaks_file_unique>

=over 4

=item * L</genome>

=item * L</_100kb_upstream_peaks_file>

=item * L</_99kb_upstream_peaks_file>

=item * L</_98kb_upstream_peaks_file>

=item * L</_97kb_upstream_peaks_file>

=item * L</_96kb_upstream_peaks_file>

=item * L</_95kb_upstream_peaks_file>

=item * L</_94kb_upstream_peaks_file>

=item * L</_93kb_upstream_peaks_file>

=item * L</_92kb_upstream_peaks_file>

=item * L</_91kb_upstream_peaks_file>

=item * L</_90kb_upstream_peaks_file>

=item * L</_89kb_upstream_peaks_file>

=item * L</_88kb_upstream_peaks_file>

=item * L</_87kb_upstream_peaks_file>

=item * L</_86kb_upstream_peaks_file>

=item * L</_85kb_upstream_peaks_file>

=item * L</_84kb_upstream_peaks_file>

=item * L</_83kb_upstream_peaks_file>

=item * L</_82kb_upstream_peaks_file>

=item * L</_81kb_upstream_peaks_file>

=item * L</_80kb_upstream_peaks_file>

=item * L</_79kb_upstream_peaks_file>

=item * L</_78kb_upstream_peaks_file>

=item * L</_77kb_upstream_peaks_file>

=item * L</_76kb_upstream_peaks_file>

=item * L</_75kb_upstream_peaks_file>

=item * L</_74kb_upstream_peaks_file>

=item * L</_73kb_upstream_peaks_file>

=item * L</_72kb_upstream_peaks_file>

=item * L</_71kb_upstream_peaks_file>

=item * L</_70kb_upstream_peaks_file>

=item * L</_69kb_upstream_peaks_file>

=item * L</_68kb_upstream_peaks_file>

=item * L</_67kb_upstream_peaks_file>

=item * L</_66kb_upstream_peaks_file>

=item * L</_65kb_upstream_peaks_file>

=item * L</_64kb_upstream_peaks_file>

=item * L</_63kb_upstream_peaks_file>

=item * L</_62kb_upstream_peaks_file>

=item * L</_61kb_upstream_peaks_file>

=item * L</_60kb_upstream_peaks_file>

=item * L</_59kb_upstream_peaks_file>

=item * L</_58kb_upstream_peaks_file>

=item * L</_57kb_upstream_peaks_file>

=item * L</_56kb_upstream_peaks_file>

=item * L</_55kb_upstream_peaks_file>

=item * L</_54kb_upstream_peaks_file>

=item * L</_53kb_upstream_peaks_file>

=item * L</_52kb_upstream_peaks_file>

=item * L</_51kb_upstream_peaks_file>

=item * L</_50kb_upstream_peaks_file>

=item * L</_49kb_upstream_peaks_file>

=item * L</_48kb_upstream_peaks_file>

=item * L</_47kb_upstream_peaks_file>

=item * L</_46kb_upstream_peaks_file>

=item * L</_45kb_upstream_peaks_file>

=item * L</_44kb_upstream_peaks_file>

=item * L</_43kb_upstream_peaks_file>

=item * L</_42kb_upstream_peaks_file>

=item * L</_41kb_upstream_peaks_file>

=item * L</_40kb_upstream_peaks_file>

=item * L</_39kb_upstream_peaks_file>

=item * L</_38kb_upstream_peaks_file>

=item * L</_37kb_upstream_peaks_file>

=item * L</_36kb_upstream_peaks_file>

=item * L</_35kb_upstream_peaks_file>

=item * L</_34kb_upstream_peaks_file>

=item * L</_33kb_upstream_peaks_file>

=item * L</_32kb_upstream_peaks_file>

=item * L</_31kb_upstream_peaks_file>

=item * L</_30kb_upstream_peaks_file>

=item * L</_29kb_upstream_peaks_file>

=item * L</_28kb_upstream_peaks_file>

=item * L</_27kb_upstream_peaks_file>

=item * L</_26kb_upstream_peaks_file>

=item * L</_25kb_upstream_peaks_file>

=item * L</_24kb_upstream_peaks_file>

=item * L</_23kb_upstream_peaks_file>

=item * L</_22kb_upstream_peaks_file>

=item * L</_21kb_upstream_peaks_file>

=item * L</_20kb_upstream_peaks_file>

=item * L</_19kb_upstream_peaks_file>

=item * L</_18kb_upstream_peaks_file>

=item * L</_17kb_upstream_peaks_file>

=item * L</_16kb_upstream_peaks_file>

=item * L</_15kb_upstream_peaks_file>

=item * L</_14kb_upstream_peaks_file>

=item * L</_13kb_upstream_peaks_file>

=item * L</_12kb_upstream_peaks_file>

=item * L</_11kb_upstream_peaks_file>

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

=item * L</_11kb_downstream_peaks_file>

=item * L</_12kb_downstream_peaks_file>

=item * L</_13kb_downstream_peaks_file>

=item * L</_14kb_downstream_peaks_file>

=item * L</_15kb_downstream_peaks_file>

=item * L</_16kb_downstream_peaks_file>

=item * L</_17kb_downstream_peaks_file>

=item * L</_18kb_downstream_peaks_file>

=item * L</_19kb_downstream_peaks_file>

=item * L</_20kb_downstream_peaks_file>

=item * L</_21kb_downstream_peaks_file>

=item * L</_22kb_downstream_peaks_file>

=item * L</_23kb_downstream_peaks_file>

=item * L</_24kb_downstream_peaks_file>

=item * L</_25kb_downstream_peaks_file>

=item * L</_26kb_downstream_peaks_file>

=item * L</_27kb_downstream_peaks_file>

=item * L</_28kb_downstream_peaks_file>

=item * L</_29kb_downstream_peaks_file>

=item * L</_30kb_downstream_peaks_file>

=item * L</_31kb_downstream_peaks_file>

=item * L</_32kb_downstream_peaks_file>

=item * L</_33kb_downstream_peaks_file>

=item * L</_34kb_downstream_peaks_file>

=item * L</_35kb_downstream_peaks_file>

=item * L</_36kb_downstream_peaks_file>

=item * L</_37kb_downstream_peaks_file>

=item * L</_38kb_downstream_peaks_file>

=item * L</_39kb_downstream_peaks_file>

=item * L</_40kb_downstream_peaks_file>

=item * L</_41kb_downstream_peaks_file>

=item * L</_42kb_downstream_peaks_file>

=item * L</_43kb_downstream_peaks_file>

=item * L</_44kb_downstream_peaks_file>

=item * L</_45kb_downstream_peaks_file>

=item * L</_46kb_downstream_peaks_file>

=item * L</_47kb_downstream_peaks_file>

=item * L</_48kb_downstream_peaks_file>

=item * L</_49kb_downstream_peaks_file>

=item * L</_50kb_downstream_peaks_file>

=item * L</_51kb_downstream_peaks_file>

=item * L</_52kb_downstream_peaks_file>

=item * L</_53kb_downstream_peaks_file>

=item * L</_54kb_downstream_peaks_file>

=item * L</_55kb_downstream_peaks_file>

=item * L</_56kb_downstream_peaks_file>

=item * L</_57kb_downstream_peaks_file>

=item * L</_58kb_downstream_peaks_file>

=item * L</_59kb_downstream_peaks_file>

=item * L</_60kb_downstream_peaks_file>

=item * L</_61kb_downstream_peaks_file>

=item * L</_62kb_downstream_peaks_file>

=item * L</_63kb_downstream_peaks_file>

=item * L</_64kb_downstream_peaks_file>

=item * L</_65kb_downstream_peaks_file>

=item * L</_66kb_downstream_peaks_file>

=item * L</_67kb_downstream_peaks_file>

=item * L</_68kb_downstream_peaks_file>

=item * L</_69kb_downstream_peaks_file>

=item * L</_70kb_downstream_peaks_file>

=item * L</_71kb_downstream_peaks_file>

=item * L</_72kb_downstream_peaks_file>

=item * L</_73kb_downstream_peaks_file>

=item * L</_74kb_downstream_peaks_file>

=item * L</_75kb_downstream_peaks_file>

=item * L</_76kb_downstream_peaks_file>

=item * L</_77kb_downstream_peaks_file>

=item * L</_78kb_downstream_peaks_file>

=item * L</_79kb_downstream_peaks_file>

=item * L</_80kb_downstream_peaks_file>

=item * L</_81kb_downstream_peaks_file>

=item * L</_82kb_downstream_peaks_file>

=item * L</_83kb_downstream_peaks_file>

=item * L</_84kb_downstream_peaks_file>

=item * L</_85kb_downstream_peaks_file>

=item * L</_86kb_downstream_peaks_file>

=item * L</_87kb_downstream_peaks_file>

=item * L</_88kb_downstream_peaks_file>

=item * L</_89kb_downstream_peaks_file>

=item * L</_90kb_downstream_peaks_file>

=item * L</_91kb_downstream_peaks_file>

=item * L</_92kb_downstream_peaks_file>

=item * L</_93kb_downstream_peaks_file>

=item * L</_94kb_downstream_peaks_file>

=item * L</_95kb_downstream_peaks_file>

=item * L</_96kb_downstream_peaks_file>

=item * L</_97kb_downstream_peaks_file>

=item * L</_98kb_downstream_peaks_file>

=item * L</_99kb_downstream_peaks_file>

=item * L</_100kb_downstream_peaks_file>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "genome__100kb_upstream_peaks_file__99kb_upstream_peaks_file__98kb_upstream_peaks_file__97kb_upstream_peaks_file__96kb_upstream_peaks_file__95kb_upstream_peaks_file__94kb_upstream_peaks_file__93kb_upstream_peaks_file__92kb_upstream_peaks_file__91kb_upstream_peaks_file__90kb_upstream_peaks_file__89kb_upstream_peaks_file__88kb_upstream_peaks_file__87kb_upstream_peaks_file__86kb_upstream_peaks_file__85kb_upstream_peaks_file__84kb_upstream_peaks_file__83kb_upstream_peaks_file__82kb_upstream_peaks_file__81kb_upstream_peaks_file__80kb_upstream_peaks_file__79kb_upstream_peaks_file__78kb_upstream_peaks_file__77kb_upstream_peaks_file__76kb_upstream_peaks_file__75kb_upstream_peaks_file__74kb_upstream_peaks_file__73kb_upstream_peaks_file__72kb_upstream_peaks_file__71kb_upstream_peaks_file__70kb_upstream_peaks_file__69kb_upstream_peaks_file__68kb_upstream_peaks_file__67kb_upstream_peaks_file__66kb_upstream_peaks_file__65kb_upstream_peaks_file__64kb_upstream_peaks_file__63kb_upstream_peaks_file__62kb_upstream_peaks_file__61kb_upstream_peaks_file__60kb_upstream_peaks_file__59kb_upstream_peaks_file__58kb_upstream_peaks_file__57kb_upstream_peaks_file__56kb_upstream_peaks_file__55kb_upstream_peaks_file__54kb_upstream_peaks_file__53kb_upstream_peaks_file__52kb_upstream_peaks_file__51kb_upstream_peaks_file__50kb_upstream_peaks_file__49kb_upstream_peaks_file__48kb_upstream_peaks_file__47kb_upstream_peaks_file__46kb_upstream_peaks_file__45kb_upstream_peaks_file__44kb_upstream_peaks_file__43kb_upstream_peaks_file__42kb_upstream_peaks_file__41kb_upstream_peaks_file__40kb_upstream_peaks_file__39kb_upstream_peaks_file__38kb_upstream_peaks_file__37kb_upstream_peaks_file__36kb_upstream_peaks_file__35kb_upstream_peaks_file__34kb_upstream_peaks_file__33kb_upstream_peaks_file__32kb_upstream_peaks_file__31kb_upstream_peaks_file__30kb_upstream_peaks_file__29kb_upstream_peaks_file__28kb_upstream_peaks_file__27kb_upstream_peaks_file__26kb_upstream_peaks_file__25kb_upstream_peaks_file__24kb_upstream_peaks_file__23kb_upstream_peaks_file__22kb_upstream_peaks_file__21kb_upstream_peaks_file__20kb_upstream_peaks_file__19kb_upstream_peaks_file__18kb_upstream_peaks_file__17kb_upstream_peaks_file__16kb_upstream_peaks_file__15kb_upstream_peaks_file__14kb_upstream_peaks_file__13kb_upstream_peaks_file__12kb_upstream_peaks_file__11kb_upstream_peaks_file__10kb_upstream_peaks_file__9kb_upstream_peaks_file__8kb_upstream_peaks_file__7kb_upstream_peaks_file__6kb_upstream_peaks_file__5kb_upstream_peaks_file__4kb_upstream_peaks_file__3kb_upstream_peaks_file__2kb_upstream_peaks_file__1kb_upstream_peaks_file__5prime_utr_peaks_file__exons_peaks_file__introns_peaks_file__3prime_utr_peaks_file__1kb_downstream_peaks_file__2kb_downstream_peaks_file__3kb_downstream_peaks_file__4kb_downstream_peaks_file__5kb_downstream_peaks_file__6kb_downstream_peaks_file__7kb_downstream_peaks_file__8kb_downstream_peaks_file__9kb_downstream_peaks_file__10kb_downstream_peaks_file__11kb_downstream_peaks_file__12kb_downstream_peaks_file__13kb_downstream_peaks_file__14kb_downstream_peaks_file__15kb_downstream_peaks_file__16kb_downstream_peaks_file__17kb_downstream_peaks_file__18kb_downstream_peaks_file__19kb_downstream_peaks_file__20kb_downstream_peaks_file__21kb_downstream_peaks_file__22kb_downstream_peaks_file__23kb_downstream_peaks_file__24kb_downstream_peaks_file__25kb_downstream_peaks_file__26kb_downstream_peaks_file__27kb_downstream_peaks_file__28kb_downstream_peaks_file__29kb_downstream_peaks_file__30kb_downstream_peaks_file__31kb_downstream_peaks_file__32kb_downstream_peaks_file__33kb_downstream_peaks_file__34kb_downstream_peaks_file__35kb_downstream_peaks_file__36kb_downstream_peaks_file__37kb_downstream_peaks_file__38kb_downstream_peaks_file__39kb_downstream_peaks_file__40kb_downstream_peaks_file__41kb_downstream_peaks_file__42kb_downstream_peaks_file__43kb_downstream_peaks_file__44kb_downstream_peaks_file__45kb_downstream_peaks_file__46kb_downstream_peaks_file__47kb_downstream_peaks_file__48kb_downstream_peaks_file__49kb_downstream_peaks_file__50kb_downstream_peaks_file__51kb_downstream_peaks_file__52kb_downstream_peaks_file__53kb_downstream_peaks_file__54kb_downstream_peaks_file__55kb_downstream_peaks_file__56kb_downstream_peaks_file__57kb_downstream_peaks_file__58kb_downstream_peaks_file__59kb_downstream_peaks_file__60kb_downstream_peaks_file__61kb_downstream_peaks_file__62kb_downstream_peaks_file__63kb_downstream_peaks_file__64kb_downstream_peaks_file__65kb_downstream_peaks_file__66kb_downstream_peaks_file__67kb_downstream_peaks_file__68kb_downstream_peaks_file__69kb_downstream_peaks_file__70kb_downstream_peaks_file__71kb_downstream_peaks_file__72kb_downstream_peaks_file__73kb_downstream_peaks_file__74kb_downstream_peaks_file__75kb_downstream_peaks_file__76kb_downstream_peaks_file__77kb_downstream_peaks_file__78kb_downstream_peaks_file__79kb_downstream_peaks_file__80kb_downstream_peaks_file__81kb_downstream_peaks_file__82kb_downstream_peaks_file__83kb_downstream_peaks_file__84kb_downstream_peaks_file__85kb_downstream_peaks_file__86kb_downstream_peaks_file__87kb_downstream_peaks_file__88kb_downstream_peaks_file__89kb_downstream_peaks_file__90kb_downstream_peaks_file__91kb_downstream_peaks_file__92kb_downstream_peaks_file__93kb_downstream_peaks_file__94kb_downstream_peaks_file__95kb_downstream_peaks_file__96kb_downstream_peaks_file__97kb_downstream_peaks_file__98kb_downstream_peaks_file__99kb_downstream_peaks_file__100kb_downstream_peaks_file_unique",
  [
    "genome",
    "_100kb_upstream_peaks_file",
    "_99kb_upstream_peaks_file",
    "_98kb_upstream_peaks_file",
    "_97kb_upstream_peaks_file",
    "_96kb_upstream_peaks_file",
    "_95kb_upstream_peaks_file",
    "_94kb_upstream_peaks_file",
    "_93kb_upstream_peaks_file",
    "_92kb_upstream_peaks_file",
    "_91kb_upstream_peaks_file",
    "_90kb_upstream_peaks_file",
    "_89kb_upstream_peaks_file",
    "_88kb_upstream_peaks_file",
    "_87kb_upstream_peaks_file",
    "_86kb_upstream_peaks_file",
    "_85kb_upstream_peaks_file",
    "_84kb_upstream_peaks_file",
    "_83kb_upstream_peaks_file",
    "_82kb_upstream_peaks_file",
    "_81kb_upstream_peaks_file",
    "_80kb_upstream_peaks_file",
    "_79kb_upstream_peaks_file",
    "_78kb_upstream_peaks_file",
    "_77kb_upstream_peaks_file",
    "_76kb_upstream_peaks_file",
    "_75kb_upstream_peaks_file",
    "_74kb_upstream_peaks_file",
    "_73kb_upstream_peaks_file",
    "_72kb_upstream_peaks_file",
    "_71kb_upstream_peaks_file",
    "_70kb_upstream_peaks_file",
    "_69kb_upstream_peaks_file",
    "_68kb_upstream_peaks_file",
    "_67kb_upstream_peaks_file",
    "_66kb_upstream_peaks_file",
    "_65kb_upstream_peaks_file",
    "_64kb_upstream_peaks_file",
    "_63kb_upstream_peaks_file",
    "_62kb_upstream_peaks_file",
    "_61kb_upstream_peaks_file",
    "_60kb_upstream_peaks_file",
    "_59kb_upstream_peaks_file",
    "_58kb_upstream_peaks_file",
    "_57kb_upstream_peaks_file",
    "_56kb_upstream_peaks_file",
    "_55kb_upstream_peaks_file",
    "_54kb_upstream_peaks_file",
    "_53kb_upstream_peaks_file",
    "_52kb_upstream_peaks_file",
    "_51kb_upstream_peaks_file",
    "_50kb_upstream_peaks_file",
    "_49kb_upstream_peaks_file",
    "_48kb_upstream_peaks_file",
    "_47kb_upstream_peaks_file",
    "_46kb_upstream_peaks_file",
    "_45kb_upstream_peaks_file",
    "_44kb_upstream_peaks_file",
    "_43kb_upstream_peaks_file",
    "_42kb_upstream_peaks_file",
    "_41kb_upstream_peaks_file",
    "_40kb_upstream_peaks_file",
    "_39kb_upstream_peaks_file",
    "_38kb_upstream_peaks_file",
    "_37kb_upstream_peaks_file",
    "_36kb_upstream_peaks_file",
    "_35kb_upstream_peaks_file",
    "_34kb_upstream_peaks_file",
    "_33kb_upstream_peaks_file",
    "_32kb_upstream_peaks_file",
    "_31kb_upstream_peaks_file",
    "_30kb_upstream_peaks_file",
    "_29kb_upstream_peaks_file",
    "_28kb_upstream_peaks_file",
    "_27kb_upstream_peaks_file",
    "_26kb_upstream_peaks_file",
    "_25kb_upstream_peaks_file",
    "_24kb_upstream_peaks_file",
    "_23kb_upstream_peaks_file",
    "_22kb_upstream_peaks_file",
    "_21kb_upstream_peaks_file",
    "_20kb_upstream_peaks_file",
    "_19kb_upstream_peaks_file",
    "_18kb_upstream_peaks_file",
    "_17kb_upstream_peaks_file",
    "_16kb_upstream_peaks_file",
    "_15kb_upstream_peaks_file",
    "_14kb_upstream_peaks_file",
    "_13kb_upstream_peaks_file",
    "_12kb_upstream_peaks_file",
    "_11kb_upstream_peaks_file",
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
    "_11kb_downstream_peaks_file",
    "_12kb_downstream_peaks_file",
    "_13kb_downstream_peaks_file",
    "_14kb_downstream_peaks_file",
    "_15kb_downstream_peaks_file",
    "_16kb_downstream_peaks_file",
    "_17kb_downstream_peaks_file",
    "_18kb_downstream_peaks_file",
    "_19kb_downstream_peaks_file",
    "_20kb_downstream_peaks_file",
    "_21kb_downstream_peaks_file",
    "_22kb_downstream_peaks_file",
    "_23kb_downstream_peaks_file",
    "_24kb_downstream_peaks_file",
    "_25kb_downstream_peaks_file",
    "_26kb_downstream_peaks_file",
    "_27kb_downstream_peaks_file",
    "_28kb_downstream_peaks_file",
    "_29kb_downstream_peaks_file",
    "_30kb_downstream_peaks_file",
    "_31kb_downstream_peaks_file",
    "_32kb_downstream_peaks_file",
    "_33kb_downstream_peaks_file",
    "_34kb_downstream_peaks_file",
    "_35kb_downstream_peaks_file",
    "_36kb_downstream_peaks_file",
    "_37kb_downstream_peaks_file",
    "_38kb_downstream_peaks_file",
    "_39kb_downstream_peaks_file",
    "_40kb_downstream_peaks_file",
    "_41kb_downstream_peaks_file",
    "_42kb_downstream_peaks_file",
    "_43kb_downstream_peaks_file",
    "_44kb_downstream_peaks_file",
    "_45kb_downstream_peaks_file",
    "_46kb_downstream_peaks_file",
    "_47kb_downstream_peaks_file",
    "_48kb_downstream_peaks_file",
    "_49kb_downstream_peaks_file",
    "_50kb_downstream_peaks_file",
    "_51kb_downstream_peaks_file",
    "_52kb_downstream_peaks_file",
    "_53kb_downstream_peaks_file",
    "_54kb_downstream_peaks_file",
    "_55kb_downstream_peaks_file",
    "_56kb_downstream_peaks_file",
    "_57kb_downstream_peaks_file",
    "_58kb_downstream_peaks_file",
    "_59kb_downstream_peaks_file",
    "_60kb_downstream_peaks_file",
    "_61kb_downstream_peaks_file",
    "_62kb_downstream_peaks_file",
    "_63kb_downstream_peaks_file",
    "_64kb_downstream_peaks_file",
    "_65kb_downstream_peaks_file",
    "_66kb_downstream_peaks_file",
    "_67kb_downstream_peaks_file",
    "_68kb_downstream_peaks_file",
    "_69kb_downstream_peaks_file",
    "_70kb_downstream_peaks_file",
    "_71kb_downstream_peaks_file",
    "_72kb_downstream_peaks_file",
    "_73kb_downstream_peaks_file",
    "_74kb_downstream_peaks_file",
    "_75kb_downstream_peaks_file",
    "_76kb_downstream_peaks_file",
    "_77kb_downstream_peaks_file",
    "_78kb_downstream_peaks_file",
    "_79kb_downstream_peaks_file",
    "_80kb_downstream_peaks_file",
    "_81kb_downstream_peaks_file",
    "_82kb_downstream_peaks_file",
    "_83kb_downstream_peaks_file",
    "_84kb_downstream_peaks_file",
    "_85kb_downstream_peaks_file",
    "_86kb_downstream_peaks_file",
    "_87kb_downstream_peaks_file",
    "_88kb_downstream_peaks_file",
    "_89kb_downstream_peaks_file",
    "_90kb_downstream_peaks_file",
    "_91kb_downstream_peaks_file",
    "_92kb_downstream_peaks_file",
    "_93kb_downstream_peaks_file",
    "_94kb_downstream_peaks_file",
    "_95kb_downstream_peaks_file",
    "_96kb_downstream_peaks_file",
    "_97kb_downstream_peaks_file",
    "_98kb_downstream_peaks_file",
    "_99kb_downstream_peaks_file",
    "_100kb_downstream_peaks_file",
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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-04 08:44:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SbIyLKilqYSfxB8M1cU1oA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
