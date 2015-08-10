use utf8;

package Wires::Schema::ResultSet::Source;

use strict;
use warnings;
use parent 'DBIx::Class::ResultSet';

sub get_sources {
    my ( $self, $category, $page, $limit ) = @_;
    my $schema = $self->result_source->schema;
    my @sources = $self->search(
        {   
            (   defined $category
                ? ( category => $category )
                : ()
            ),
            'me.status' => 'active',
        },
        {   
            #group_by => [qw/ category name  id /], # This is not working because of overlapping table names
            page => $page || 1,     # page to return (default: 1)
            rows => $limit || 10,    # number of results per page (default: 50)
            #order_by => { -asc => 'category' },
            order_by => { -asc => 'me.name' },
            join => [qw / category /],
            '+select' => [ 'category.name'],
            '+as'     => [ 'category_name' ],
            # Recommended way to send simple data to a template vs. sending the ResultSet object
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        }
    );
    #my @items = $self->search(
        #{   (   defined $category
                #? ( 'source.category' => $category, )
                #: ()
            #),
            #pubdate => { '<=' => $dtf->format_datetime($now) }, # Don't return items from the future! :)
        #},
        #{   page => $page || 1,     # page to return (default: 1)
            #rows => $limit || 10,    # number of results per page (default: 50)
            #order_by => { -desc => 'pubdate' },
            #join     => [qw/ source /],
            #'+select' => [ 'source.name', 'source.description' ],
            #'+as'     => [ 'source_name', 'source_desc' ],
            ## Recommended way to send simple data to a template vs. sending the ResultSet object
            #result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        #}
    #);
    return \@sources;
}

sub get_source {
    my ( $self, $id ) = @_;
    my $schema = $self->result_source->schema;
    my $source = $self->search( { 'me.id' => $id },
        {
            join => [qw / category /],
            '+select' => [ 'category.name'],
            '+as'     => [ 'category_name' ],
            result_class => 'DBIx::Class::ResultClass::HashRefInflator' } )->single;
    my $items    = $schema->resultset( 'Item' )
        ->get_items( undef, undef, undef, undef, $id );
        $source->{'items'} = $items;
    return $source;
}

1;
