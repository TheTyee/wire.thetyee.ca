use utf8;
package Wires::Schema::Result::Item;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wires::Schema::Result::Item

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<items>

=cut

__PACKAGE__->table("items");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'wire.items_id_seq'

=head2 url

  data_type: 'text'
  is_nullable: 0

=head2 title

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 author

  data_type: 'text'
  is_nullable: 1

=head2 image

  data_type: 'text'
  is_nullable: 1

=head2 pubdate

  data_type: 'timestamp'
  is_nullable: 0

=head2 count_tw

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_su

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_fb

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_li

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 count_go

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 status

  data_type: 'text'
  default_value: 'active'
  is_nullable: 1

=head2 source_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "wire.items_id_seq",
  },
  "url",
  { data_type => "text", is_nullable => 0 },
  "title",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "author",
  { data_type => "text", is_nullable => 1 },
  "image",
  { data_type => "text", is_nullable => 1 },
  "pubdate",
  { data_type => "timestamp", is_nullable => 0 },
  "count_tw",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_su",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_fb",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_li",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "count_go",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "status",
  { data_type => "text", default_value => "active", is_nullable => 1 },
  "source_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<items_url_key>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("items_url_key", ["url"]);

=head1 RELATIONS

=head2 source

Type: belongs_to

Related object: L<Wires::Schema::Result::Source>

=cut

__PACKAGE__->belongs_to(
  "source",
  "Wires::Schema::Result::Source",
  { id => "source_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-26 18:51:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v3xEnDw/rmKh8TRTVnNRqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->table("wire.items");

1;

