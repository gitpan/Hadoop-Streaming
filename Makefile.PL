
use strict;
use warnings;



use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Hadoop-Streaming',
  NAME      => 'Hadoop::Streaming',
  AUTHOR    => "andrew\ grangaard\ \<spazm\@cpan\.org\>\,\ Naoya\ Ito\ \<naoya\@hatena\.ne\.jp\>",
  ABSTRACT  => "Simplify\ writing\ Hadoop\ Streaming\ jobs\.\ Write\ a\ map\(\)\ and\ reduce\(\)\ function\ and\ let\ this\ role\ handle\ the\ Stream\ interface\.",
  VERSION   => '0.100050',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Test::More" => '0',
    "Moose::Role" => '0',
    "Params::Validate" => '0',
    "FindBin" => '0',
    "IO::Handle" => '0',
    "Moose" => '0',
    "Test::Command" => '0',
  },
  test => {TESTS => 't/*.t'}
);

