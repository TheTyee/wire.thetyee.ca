#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../local/lib/perl5";
use Modern::Perl '2013';
use utf8::all;
use Wires::Schema;

use Config::JFDI;
use Data::Dumper;
use Mojo::UserAgent;
use Mojo::URL;
use Try::Tiny;

# Get the configuration mode
my $mode   = $ARGV[0];
die "You forgot the mode" unless $mode;

my $conf   = Config::JFDI->new( name => "app.$mode", path => "$Bin/../" );
my $config = $conf->get;
my $api_key = $config->{'sharedcount_api_key'};

my $API = 'https://free.sharedcount.com/url';

my $dbh = _dbh();

# TODO  Limit this to items less than some number of days old
my @items = $dbh->resultset( 'Item' )->search({}, { order_by => { -desc => 'pubdate' }})->all();

for my $item ( @items ) {
    my $ua = Mojo::UserAgent->new;
    my $counts
        = $ua->max_redirects( 5 )->get( $API . '?url=' . $item->url . '&apikey=' . $api_key => { DNT => 1 } )
        ->res->json;
    if ( !$counts->{'Error'} ) {
        say "Updated item id: " . $item->id . ': ' . $item->url if $mode eq 'development';
        say Dumper( $counts );
        $item->count_tw( $counts->{'Twitter'} or '0' );
        $item->count_su( $counts->{'StumbleUpon'} or '0' );
        $item->count_go( $counts->{'GooglePlusOne'} or '0' );
        $item->count_li( $counts->{'LinkedIn'} or '0' );
        $item->count_fb( $counts->{'Facebook'}{'total_count'} or '0' );
        $item->update;
    } else {
        say Dumper( $counts->{'Error'} );
    }
}

sub _dbh {
    my $schema = Wires::Schema->connect( $config->{'pg_dsn'},
        $config->{'pg_user'}, $config->{'pg_pass'}, );
    return $schema;
}
