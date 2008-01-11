#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'MooseX::Notification' );
}

diag( "Testing MooseX::Notification $MooseX::Notification::VERSION, Perl $], $^X" );
