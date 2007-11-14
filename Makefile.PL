use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::Twitter::FriendFinder',
    AUTHOR              => 'Tomohiro Teranishi <tomohiro.teranishi@gmail.com>',
    VERSION_FROM        => 'lib/Net/Twitter/FriendFinder.pm',
    ABSTRACT_FROM       => 'lib/Net/Twitter/FriendFinder.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'            => 0,
        'Web::Scraper'          => 0,
        'URI'                   => 0,
        'URI::Escape'           => 0,
        'Net::Twitter::Diff'    => 0,
        'Text::SimpleTable'     => 0,
        'Class::Accessor::Fast' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-Twitter-FriendFinder-*' },
);
