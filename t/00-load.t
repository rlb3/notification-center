#!perl

use Test::More tests => 2;

BEGIN {
	use_ok( 'MooseX::Notification' );
	use_ok( 'MooseX::Notification::Manager' );
}

diag( "Testing MooseX::Notification $MooseX::Notification::VERSION, Perl $], $^X" );
