#!/usr/bin/env perl

use strict;
use warnings;

use Modern::Perl '2013';
use utf8::all;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Wires::Schema;

use Config::JFDI;
use Data::Dumper;
use Feed::Find;
use Mojo::UserAgent;
use Try::Tiny;
use XML::FeedPP;

# Get the configuration mode
my $mode = $ARGV[0];
die "You forgot the mode" unless $mode;

my $conf
    = Config::JFDI->new( name => "app.$mode", path => "$Bin/../" );
my $config = $conf->get;

my $schema = _dbh();

main();

sub main {
    my $sources = get_sources();
    my $results   = add_feeds( $sources );
    say Dumper( $results );
}

sub get_sources {
   my @sources = $schema->resultset('Source')->search()->all();
   return \@sources;
}

sub add_feeds {
    my $sources = shift;
    my @results;
    for my $source ( @$sources ) {
        say $source->url if $mode eq 'development';
        my $url = $source->url;
        my ( $rss ) = Feed::Find->find( $source->url );
        #my @rss = XML::Feed->find_feeds($url);
        say Dumper( $rss ) if $mode eq 'development';
        #next unless $rss;
        if ( $rss ) {
            my $result = $source->update({ feed_url => $rss });
            push @results, $result;
        } else {
            my $result = $source->update({ status => "No feed found" });
            say "No feed found for $url";
            push @results, $result;
        }
    };
    return \@results;
}

sub _dbh {
    my $schema = Wires::Schema->connect( $config->{'pg_dsn'},
        $config->{'pg_user'}, $config->{'pg_pass'}, );
    return $schema;
};
