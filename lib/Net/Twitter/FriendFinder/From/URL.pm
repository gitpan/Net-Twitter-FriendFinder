package Net::Twitter::FriendFinder::From::URL;

use strict;
use warnings;
use base qw/Net::Twitter::FriendFinder::From/;
use Web::Scraper;
use URI;

our $ORDER_SCORE = 30;

sub search {
    my $self = shift;
    my $url  = shift;

    my $handicap = $self->{handicap};

    my $scrap = scraper {
        process "a",
        'url[]' => '@href',
    };

    my $res = $scrap->scrape( URI->new( $url ) );

    my $data = {};
    my $order_point = $ORDER_SCORE;
    for my $url ( @{ $res->{url} } ) {
        if( $url->as_string =~ /^(http|https):\/\/(www\.|)twitter\.com/  ) {
             my ( $name ) = $url->as_string =~ m|twitter.com/(\w+)|;
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

Net::Twitter::FriendFinder::From::URL - Find Twitter Friend from URL

=head1 SYNOPSYS

use Net::Twitter::FriendFinder;
 my $tf 
    = Net::Twitter::FriendFinder->new({ 
        from => {
            'URL' => {},
        }
      });
    $tf->search( 'http://twitter.g.hatena.ne.jp/keyword/Friends%e7%99%bb%e9%8c%b2%e3%81%94%e8%87%aa%e7%94%b1%e3%81%ab%20Part3' );
    $tf->show();

=head1 DESCRIPTION

seach your choice link and try to find a tag which has link to twitter pgae.

=head1 MODULE

=head2 search

set url you want to search.

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com>

=cut
