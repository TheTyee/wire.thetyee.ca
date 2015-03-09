use utf8;
package Wires::Schema::Result::Source;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wires::Schema::Result::Source

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

=head1 TABLE: C<sources>

=cut

__PACKAGE__->table("sources");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'wires.sources_id_seq'

=head2 url

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 image

  data_type: 'text'
  is_nullable: 1

=head2 category

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 contact_name

  data_type: 'text'
  is_nullable: 1

=head2 contact_email

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'text'
  is_nullable: 1

=head2 source_updated

  data_type: 'timestamp'
  default_value: timezone('utc'::text, now())
  is_nullable: 0

=head2 feed_url

  data_type: 'text'
  is_nullable: 1

=head2 feed_updated

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "wires.sources_id_seq",
  },
  "url",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "image",
  { data_type => "text", is_nullable => 1 },
  "category",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "contact_name",
  { data_type => "text", is_nullable => 1 },
  "contact_email",
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "text", is_nullable => 1 },
  "source_updated",
  {
    data_type     => "timestamp",
    default_value => \"timezone('utc'::text, now())",
    is_nullable   => 0,
  },
  "feed_url",
  { data_type => "text", is_nullable => 1 },
  "feed_updated",
  { data_type => "timestamp", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sources_feed_url_key>

=over 4

=item * L</feed_url>

=back

=cut

__PACKAGE__->add_unique_constraint("sources_feed_url_key", ["feed_url"]);

=head2 C<sources_url_key>

=over 4

=item * L</url>

=back

=cut

__PACKAGE__->add_unique_constraint("sources_url_key", ["url"]);

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<Wires::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Wires::Schema::Result::Category",
  { id => "category" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 items

Type: has_many

Related object: L<Wires::Schema::Result::Item>

=cut

__PACKAGE__->has_many(
  "items",
  "Wires::Schema::Result::Item",
  { "foreign.source_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-08-06 17:09:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m/rrdfG0xvfsEqgNcsexww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->table("wire.sources");
1;
