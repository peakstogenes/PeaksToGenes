use utf8;
package PeaksToGenes::Schema::Result::Transcript;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::Transcript

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<transcripts>

=cut

__PACKAGE__->table("transcripts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 genome_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 transcript

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "transcript",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<genome_id_transcript_unique>

=over 4

=item * L</genome_id>

=item * L</transcript>

=back

=cut

__PACKAGE__->add_unique_constraint("genome_id_transcript_unique", ["genome_id", "transcript"]);

=head1 RELATIONS

=head2 genome

Type: belongs_to

Related object: L<PeaksToGenes::Schema::Result::AvailableGenome>

=cut

__PACKAGE__->belongs_to(
  "genome",
  "PeaksToGenes::Schema::Result::AvailableGenome",
  { id => "genome_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-02 12:42:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0tx83PQdjJeRTZ3r8ozDFg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
