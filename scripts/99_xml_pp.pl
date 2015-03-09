#!/usr/bin/perl 
#===============================================================================
#
#         FILE: 99_xml_pp.pl
#
#        USAGE: ./99_xml_pp.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
#      COMPANY: 
#      VERSION: 1.0
#      CREATED: 06/08/2014 18:52:35
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use Try::Tiny;
use XML::FeedPP;

   eval { my $feed_obj = XML::FeedPP->new('http://www.obwb.ca/blog/feed/') }; 
   if ( $@ ) { print "Caught an error" };
