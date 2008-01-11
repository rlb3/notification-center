package MooseX::Notification;

use MooseX::Singleton;
use Scalar::Util qw(refaddr);
use Set::Object;

our $VERSION = '0.0.1';

has observers => (
    is      => 'ro',
    isa     => 'HashRef[Set::Object]',
    default => sub {
        { DEFAULT => Set::Object->new }
    }
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

    delete $self->method_calls->{ refaddr $observer };
    $self->observers->{$event}->remove($observer);
}

sub notify {
    my ( $self, $event, @data ) = @_;

    my $observers;
    if ( $event ne 'DEFAULT' ) {
        $observers = Set::Object->new(
            $self->observers->{$event}->members,
            $self->observers->{'DEFAULT'}->members
        );
    }
    else {
        $observers = $self->observers->{$event};
    }

    foreach my $observer ( $observers->members ) {
        my $method = $self->method_calls->{ refaddr $observer };
        $observer->$method(@data);
    }
}

1;
