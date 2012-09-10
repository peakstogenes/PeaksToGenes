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

=head2 _100kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _99kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _98kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _97kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _96kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _95kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _94kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _93kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _92kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _91kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _90kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _89kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _88kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _87kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _86kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _85kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _84kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _83kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _82kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _81kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _80kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _79kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _78kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _77kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _76kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _75kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _74kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _73kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _72kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _71kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _70kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _69kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _68kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _67kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _66kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _65kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _64kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _63kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _62kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _61kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _60kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _59kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _58kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _57kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _56kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _55kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _54kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _53kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _52kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _51kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _50kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _49kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _48kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _47kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _46kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _45kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _44kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _43kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _42kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _41kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _40kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _39kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _38kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _37kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _36kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _35kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _34kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _33kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _32kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _31kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _30kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _29kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _28kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _27kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _26kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _25kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _24kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _23kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _22kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _21kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _20kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _19kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _18kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _17kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _16kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _15kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _14kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _13kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _12kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _11kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _10kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _9kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _8kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _7kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _6kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _5kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _4kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _3kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _2kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _1kb_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _5prime_utr_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _exons_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _introns_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _3prime_utr_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _1kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _2kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _3kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _4kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _5kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _6kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _7kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _8kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _9kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _10kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _11kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _12kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _13kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _14kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _15kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _16kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _17kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _18kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _19kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _20kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _21kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _22kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _23kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _24kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _25kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _26kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _27kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _28kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _29kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _30kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _31kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _32kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _33kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _34kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _35kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _36kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _37kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _38kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _39kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _40kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _41kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _42kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _43kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _44kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _45kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _46kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _47kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _48kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _49kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _50kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _51kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _52kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _53kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _54kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _55kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _56kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _57kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _58kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _59kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _60kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _61kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _62kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _63kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _64kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _65kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _66kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _67kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _68kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _69kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _70kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _71kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _72kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _73kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _74kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _75kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _76kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _77kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _78kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _79kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _80kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _81kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _82kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _83kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _84kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _85kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _86kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _87kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _88kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _89kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _90kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _91kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _92kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _93kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _94kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _95kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _96kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _97kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _98kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _99kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _100kb_downstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _100kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _99kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _98kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _97kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _96kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _95kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _94kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _93kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _92kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _91kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _90kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _89kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _88kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _87kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _86kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _85kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _84kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _83kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _82kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _81kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _80kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _79kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _78kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _77kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _76kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _75kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _74kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _73kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _72kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _71kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _70kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _69kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _68kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _67kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _66kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _65kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _64kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _63kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _62kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _61kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _60kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _59kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _58kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _57kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _56kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _55kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _54kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _53kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _52kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _51kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _50kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _49kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _48kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _47kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _46kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _45kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _44kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _43kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _42kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _41kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _40kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _39kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _38kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _37kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _36kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _35kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _34kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _33kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _32kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _31kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _30kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _29kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _28kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _27kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _26kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _25kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _24kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _23kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _22kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _21kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _20kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _19kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _18kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _17kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _16kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _15kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _14kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _13kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _12kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _11kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _10kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _9kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _8kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _7kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _6kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _5kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _4kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _3kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _2kb_upstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _1kb_upstream_peaks_information

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

=head2 _1kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _2kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _3kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _4kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _5kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _6kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _7kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _8kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _9kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _10kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _11kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _12kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _13kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _14kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _15kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _16kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _17kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _18kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _19kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _20kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _21kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _22kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _23kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _24kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _25kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _26kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _27kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _28kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _29kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _30kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _31kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _32kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _33kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _34kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _35kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _36kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _37kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _38kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _39kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _40kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _41kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _42kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _43kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _44kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _45kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _46kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _47kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _48kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _49kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _50kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _51kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _52kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _53kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _54kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _55kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _56kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _57kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _58kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _59kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _60kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _61kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _62kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _63kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _64kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _65kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _66kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _67kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _68kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _69kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _70kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _71kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _72kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _73kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _74kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _75kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _76kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _77kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _78kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _79kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _80kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _81kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _82kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _83kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _84kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _85kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _86kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _87kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _88kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _89kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _90kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _91kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _92kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _93kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _94kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _95kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _96kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _97kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _98kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _99kb_downstream_peaks_information

  data_type: 'text'
  is_nullable: 1

=head2 _100kb_downstream_peaks_information

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
  "_100kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_99kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_98kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_97kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_96kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_95kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_94kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_93kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_92kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_91kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_90kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_89kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_88kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_87kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_86kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_85kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_84kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_83kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_82kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_81kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_80kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_79kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_78kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_77kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_76kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_75kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_74kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_73kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_72kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_71kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_70kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_69kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_68kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_67kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_66kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_65kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_64kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_63kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_62kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_61kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_60kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_59kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_58kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_57kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_56kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_55kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_54kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_53kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_52kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_51kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_50kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_49kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_48kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_47kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_46kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_45kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_44kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_43kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_42kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_41kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_40kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_39kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_38kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_37kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_36kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_35kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_34kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_33kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_32kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_31kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_30kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_29kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_28kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_27kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_26kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_25kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_24kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_23kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_22kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_21kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_20kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_19kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_18kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_17kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_16kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_15kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_14kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_13kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_12kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_11kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_10kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_9kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_8kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_7kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_6kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_5kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_4kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_3kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_2kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_1kb_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_5prime_utr_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_exons_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_introns_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_3prime_utr_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_1kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_2kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_3kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_4kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_5kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_6kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_7kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_8kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_9kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_10kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_11kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_12kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_13kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_14kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_15kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_16kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_17kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_18kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_19kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_20kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_21kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_22kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_23kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_24kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_25kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_26kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_27kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_28kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_29kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_30kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_31kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_32kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_33kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_34kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_35kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_36kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_37kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_38kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_39kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_40kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_41kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_42kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_43kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_44kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_45kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_46kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_47kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_48kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_49kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_50kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_51kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_52kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_53kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_54kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_55kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_56kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_57kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_58kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_59kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_60kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_61kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_62kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_63kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_64kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_65kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_66kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_67kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_68kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_69kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_70kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_71kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_72kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_73kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_74kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_75kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_76kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_77kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_78kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_79kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_80kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_81kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_82kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_83kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_84kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_85kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_86kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_87kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_88kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_89kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_90kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_91kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_92kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_93kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_94kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_95kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_96kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_97kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_98kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_99kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_100kb_downstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_100kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_99kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_98kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_97kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_96kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_95kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_94kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_93kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_92kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_91kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_90kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_89kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_88kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_87kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_86kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_85kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_84kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_83kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_82kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_81kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_80kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_79kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_78kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_77kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_76kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_75kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_74kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_73kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_72kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_71kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_70kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_69kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_68kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_67kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_66kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_65kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_64kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_63kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_62kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_61kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_60kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_59kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_58kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_57kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_56kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_55kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_54kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_53kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_52kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_51kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_50kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_49kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_48kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_47kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_46kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_45kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_44kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_43kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_42kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_41kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_40kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_39kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_38kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_37kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_36kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_35kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_34kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_33kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_32kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_31kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_30kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_29kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_28kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_27kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_26kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_25kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_24kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_23kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_22kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_21kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_20kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_19kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_18kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_17kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_16kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_15kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_14kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_13kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_12kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_11kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_10kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_9kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_8kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_7kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_6kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_4kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_3kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_2kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_1kb_upstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5prime_utr_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_exons_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_introns_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_3prime_utr_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_1kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_2kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_3kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_4kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_5kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_6kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_7kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_8kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_9kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_10kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_11kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_12kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_13kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_14kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_15kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_16kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_17kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_18kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_19kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_20kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_21kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_22kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_23kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_24kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_25kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_26kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_27kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_28kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_29kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_30kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_31kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_32kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_33kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_34kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_35kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_36kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_37kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_38kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_39kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_40kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_41kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_42kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_43kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_44kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_45kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_46kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_47kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_48kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_49kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_50kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_51kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_52kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_53kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_54kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_55kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_56kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_57kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_58kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_59kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_60kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_61kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_62kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_63kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_64kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_65kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_66kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_67kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_68kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_69kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_70kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_71kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_72kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_73kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_74kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_75kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_76kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_77kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_78kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_79kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_80kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_81kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_82kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_83kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_84kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_85kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_86kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_87kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_88kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_89kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_90kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_91kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_92kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_93kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_94kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_95kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_96kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_97kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_98kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_99kb_downstream_peaks_information",
  { data_type => "text", is_nullable => 1 },
  "_100kb_downstream_peaks_information",
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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-09-10 17:08:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/P+nYURfYlzKYP7iVNYMxg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
