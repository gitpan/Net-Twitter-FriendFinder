#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::Twitter::FriendFinder' );
}

diag( "Testing Net::Twitter::FriendFinder $Net::Twitter::FriendFinder::VERSION, Perl $], $^X" );
