package Net::Twitter::FriendFinder::From::Twitter;

use strict;
use warnings;
use base qw/Net::Twitter::FriendFinder::From/;
use Web::Scraper;
use URI;
use URI::Escape;

our $ORDER_SCORE = 30;
my $url = "http://twitter.com/tw/search/users?q=%s&page=%d";

sub search {
    my $self     = shift;
    my $keyword  = shift;

    my $coverage = $self->{coverage};
    my $handicap = $self->{handicap};

    $keyword = URI::Escape::uri_escape( $keyword );
    $keyword =~ s/%20/+/g;

    my $ws0 = scraper {
        process "div.user_search > div > a.screen_name > span.detail",
        description => 'TEXT',
    };
    my $ws1 = scraper {
        process "div#results > div.user_search",
        'ids[]' => $ws0,
    };

    my $data = {}; 
    my $order_point = $ORDER_SCORE;
    for( my $page = 1 ; $page <= $coverage ; $page++ ) {
        my $target_uri = sprintf( $url , $keyword , $page )  ;
        my $res = $ws1->scrape( URI->new( $target_uri ) );

        for my $item ( @{ $res->{ids} } ) {
            my  $name  = $item->{description};
            next unless defined $name;
            my $score = $order_point * $handicap ;
            $data->{ $name } = $score;
            $order_point-- if $order_point > 0 ;
            
        }
    }

    return $data;
}

1;

=head1 NAME

Net::Twitter::FriendFinder::From::Twitter - Search from twitter people search.

=head1 SYNOPSYS


   use strict;
   use warnings;
   use FindBin::libs;
   use Net::Twitter::FriendFinder;
   
   
    my $tf 
       = Net::Twitter::FriendFinder->new({ 
            from => {
               Twitter => { coverage => 5 },
            }
         });
   
       $tf->search('perl');
       $tf->show();

=head1 DESCRIPTION

Find twitter friends from twitter people search 

e.g.  http://twitter.com/tw/search/users?q=perl

=head1 coverage

 coverage = 20 entry.

So if you set 

 coverage => 5,

then 20 * 5 = 100. means try to find twitter friend from 100 entry.

=head1 MODULE

=head2 search

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com>

=cut
