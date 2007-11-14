package Net::Twitter::FriendFinder;

use warnings;
use strict;
use UNIVERSAL::require;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/default from setting ids scores resources filters)/);
use Text::SimpleTable;
use Net::Twitter::Diff;

our $VERSION = '0.02';


sub search {
    my $self = shift;
    my $keyword = shift;

    $self->{keyword} = $keyword;
    # set default of default :-p
    my $default = {};
    $default->{coverage}    = $self->{default}{coverage} || 1;

     $self->{filters} = [];

    my @resources = keys %{ $self->{from} };
    my $data = {}; 
    $self->{resources} = ();
    for my $resource ( @resources ) {
        my $module = substr( $resource , 0 , 1 ) eq '+' ? substr( $resource ,1): "Net::Twitter::FriendFinder::From::" . $resource;
        push @{ $self->{resources} } , $module ;
        $module->require or die $@;
        my $conf =  $self->{from}{ $resource } ;
        $conf->{coverage} = $conf->{coverage} || $default->{coverage};
        $conf->{handicap} = $conf->{handicap} || 1;

        my $from = $module->new( $conf );
        my $results =  $from->search( $keyword );

        foreach my $id ( keys %{ $results } ) {
            $data->{ $id } = $results->{ $id } + ( $data->{ $id } || 0 );
        }
    }

    if( $self->{setting}{filter_already_followers} ) {
        my $twitter = Net::Twitter::Diff->new( username=> $self->{setting}{username} , password => $self->{setting}{password} );
        my $xfollowing = $twitter->xfollowing;
    
        my @filters = ();

        for my $item ( @{ $xfollowing } ) {
            my $screen_name = $item->{screen_name} ;
            if( defined $data->{ $screen_name } ) {
                push @filters , { id => $screen_name , score =>  $data->{ $screen_name } };
                delete $data->{ $screen_name };
            }
        }
        $self->{filters} = \@filters;

    }

    my @ids = sort { $data->{ $a } <=> $data->{ $b } } keys %{ $data };

    my $limit = $self->{setting}{limit} || scalar @ids;
    @ids = reverse @ids;
    if( scalar @ids > $limit ) {
        @ids = @ids[0...$limit-1];
    }
    $self->{ids} = \@ids;
    $self->{scores} = $data;

    return 1;
}

sub show {
    my $self = shift;

    my $t = Text::SimpleTable->new( 44 );
    $t->row( 'Resources' );
    print $t->draw;

    my $t0 = Text::SimpleTable->new( 44 );
    for my $resource ( @{ $self->{resources} } ) {
        $t0->row( $resource );
    }
    print $t0->draw;

    my $t1 = Text::SimpleTable->new( 7 , 34 );
    $t1->row('Keyword' , $self->{keyword} );
    print $t1->draw;

    my $t2 = Text::SimpleTable->new( 3, 20, 15 );
    $t2->row( '#', 'Twitter id' , 'Score' );
    print $t2->draw;
    
    my $t3 = Text::SimpleTable->new( '3', 20, 15 );

    my $cnt = 1;
    for my $id ( @{ $self->{ids} } ) {
        $t3->row( $cnt, $id, $self->{scores}{ $id } );
        $cnt++;
    }
    print $t3->draw;

    if( scalar @{ $self->{filters} } ) {
        my $t4 = Text::SimpleTable->new( 44 );
        $t4->row( 'Filter Users' );
        print $t4->draw;

        my $t5= Text::SimpleTable->new( 3, 20, 15 );
        my $cnt = 1;
        for my $filter ( @{ $self->{filters} } ) {
            $t5->row( $cnt , $filter->{id} , $filter->{score} );
            $cnt++;
        }
        print $t5->draw;
    }

}

sub follow {
use Data::Dumper;
    my $self = shift;
    my $twit = Net::Twitter->new( username=>$self->{setting}{username} ,password=> $self->{setting}{password});
    foreach my $id (  @{ $self->{ids} } ) {
        my $result = $twit->follow( $id );
        sleep( $self->{setting}{sleep} ) if  defined $self->{setting}{sleep};

        my $res = defined $result ? 'ok' : 'fail';
        print "follow $id [$res]\n" if $self->{setting}{on_echo};
    }
}

1;

=head1 NAME

Net::Twitter::FriendFinder - find your twitter friend :-)

=head1 DESCRIPTION

Hello. I started twitter but I did not have much friends.  Since I am shay, so that I created this
module.

You can find twitter friends by using keyword search and then you can follow friends whith this module.

=head1 SYNOPSYS

 use Net::Twitter::FriendFinder;

 my $tf 
    = Net::Twitter::FriendFinder->new({ 
        setting => {
            limit => 20,
            on_echo=> 1,
            username => '****',
            password => '****',
            filter_already_followers => 1,
            sleep => 60,
        },
        default => { 
            coverage => 1,
        } ,
        from => {
            Google  => { coverage => 4 },
            Twitter => { handicap => 1.3 } ,
            TwitterKensaku => { coverage => 2 },
            +My::Resource => {}, # your own resource
        }
      });

    $tf->search( $keyword );
    $tf->show();
    $tf->follow();

=head1 MODULE

=head2 new

You should set configulation here.

=over 2 

=item B<setting>

=back

=over 4

=item ->{limit}

you can set limit for how many friends you want to find for max. 

=item ->{on_echo}

when on_echo = 1 then , $tf->follow() method print out who you are going to follow.

=item ->{username}

twitter username

=item ->{password}

twitter password

=item ->{sleep}

since Twitter API has request count limitation, you may want to set sleep time when you try to follow a lot of people.

filter_already_followers - when true, it will check your current followers and not try to follow again. required username and password for this. NOTICE: you may miss some friends to filter who add recently because Twitter API does not return them.

=back

=over 2

=item B<default>

you can set default setting here. 

=back

=over 4


=item ->{coverage}

you can set how much you cover. It depend on where you get resource from , so check the resource POD.

=back

=over 2

=item B<from>

You can set where to search friends from. you can find resource from Net::Twitter::FriendFinder::From::*

  from => {
    Google => {},
    Twitter=> {}
  },


Also if you made your own resource package then set your package name with +.

 from => {
    +My::Resource => { },
 },

=back

=head2 search

 this seach method try to search your friends. 

=head2 show

display who you find from your criteria.

=head2 follow

follow people you find. I recommend that before calling this module , you
should check who you are going t follow with show() method.

=head1 HOW TO MAKE YOUR OWN RESOURCE

this is just simple one.

    package My::Recomend::User;
 
    use strict;
    use warnings;

    use base qw/Net::Twitter::FriendFinder::From/;

    sub search {
        return {
            'tomyhero' => 100,
            'perl'     => 30,
        };
    }

    1;

then

    my $tw = Net::Twitter::FriendFinder->new({
        from => {
            +My::Recomend::User => {},
        }
    });

    $tw->search();
    $tw->show();
    $tw->follow();

=head1 SEE ALSO

L<Net::Twitter>

L<Net::Twitter::FriendFinder::From::Google>

L<Net::Twitter::FriendFinder::From::Twitter>

L<Net::Twitter::FriendFinder::From::TwitterKensaku>

L<Net::Twitter::FriendFinder::From::TwitterDiff>

L<Net::Twitter::FriendFinder::From::URL>

=head1 AUTHOR

Tomohiro Teranishi<tomohiro.teranishi@gmail.com>

=cut
