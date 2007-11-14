package Net::Twitter::FriendFinder::From;

use strict;
use warnings;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors(qw/limit coverage handicap/);

sub search {
    die 'implement me';
}

1;
=head1 NAME

Net::Twitter::FriendFinder::From - Net::Twitter::FriendFinder resource template

=head1 DESCRIPTION

use as base package if you try to make resource package.

=head1 METHOD

=head2 search

=head1 AUTHOR

Tomohiro Teranishi

=cut


