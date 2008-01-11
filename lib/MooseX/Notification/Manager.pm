package MooseX::Notification::Manager;

use MooseX::Singleton;
use Scalar::Util qw(reftype blessed refaddr);
use Set::Object;

has observers => (
    is      => 'ro',
    isa     => 'HashRef[Set::Object]',
    default => sub { {} }
);

has method_calls => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} }
);

sub add {
    my ( $self, $args ) = @_;

    my $event    = delete $args->{'event'} || 'DEFAULT';
    my $observer = $args->{'observer'};
    my $method   = $args->{'method'} || 'update';

    $self->observers->{$event} ||= Set::Object->new;

    $self->observers->{$event}->insert($observer);
    $self->method_calls->{ refaddr $observer } = $method;
}

sub remove {
    my ( $self, $args ) = @_;

    my $event = $args->{'event'} || 'DEFAULT';
    my $observer = $args->{'observer'};

    $self->observers->{$event}->remove($observer);
    delete $self->method_calls->{ refaddr $observer }
}

1;
