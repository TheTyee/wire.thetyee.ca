#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../lib";
use Modern::Perl '2013';
use utf8::all;
use Wires::Schema;

use Config::JFDI;
use Data::Dumper;
use Mojo::UserAgent;
use Try::Tiny;

# Get the configuration mode
my $mode = $ARGV[0];
die "You forgot the mode" unless $mode;

my $conf = Config::JFDI->new( name => "app.$mode", path => "$Bin/../" );
my $config = $conf->get;

my $dbh = _dbh();
use constant URL => 'http://thetyee.ca/BCBlogs/';

main();

sub main {
    my $res          = get_page_to_scrape( URL );
    my $dom          = scrape_page( $res );
    my $sections_col = get_sections( $dom );
    my @categories;
    my @sources;
    for my $section ( $sections_col->each ) {
        my $category = {
            name    => _get_category_name( $section ),
            id      => _get_category_id( $section ),
            #sources => get_sources( $section ),
        };
        if ( $category->{'id'} ne 'me' ) { 
            push @categories, $category;
            push @sources, @{ get_sources( $section, $category ) };
        }
    }
    for my $category ( @categories ) {
        try {
            my $result = $dbh->resultset( 'Category' )->find_or_new( $category );
            if ($result->in_storage) {
                say "Already had category: " . $result->id;
            }
            else {
                $result->insert;
                say "Inserting new category: " .  $result->id;
            }
        } catch {
            warn "caught error: $_";
        }
    }
    #print Dumper( \@sources );
    for my $source ( @sources ) {
        try {
            my $result = $dbh->resultset( 'Source' )->find_or_new( $source );
            if ($result->in_storage) {
                say "Already had source: " . $result->id;
            }
            else {
                $result->insert;
                say "Inserting new source: " .  $result->id;
            }
        } catch {
            warn "caught error: $_";
        }
    }
}

sub get_page_to_scrape {
    my $url = shift;
    my $ua  = Mojo::UserAgent->new;
    my $res = $ua->get( $url )->res->body;
    return $res;
}

sub scrape_page {
    my $html = shift;
    my $dom  = Mojo::DOM->new( $html );
    return $dom;
}

sub get_sections {
    my $dom                 = shift;
    my $sections_collection = $dom->find( '.section' );
    return $sections_collection;
}

sub _get_category_name {
    my $section       = shift;
    my $category_name = $section->at( 'h3' )->text;
    return $category_name;
}

sub _get_category_id {
    my $section     = shift;
    my $category_id = $section->{'id'};
    return $category_id;
}

sub get_sources {
    my $section  = shift;
    my $category = shift;
    my $para_col = $section->find( 'p' );
    my @sources;
    for my $p ( $para_col->each ) {
        next unless $p->text && $p->at('a');
        my $source = {
            name        => _get_source_name( $p ),
            description => _get_source_description( $p ),
            url         => _get_source_link( $p ),
            category    => $category->{'id'},
        };
        push @sources, $source;
    }
    return \@sources;
}

sub _get_source_name {
    my $p           = shift;
    my $source_name = $p->at( 'a' )->text;
    return $source_name;
}

sub _get_source_description {
    my $p                  = shift;
    my $source_description = $p->text;
    $source_description =~ s/: //ig; # Strip out the colon
    return $source_description;
}

sub _get_source_link {
    my $p    = shift;
    my $link = $p->at( 'a' )->{'href'};
    return $link;
}

sub _dbh {
    my $schema = Wires::Schema->connect( $config->{'pg_dsn'},
        $config->{'pg_user'}, $config->{'pg_pass'}, );
    return $schema;
}
