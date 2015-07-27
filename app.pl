#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/local/lib/perl5";

use Mojolicious::Lite;
use Mojo::JSON;
use JSON;
use Data::Dumper;
use Try::Tiny;
use Wires::Schema;
use DBIx::Class::ResultClass::HashRefInflator;

# Development plugins
# Documentation browser under "/perldoc"
plugin 'PODRenderer';

#plugin 'ConsoleLogger';

# Deploy plugins
my $config = plugin 'JSONConfig';

helper schema => sub {
    my $schema = Wires::Schema->connect(
        $config->{'pg_dsn'}, $config->{'pg_user'},
        $config->{'pg_pass'}, { pg_enable_utf8 => 1 }
    );
    return $schema;
};

get '/' => sub {
    my $self    = shift;
    my $items   = $self->schema->resultset( 'Item' )->get_items();
    my $sources = $self->schema->resultset( 'Source' )->get_sources();
    my $cats    = $self->schema->resultset( 'Category' )->get_categories();
    my $json
        = JSON->new->allow_nonref;    # Using JSON module for proper encoding
    my $items_json   = $json->encode( $items );
    my $sources_json = $json->encode( $sources );
    my $cats_json    = $json->encode( $cats );

    #$self->app->log->debug( $sources_json );

    #my $j = Mojo::JSON->new();
    #my $items_json = $j->encode($items);
    $self->stash(
        {   items   => $items_json,
            sources => $sources_json,
            cats    => $cats_json
        }
    );
    $self->render( 'index' );
};

# Get feed items, with optional limit or page
get '/items' => sub {
    my $self     = shift;
    my $category = $self->param( 'category' ) || undef;
    my $page     = $self->param( 'page' );
    my $limit    = $self->param( 'limit' );
    $self->app->log->debug( $category );
    my $items = $self->schema->resultset( 'Item' )
        ->get_items( $category, $page, $limit );
    $self->respond_to(
        json => sub {
            $self->render( json => $items ), status => 200;
        },
        any => { text => '', status => 204 }
    );
};

# Get one source by id
get '/items/:id' => sub {    # Read one
    my $self = shift;
    my $rs   = $self->schema->resultset( 'Item' );
    my $id   = $self->stash( 'id' );
    my $item = $rs->get_item( $id );
    $self->respond_to(
        json => sub {
            $self->render( json => $item ), status => 200;
        },
        any => { text => '', status => 204 }
    );
};

# POST/CREATE item
post '/items' => sub {    # Create
    my $self   = shift;
    my $schema = $self->schema;
    my $json   = $self->req->json;
    my $item   = $schema->resultset( 'Item' )->create( $json );
    if ( $item ) {
        $self->res->code( 200 );
        $self->render( json => { id => $item->id } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to create item." } );
    }
};

any [ 'put', 'patch' ] => '/items/:id' => sub {    # Update full or partial
    my $self   = shift;
    my $id     = $self->stash( 'id' );
    my $schema = $self->schema;
    my $json   = $self->req->json;
    my $item   = $schema->resultset( 'Item' )->find( $id );
    if ( $item ) {
        my $result = $item->update( $json );
        $self->res->code( 200 );
        $self->render( json => { id => $result->id } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to update source." } );
    }
};

any ['delete'] => '/items/:id' => sub {    # Delete
    my $self   = shift;
    my $id     = $self->stash( 'id' );
    my $schema = $self->schema;
    my $item   = $schema->resultset( 'Item' )->find( $id );
    if ( $item ) {
        my $result = $item->delete;
        $self->res->code( 200 );
        $self->render( json => { text => "Item $id deleted" } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to delete item." } );
    }
};

# Read /sources with optional filter by category
get '/sources' => sub {    # Read collection
    my $self     = shift;
    my $rs       = $self->schema->resultset( 'Source' );
    my $category = $self->param( 'category' );
    my $sources  = $rs->get_sources( $category );

    # Not using this currently...
    my $json
        = JSON->new->allow_nonref;    # Using JSON module for proper encoding
    my $sources_json = $json->encode( $sources );
    $self->stash( sources_json => $sources_json );
    $self->respond_to(
        json => sub {
            $self->render( json => $sources ), status => 200;
        },
        html => sub {
            $self->render( 'sources' );
        }
    );
};

# Get one source by id
get '/sources/:id' => sub {    # Read one
    my $self   = shift;
    my $rs     = $self->schema->resultset( 'Source' );
    my $id     = $self->stash( 'id' );
    my $source = $rs->get_source( $id );
    $self->respond_to(
        json => sub {
            $self->render( json => $source ), status => 200;
        },
        any => { text => '', status => 204 }
    );
};

post '/sources' => sub {    # Create
    my $self   = shift;
    my $schema = $self->schema;
    my $json   = $self->req->json;
    my $source = $schema->resultset( 'Source' )->create( $json );
    if ( $source ) {
        $self->res->code( 200 );
        $self->render( json => { id => $source->id } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to create source." } );
    }
};

any [ 'put', 'patch' ] => '/sources/:id' => sub {    # Update full or partial
    my $self   = shift;
    my $id     = $self->stash( 'id' );
    my $schema = $self->schema;
    my $json   = $self->req->json;
    my $source = $schema->resultset( 'Source' )->find( $id );
    if ( $source ) {
        my $result = $source->update( $json );
        $self->res->code( 200 );
        $self->render( json => { id => $result->id } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to update source." } );
    }
};

any ['delete'] => '/sources/:id' => sub {    # Delete
    my $self   = shift;
    my $id     = $self->stash( 'id' );
    my $schema = $self->schema;
    my $source = $schema->resultset( 'Source' )->find( $id );
    if ( $source ) {
        my $result = $source->delete;
        $self->res->code( 200 );
        $self->render( json => { text => "Source $id deleted" } );
    }
    else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to delete source." } );
    }
};

# Read /categories
get '/categories' => sub {    # Read collection
    my $self = shift;
    my $rs   = $self->schema->resultset( 'Category' );

    #my $category = $self->param( 'category' );
    my $cats = $rs->get_categories();
    my $json
        = JSON->new->allow_nonref;    # Using JSON module for proper encoding
    my $cats_json = $json->encode( $cats );
    $self->respond_to(
        json => sub {
            $self->render( json => $cats_json ), status => 200;
        },
        any => { text => 'No results', status => 204 }
    );
};

# Get one source by id
get '/categories/:id' => sub {        # Read one
    my $self = shift;

    #my $rs     = $self->schema->resultset( 'Source' );
    #my $id     = $self->stash( 'id' );
    #my $source = $rs->get_source( $id );
    #$self->respond_to(
    #json => sub {
    #$self->render( json => $source ), status => 200;
    #},
    #any => { text => '', status => 204 }
    #);
};

post '/categories' => sub {    # Create
    my $self = shift;

    #my $schema = $self->schema;
    #my $json   = $self->req->json;
    #my $source = $schema->resultset( 'Source' )->create( $json );
    #if ( $source ) {
    #$self->res->code( 200 );
    #$self->render( json => { id => $source->id } );
    #}
    #else {
    #$self->res->code( 422 );
    #$self->render( json => { error => "Unable to create source." } );
    #}
};

any [ 'put', 'patch' ] => '/categories/:id' => sub {  # Update full or partial
    my $self = shift;
    my $id     = $self->stash( 'id' );
    my $schema = $self->schema;
    my $json   = $self->req->json;
    my $category = $schema->resultset( 'Category' )->find( $id );
    if ( $category ) {
        my $result = $category->update( $json );
        $self->res->code( 200 );
        $self->render( json => { id => $result->id } );
    } else {
        $self->res->code( 422 );
        $self->render( json => { error => "Unable to update category" } );
    }
};

any ['delete'] => '/categories/:id' => sub {    # Delete
    my $self = shift;

    #my $id     = $self->stash( 'id' );
    #my $schema = $self->schema;
    #my $source = $schema->resultset( 'Source' )->find( $id );
    #if ( $source ) {
    #my $result = $source->delete;
    #$self->res->code( 200 );
    #$self->render( json => { text => "Source $id deleted" } );
    #}
    #else {
    #$self->res->code( 422 );
    #$self->render( json => { error => "Unable to delete source." } );
    #}
};

# Get hot items, with optional limit or page
get '/hot' => sub {
    my $self     = shift;
    my $category = $self->param( 'category' ) || undef;
    my $page     = $self->param( 'page' );
    my $limit    = $self->param( 'limit' );
    my $items    = $self->schema->resultset( 'Item' )
        ->get_items_hot( $category, $page, $limit );
    $self->respond_to(
        json => sub {
            $self->render( json => $items ), status => 200;
        },
        any => { text => '', status => 204 }
    );
};

app->secrets( [ $config->{'app_secret'} ] );
app->start;
