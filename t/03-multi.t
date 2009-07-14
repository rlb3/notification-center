#! perl

use strict;
use warnings;

use Test::More qw / no_plan /;

{

    package MyInt;
    use Moose;
    use Notification::Center;

    has 'name' => ( is => 'ro', isa => 'Str', required => 1 );
    has 'int'  => ( is => 'ro', isa => 'Int', default  => 0 );

    sub set_int {
        my ( $self, $new ) = @_;
        my $ns = Notification::Center->default;
        $self->{int} = $new;
        $ns->notify(
            { event => $self->{name} . 'changed', args => $self->{int} } );
    }

    no Moose;

    package MultiWatcher;
    use Moose;
    has 'int1_name' => ( isa => 'Str', is => 'ro', required => 1 );
    has 'int1_val'  => ( isa => 'Int', default => 0 );
    has 'int2_name' => ( isa => 'Str', is      => 'ro', required => 1 );
    has 'int2_val'  => ( isa => 'Int', default => 0 );

    sub BUILD {
        my $self = shift;
        my $nc   = Notification::Center->default;
        $nc->add(
            {
                observer => $self,
                event    => $self->{int1_name} . 'changed',
                method   => 'update_int1'
            }
        );
        $nc->add(
            {
                observer => $self,
                event    => $self->{int2_name} . 'changed',
                method   => 'update_int2'
            }
        );
    }

    sub update_int1 {
        my ( $self, $val ) = @_;
        $self->{int1_val} = $val;
    }

    sub update_int2 {
        my ( $self, $val ) = @_;
        $self->{int2_val} = $val;
    }

    sub get_total {
        my $self = shift;
        return $self->{int1_val} + $self->{int2_val};
    }
    no Moose;
}
my $int1 = MyInt->new( name => 'int1' );
my $int2 = MyInt->new( name => 'int2' );
my $mw = MultiWatcher->new( int1_name => 'int1', int2_name => 'int2' );
is( $mw->get_total, 0, 'initial value' );
$int1->set_int(5);
is( $mw->get_total, 5, 'set int1 value' );
$int2->set_int(6);
is( $mw->get_total, 11, 'set int2 value' );
