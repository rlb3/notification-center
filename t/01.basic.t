#!perl

use Test::More tests => 3;

{

    package Person;
    use Moose;
    use MooseX::Notification;

    has fname => ( is => 'rw' );
    has lname => ( is => 'rw' );

    sub print_name {
        my ($self) = @_;

        my $ns = MooseX::Notification->default;
        $ns->notify( { event => 'print', args => $self } );
    }

    no Moose;

    package PrintName;
    use Moose;

    sub display {
        my ( $self, $person ) = @_;
        my $name = sprintf "%s, %s", $person->lname, $person->fname;
        Test::More::is( $name, 'Wall, Larry', 'Displaying the name' );
    }

    no Moose;

    package UCPrintName;
    use Moose;

    sub display {
        my ( $self, $person ) = @_;
        my $name = sprintf "%s, %s", $person->lname, $person->fname;
        $name = uc $name;
        Test::More::is( $name, 'WALL, LARRY', 'Displaying the name' );
    }

    no Moose;
}

use MooseX::Notification;

my $person = Person->new( fname => 'Larry', lname => 'Wall' );
my $p      = PrintName->new;
my $u      = UCPrintName->new;

my $ns = MooseX::Notification->default;

$ns->add(
    {
        observer => $p,
        event    => 'print',
        method   => 'display',
    }
);
$ns->add(
    {
        observer => $u,
        method   => 'display',
    }
);

$person->print_name;

$ns->remove( { observer => $u } );
$person->print_name;