use utf8;
package PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PeaksToGenes::Schema::Result::UpstreamNumberOfPeaks

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<upstream_number_of_peaks>

=cut

__PACKAGE__->table("upstream_number_of_peaks");

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

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gene

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 _10_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _9_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _8_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _7_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _6_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _5_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _4_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _3_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _2_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=head2 _1_steps_upstream_number_of_peaks

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "genome_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "name",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gene",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "_10_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_9_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_8_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_7_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_6_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_5_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_4_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_3_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_2_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
  "_1_steps_upstream_number_of_peaks",
  { data_type => "real", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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

=head2 name

Type: belongs_to

Related object: L<PeaksToGenes::Schema::Result::Experiment>

=cut

__PACKAGE__->belongs_to(
  "name",
  "PeaksToGenes::Schema::Result::Experiment",
  { id => "name" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-08-02 12:42:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vodDzeD41DucaLKcK0oBcg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
