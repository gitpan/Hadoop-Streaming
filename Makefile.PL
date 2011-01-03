
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Contains Mapper, Combiner and Reducer roles to simplify writing Hadoop Streaming jobs ',
  'AUTHOR' => 'andrew grangaard <spazm@cpan.org>, Naoya Ito <naoya@hatena.ne.jp>',
  'BUILD_REQUIRES' => {
    'Config' => '0',
    'FindBin' => '0',
    'Test::Command' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Hadoop-Streaming',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Hadoop::Streaming',
  'PREREQ_PM' => {
    'IO::Handle' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'Params::Validate' => '0'
  },
  'VERSION' => '0.110030',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



