use utf8;

package Wires::Schema::ResultSet::Item;

use strict;
use warnings;
use DateTime;
use parent 'DBIx::Class::ResultSet';

sub get_item {
    my ( $self, $id ) = @_;
    my $schema = $self->result_source->schema;
    my $item = $self->search( { id => $id },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } )->single;
    return $item;
}

sub get_items {
    my ( $self, $category, $page, $limit, $source_id ) = @_;
    my $schema = $self->result_source->schema;
    my $dtf = $schema->storage->datetime_parser;
    my $now = DateTime->now( time_zone => 'America/Vancouver' );
    my @items = $self->search(
        {   (   defined $category
                ? ( 'source.category' => $category, )
                : ()
            ),
            (   defined $source_id
                ? ( 'source.id' => $source_id, )
                : ()
            ),
            pubdate => { '<=' => $dtf->format_datetime($now) }, # Don't return items from the future! :)
        },
        {   page => $page || 1,     # page to return (default: 1)
            rows => $limit || 20,    # number of results per page (default: 50)
            order_by => { -desc => 'pubdate' },
            join => { source => 'category' },
            #'+select' => [ 'category.name' ],
            #'+as'     => [ 'cateogry_name'],
            #join     => [qw/ source /],
            '+select' => [ 'source.name', 'source.description', 'source.category', 'category.name' ],
            '+as'     => [ 'source_name', 'source_desc', 'category', 'category_name' ],
            # Recommended way to send simple data to a template vs. sending the ResultSet object
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    );
    return \@items;
}

sub get_items_hot {
    my ( $self, $category, $page, $limit ) = @_;
    my $schema = $self->result_source->schema;
    my $dtf = $schema->storage->datetime_parser;
    my $now = DateTime->now( time_zone => 'America/Vancouver' );
    my @items = $self->search(
        {   (   defined $category
                ? ( 'source.category' => $category )
                : ()
            ),
            pubdate => { '<=' => $dtf->format_datetime($now) }, # Don't return items from the future! :)
        },
        {   page => $page,            # page to return (defaults to 1)
            rows => $limit,           # number of results per page
            #join => [qw/ source /],
            join => { source => 'category' },
            '+select' => [ 'source.name', 'source.description', 'source.category', 'category.name' ],
            '+as'     => [ 'source_name', 'source_desc', 'category', 'category_name' ],
            order_by => [
                { -desc => 'count_tw + count_fb + count_go + count_li + count_su' }, { -desc => 'pubdate' }
            ],
            # Recommended way to send simple data to a template vs. sending the ResultSet object
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    );
    return \@items;
}

1;
