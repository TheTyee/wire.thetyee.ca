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
use DateTime;
use HTTP::Date;
use HTML::Content::Extractor;
use Lingua::EN::Summarize;
use Mojo::UserAgent;
use Try::Tiny;
use XML::FeedPP;

# Get the configuration mode
my $mode   = $ARGV[0];
die "You forgot the mode" unless $mode;

my $conf   = Config::JFDI->new( name => "app.$mode", path => "$Bin/../" );
my $config = $conf->get;
my $dtformat = 'DateTime::Format::HTTP';
my $dbh   = _dbh();
my @sources = $dbh->resultset( 'Source' )->search()->all();

my $source_count = 0;
my $item_count = 0;
for my $source ( @sources ) {
    next unless $source->feed_url;
    say $source->feed_url;
    my $feed_obj = try {
        XML::FeedPP->new( $source->feed_url );
    } catch {
        say "Couldn't load the feed... skipping...";
        $source->update({ status => 'Could not load feed' });
        return;
        next;
    };
    my $status; 
    next unless $feed_obj;
    # TODO next unless channel pubDate is recent
    foreach my $item ( $feed_obj->get_item() ) {
        next if $dbh->resultset( 'Item' )->find({ url => $item->link() });
        next unless $item->title(); # Need titles
        next unless !ref($item->title()) ; # Strings! 
        next unless $item->pubDate();
        my $pubDate = $item->pubDate();
        $pubDate =~ s/^(\d{4}-\d{2}-\d{2}).*$/$1/g;
        my $today = DateTime->now( time_zone => 'floating');
        my $last_week = $today->subtract( days => 30 );
        my $epoch = str2time( $pubDate );
        my $feed_date = DateTime->from_epoch({ epoch => $epoch });
        my $date_cmp = DateTime->compare( $feed_date, $last_week );
        next unless $date_cmp == 1;
        $status = 1;
        my $ua = Mojo::UserAgent->new;
        my $html
            = $ua->max_redirects( 5 )->get( $item->link() => { DNT => 1 } )
            ->res->body;
        my $obj = HTML::Content::Extractor->new();
        $obj->analyze( $html );
        my $main_images = $obj->get_main_images( 1 );

        my $main_text = $obj->get_main_text( 1 );
        my $image     = '';
        if ( $main_images ) {
            my $img = '';
            $img = $main_images->[0]->{'prop'}->{'src'};
            if ( $img && $img =~ m!^http://! ) {
                $image = $img;
            }
        }
        my $doc = {
            url     => $item->link() || '',
            title   => $item->title() || '',
            pubdate => $item->pubDate() || '',
            description => summarize(
                $main_text,
                #filter    => 'html',
                maxlength => 100
            ) || '',
            content => $main_text || '',
            image   => $image || '',
            author  => $item->author() || '',
            source_id => $source->id() || '',
        };
        say $doc->{'title'} if $mode eq 'development';
        _store_item( $doc );
        $item_count++;
    }
        my $dt = DateTime->now();
        $source->update({ feed_updated => $dt->datetime() });
        if ( $status ) { # TODO rethink this logic
            say "Setting status to active";
            $source->update({ status => 'Feed active' });
        } else { 
            $source->update({ status => 'Not active' });
            say "Setting status to not active";
        };
        $source_count++;
}

say "Updated $source_count sources and adding $item_count items on this run.";

sub _dbh {
    my $schema = Wires::Schema->connect( $config->{'pg_dsn'},
        $config->{'pg_user'}, $config->{'pg_pass'}, { pg_enable_utf8 => 1 } );
    return $schema;
}

sub _store_item {
    my $doc = shift;
    #say Dumper( $doc ) if $mode eq 'development';
    my $result;
    try {
        $result = $dbh->txn_do(
            sub {
                my $rs = $dbh->resultset( 'Item' )->find_or_new( {%$doc} );
                unless ( $rs->in_storage ) {
                    $rs->insert;
                }
            }
        );
    }
    catch {
        say "Caught error $_";
    };
    return $result;
}
