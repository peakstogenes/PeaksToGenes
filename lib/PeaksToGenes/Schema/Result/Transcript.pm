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

=head2 C<transcript_unique>

=over 4

=item * L</transcript>

=back

=cut

__PACKAGE__->add_unique_constraint("transcript_unique", ["transcript"]);

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-05 21:56:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZxRjdE8IixvttiHqV80sWg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;