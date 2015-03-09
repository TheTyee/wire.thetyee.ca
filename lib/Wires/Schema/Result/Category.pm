use utf8;
package Wires::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Wires::Schema::Result::Category

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

=head1 TABLE: C<categories>

=cut

__PACKAGE__->table("categories");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 status

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "status",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 sources

Type: has_many

Related object: L<Wires::Schema::Result::Source>

=cut

__PACKAGE__->has_many(
  "sources",
  "Wires::Schema::Result::Source",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2014-08-06 17:09:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BqtT11owr+TbRa9sBqParQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->table("wire.categories");
1;
