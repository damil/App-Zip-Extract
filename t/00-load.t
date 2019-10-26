#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'App::Zip::Extract' ) || print "Bail out!\n";
}

diag( "Testing App::Zip::Extract $App::Zip::Extract::VERSION, Perl $], $^X" );
