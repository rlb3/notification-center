#!perl

use Test::More qw(no_plan);

{
    package Person;
    use Moose;
    
    has fname => (is => 'rw');
    has lname => (is => 'rw');
    
    sub display {
        my ($self) = @_;
        sprintf "%s, %s\n", $self->lname, $self->fname;
    }
    
    no Moose;
}

use MooseX::Notification::Manager;

my $me = Person->new(fname => 'Robert', lname => 'Boone');

my $ns = MooseX::Notification::Manager->instance;

$ns->add(
    {
        observer => $me,
        event    => 'print',
        method   => 'display',
    }
);

diag $ns->dump;

$ns->remove(
    {
        observer => $me,
        event    => 'print',
    }
);

diag $ns->dump;

ok 1;