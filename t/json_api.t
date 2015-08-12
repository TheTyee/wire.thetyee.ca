use FindBin;
use lib "$FindBin::Bin/../local/lib/perl5";
#use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Mojo;
use Data::Dumper;
use DateTime;

# Include application
require "$FindBin::Bin/../app.pl";

my $t = Test::Mojo->new;
$t->ua->max_redirects( 1 );

# TODO move to seperate HTML test
# HTML/XML
# $t->get_ok('/index.html')->status_is(200)->text_is('title' => 'BC Blogs');
#
#
# JSON API
#

#########################
# ITEMS
#########################
# Basic get for /items
$t->get_ok( '/items.json' )->status_is( 200, 'Right status for /items.json' );

# Check for an array with 10 objects
my $items = $t->ua->get( '/items.json' )->res->json;
ok( @$items == 20, "Got an array of 10 items back" );

# Check the ?limit paramater
my $limit = $t->ua->get( '/items.json?limit=30' )->res->json;
ok( @$limit == 30, "Got an array of 20 items back" );

# Check the ?page paramater
my $page2 = $t->ua->get( '/items.json?page=2' )->res->json( '/0/title' );
my $page1 = $t->ua->get( '/items.json?page=1' )->res->json( '/0/title' );
ok( $page2 ne $page1, "Page 2 is different than page 1" );

# POST/CREATE a new item
my $dt   = DateTime->now();
my $item = $t->post_ok(
    '/items' => json => {
        title       => 'Test item title',
        url         => 'http://test.com',
        description => 'Test item description',
        content     => '',
        author      => '',
        pubdate     => $dt->ymd
    }
)->status_is( 200 )->json_like( '/id' => qr/^\d+$/ );
my $item_id = $item->tx->res->json( '/id' );

# PUT/UPDATE an item
$t->put_ok(
    "/items/$item_id" => json => { title => 'Test item title updated' } )
    ->status_is( 200 )->json_like( '/id' => qr/^\d+$/ );

# Check the update
$t->get_ok( "/items/$item_id.json" )->status_is( 200 )
    ->json_like( '/title' => qr/updated/, 'Item title was updated' );

# DELETE an item
$t->delete_ok( "/items/$item_id" )->status_is( 200 )
    ->content_like( qr/deleted/, "Item deleted" );

#########################
# SOURCES
#########################
# Basic get for /sources
$t->get_ok( '/sources.json' )
    ->status_is( 200, 'Right status for /sources.json' );

my $sources = $t->ua->get( '/sources.json' )->res->json;
ok( @$sources > 0, "Got an array of sources back" );
ok( $sources->[0]->{'name'} lt $sources->[1]->{'name'},
    "Results are sorted ascending by name" );

$t->get_ok( '/sources.json?category=ad' )
    ->status_is( 200, 'Right status for /sources.json?category=ab' );

# Check that the ?category paramater returns different results
my $cat1 = $t->ua->get( '/sources.json?category=ad' )->res->json( '/0/name' );
my $cat2 = $t->ua->get( '/sources.json?category=au' )->res->json( '/0/name' );
ok( $cat1 ne $cat2, "Category 1 has different results than Category 2" );

# Basic get for a single source, /sources/1
$t->get_ok( '/sources/10.json' )
    ->status_is( 200, 'Right status for /sources/1' )
    ->json_has( '/name',        'Source has a name' )
    ->json_has( '/url',         'Source has a url' )
    ->json_has( '/description', 'Source has a description' );

# POST/CREATE a new source
my $source = $t->post_ok(
    '/sources' => json => {
        name        => 'Test source',
        url         => 'http://test.com',
        description => 'Test description',
        category    => 'ad'
    }
)->status_is( 200 )->json_like( '/id' => qr/^\d+$/ );

#ok($source eq '', "Source is " . Dumper( $source->tx->res->json ));
my $source_id = $source->tx->res->json( '/id' );

# PUT/UPDATE
$t->put_ok(
    "/sources/$source_id",
    => json => {
        name        => 'Test source udpated',
        url         => 'http://test.com',
        description => 'Test description',
        category    => 'ad'
    }
)->status_is( 200 )->json_like( '/id' => qr/^\d+$/ );
#
# DELETE
$t->delete_ok( "/sources/$source_id" )->status_is( 200 )
    ->content_like( qr/deleted/, "Source deleted" );

done_testing();
