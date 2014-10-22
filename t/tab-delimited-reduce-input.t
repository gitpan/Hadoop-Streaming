use strict;
use warnings;

use Test::More tests=>7;
use Test::Command;
use Config;

use FindBin;
ok( $FindBin::Bin );

my $path="$FindBin::Bin/tab-delimited-reduce-input/";

my $perl            = $Config{perlpath};
my $sort            = $FindBin::Bin . '/sort.pl';

my $map             = $path . 'map.pl';
my $reduce          = $path . 'reduce.pl';
my $input           = $path . 'example-input.txt';
my $expected_map    = $path . 'expected-map.out';
my $expected_reduce = $path . 'expected-reduce.out';

TEST_MAP:
{
    my $map_cmd = Test::Command->new( cmd => "$perl $map < $input" );
    $map_cmd->exit_is_num( 0, 'map exit value is 0' );
    $map_cmd->stderr_is_eq( '', 'stderr is blank in mapper');
    $map_cmd->stdout_is_file( $expected_map,
        "map output matches expected [$expected_map]" );
}

TEST_REDUCE:
{
    my $reduce_cmd = Test::Command->new( cmd => "$perl $sort $expected_map | $perl $reduce" );
    $reduce_cmd->exit_is_num( 0, 'reducer exit value is 0' );
    $reduce_cmd->stderr_is_eq( '', 'stderr is blank in reducer');
    $reduce_cmd->stdout_is_file( $expected_reduce,
        "reduce output matches expected [$expected_reduce]" );
}
