#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'LSI::MegaSAS' ) || print "Bail out!
";
}

diag( "Testing LSI::MegaSAS $LSI::MegaSAS::VERSION, Perl $], $^X" );
