use utf8;
package PeaksToGenes::Schema::Result::ChromosomeSize;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::ChromosomeSize

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<chromosome_sizes>

=cut

__PACKAGE__->table("chromosome_sizes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 chromosome_sizes_file

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "chromosome_sizes_file",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 chromosome_size_file

Type: belongs_to

Related object: L<PeaksToGenes::Schema::Result::AvailableGenome>

=cut

__PACKAGE__->belongs_to(
  "chromosome_size_file",
  "PeaksToGenes::Schema::Result::AvailableGenome",
  { id => "chromosome_sizes_file" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-20 11:50:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OY1KbuP031DmTnvGqHKCwQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
