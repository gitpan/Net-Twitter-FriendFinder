package Net::Twitter::FriendFinder::From::Google;

use strict;
use warnings;
use base qw/Net::Twitter::FriendFinder::From/;
use Web::Scraper;
use URI;
use URI::Escape;
__PACKAGE__->mk_accessors(qw/lang/);

my $url = "http://www.google.com/search?q=%s+site:.twitter.com&num=%d&start=%d&hl=%s";
our $ORDER_SCORE = 30;

sub search {
    my $self     = shift;
    my $keyword  = shift;

    my $coverage = $self->{coverage};
    my $handicap = $self->{handicap};
    my $lang     = $self->{lang} || '';

    $keyword = URI::Escape::uri_escape( $keyword );
    $keyword =~ s/%20/+/g;
    my $google_url = scraper {
        process "table> tr > td.j > font > span.a",
        description => 'TEXT',
    };

    my $google = scraper {
        process "div.g",
        "urls[]" => $google_url;
    };

    my $data = {};
    my $order_point = $ORDER_SCORE;
    for( my $page = 1 ; $page <= $coverage ; $page++ ) {
        my $target_uri = sprintf( $url , $keyword , 20 , ( $page-1 ) * 20  , $lang )  ;
        my $res = $google->scrape( URI->new( $target_uri ) );

        for my $item ( @{ $res->{urls} } ) {
            my ( $name ) = $item->{description} =~ m|twitter.com/(\w+)/|;
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

Net::Twitter::FriendFinder::From::Google - Search from google.

=head1 SYNOPSYS

   use strict;
   use warnings;
   use FindBin::libs;
   use Net::Twitter::FriendFinder;
   
   
    my $tf 
       = Net::Twitter::FriendFinder->new({ 
            from => {
               Google  => { coverage => 5 , lang => 'ja' },
            }
         });
   
       $tf->search('perl');
       $tf->show();

=head1 DESCRIPTION

Find twitter friends from google search.  

Internally run google search like below.
  
  site:.twitter.com [your keyword]

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
