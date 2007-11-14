package Net::Twitter::FriendFinder::From::TwitterDiff;

use strict;
use warnings;
use Net::Twitter::Diff;
use base qw/Net::Twitter::FriendFinder::From/;
__PACKAGE__->mk_accessors(qw/username password/);

our $SCORE = 50;

sub search {
    my $self    = shift;
    my $keyword = shift;
    my $diff = Net::Twitter::Diff->new( username => $self->{username} , password => $self->{password} );

    my $screen_names = [];
    if( !defined $keyword ) { 
        my $res = $diff->diff();
        $screen_names = $res->{not_following};
    }
    else {
        my $res = $diff->comp_following( $keyword );
        $screen_names = $res->{not_me};
    }

    my $data = {};
    for my $screen_name ( @{ $screen_names } ) {
        $data->{ $screen_name } = $SCORE * $self->{handicap};
    }

    return $data;

}

1;

=head1 NAME

Net::Twitter::FriendFinder::From::TwitterDiff - search from Net::Twitter::Diff

=head1 SYNOPSYS

use Net::Twitter::FriendFinder;
 my $tf 
    = Net::Twitter::FriendFinder->new({ 
        from => {
            'TwitterDiff' => { username => 'tomyhero' , password => '********' }
        }
      });

    # this one search who you are not following but followed
    $tf->search();
    or 
    # If you set parameter then , search $twitter_name's following but you are not following
    # $tf->search( $twitter_name );
    $tf->show();

=head1 DESCRIPTION

You can get Net::Twitter::Diff from bellow svn repo for now.

 svn co http://svn.coderepos.org/share/lang/perl/Net-Twitter-Diff/trunk/

Search friends who are not folloing bug they are following you.

=head1 METHOD

=head2 search

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com>

=cut
