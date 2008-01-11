#!perl

use Test::More tests => 1;

{

    package Person;
    use Moose;
    use MooseX::Notification;

    has fname => ( is => 'rw' );
    has lname => ( is => 'rw' );

    sub print_name {
        my ( $self ) = @_;
        
        my $ns = MooseX::Notification->instance;
        $ns->notify('print', $self);
    }

    no Moose;

    package PrintName;
    use Moose;
    

    sub display {
        my ( $self, $person ) = @_;
        my $name = sprintf "%s, %s", $person->lname, $person->fname;
        Test::More::is($name, 'Wall, Larry', 'Displaying the name');
    }
    
    no Moose;
}

use MooseX::Notification;

my $person = Person->new( fname => 'Larry', lname => 'Wall' );
my $d  = PrintName->new;

my $ns = MooseX::Notification->instance;

$ns->add(
    {
        observer => $d,
        event    => 'print',
        method   => 'display',
    }
);

$person->print_name;

