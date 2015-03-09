use utf8;
package Wires::Schema::Result::Feed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wires::Schema::Result::Feed

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

=head1 TABLE: C<feeds>

=cut

__PACKAGE__->table("feeds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'wires.feeds_id_seq'

=head2 url

  data_type: 'text'
  is_nullable: 0

=head2 last_updated

  data_type: 'timestamp'
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
    sequence          => "wires.feeds_id_seq",
  },
  "url",
  { data_type => "text", is_nullable => 0 },
  "last_updated",
  { data_type => "timestamp", is_nullable => 1 },
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

=head2 C<feeds_url_key>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("feeds_url_key", ["url"]);

=head1 RELATIONS

=head2 items

Type: has_many

Related object: L<Wires::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items",
  "Wires::Schema::Result::Item",
  { "foreign.feed_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-08-03 15:31:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bp9uSPQhZ3nTj4B9Adykfg

__PACKAGE__->table("wire.feeds");

1;
