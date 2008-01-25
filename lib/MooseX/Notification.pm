package MooseX::Notification;

use MooseX::Singleton;
use Scalar::Util qw(refaddr);
use Set::Object;

our $AUTHORITY = 'CPAN:RLB';
our $VERSION   = '0.0.2';

my $instance;

has default => (
    is      => 'ro',
    isa     => 'MooseX::Notification',
    lazy    => 1,
    default => sub {
        return $instance ||= MooseX::Notification->new;
    },
);

has observers => (
    is      => 'ro',
    isa     => 'HashRef[Set::Object]',
    default => sub {
        { DEFAULT => Set::Object->new };
    }
);

has method_calls => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} }
);

sub add {
    my ( $self, $args ) = @_;

    my $event    = $args->{'event'} || 'DEFAULT';
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
        $observers = Set::Object->new( $self->observers->{$event}->members, $self->observers->{'DEFAULT'}->members );
    }
    else {
        $observers = $self->observers->{$event};
    }

    foreach my $observer ( $observers->members ) {
        my $method = $self->method_calls->{ refaddr $observer };
        $observer->$method(@data) if $observer->can($method);
    }
}

1;

__END__

=pod

=head1 NAME

MooseX::Notification - An observer/notification for Moose

=head1 SYNOPSIS

    {

        package Counter;

        use Moose;
        use MooseX::Notification;

        has count => ( is => 'rw', isa => 'Int', default => 0 );

        sub inc {
            my ($self) = @_;
            $self->count($self->count + 1);

            my $mn = MooseX::Notification->default;

            $mn->notify( 'print', $self->count );
        }

        sub dec {
            my ($self) = @_;
            $self->count($self->count - 1);

            my $mn = MooseX::Notification->default;

            $mn->notify( 'print', $self->count );
        }

        no Moose;

        package CountPrint;

        use Moose;

        sub print {
            my ( $self, $count ) = @_;

            print $count;
        }

        no Moose;
    }

    my $count = Counter->new;

    my $mn = MooseX::Notification->default;
    my $cp = CountPrint->new;
    $mn->add({
       observer => $cp,
       event    => 'print',
       method   => 'print',
    });

    for (1 .. 10) {
        $count->inc;
    }

    for (1 .. 5) {
        $count->dec;
    }

    # prints: 1234567891098765

=head1 DESCRIPTION

An observer/notification based on the objective-c NSNotificationCenter Class

=over

=item add

args keys: observer, event, method

observer: the object that will observer events

event: the name of the event that you are assigning the observer. Defaults to DEFAULT

method: the method you want called on the observer when the event is called. Defaults to update

=item remove

args keys: observer, event

observer: the object that you want to remove

event: the name of the event that you are removing the observer. Defaults to DEFAULT

=item notify

args: $event, @data

$event: the event you want to trigger

@data: data you want to pass into observers

=back

=cut
