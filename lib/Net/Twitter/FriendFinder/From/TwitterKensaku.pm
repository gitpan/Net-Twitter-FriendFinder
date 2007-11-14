package Net::Twitter::FriendFinder::From::TwitterKensaku;

use strict;
use warnings;
use base qw/Net::Twitter::FriendFinder::From/;
use Web::Scraper;
use URI;
use URI::Escape;

our $ORDER_SCORE = 30;
my $url = 'http://twitter.1x1.jp/search/?keyword=%s&offset=%d';

sub search {
    my $self     = shift;
    my $keyword  = shift;

    my $coverage = $self->{coverage};
    my $handicap = $self->{handicap};

    $keyword = URI::Escape::uri_escape( $keyword );
    $keyword =~ s/%20/+/g;

    my $ws0 = scraper {
        process "div.pagination > table.list > tbody > tr",
            'list[]' => scraper {
                process '//td[2]', id => 'TEXT';
             },
    };

    my $data = {}; 
    my $order_point = $ORDER_SCORE;
    my $prev_top = '';
    for( my $page = 1 ; $page <= $coverage ; $page++ ) {
        my $target_uri = sprintf( $url , $keyword , $page )  ;
        my $res = $ws0->scrape( URI->new( $target_uri ) );
        
        for my $item ( @{ $res->{list} } ) {
            my  ( $name )  = $item->{id} =~ m|@(\w+)|;
            next unless defined $name;

            # order point + prev point
            my $score = $order_point ;
            $score +=  $data->{ $name } ? $data->{ $name }+1 : 1 ;
            $score = $score * $handicap ;
            $data->{ $name } = $score;
            $order_point-- if $order_point > 0 ;
            
        }
    }

    return $data;
}


1;

=head1 NAME

Net::Twitter::FriendFinder::From::TwitterKensaku - TwitterKensaku

=head1 SYNOPSYS

 use Net::Twitter::FriendFinder;
 my $tf 
    = Net::Twitter::FriendFinder->new({ 
        from => {
            'TwitterKensaku' => { coverage => 2 },
        }
      });

    $tf->search( 'perl' );
    $tf->show();

=head1 DESCRIPTION

get data from http://twitter.1x1.jp/search/ 

This is nice site.

=head1 METHOD

=head2 search

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com>

=cut
