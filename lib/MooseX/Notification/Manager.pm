package MooseX::Notification::Manager;

use MooseX::Singleton;
use Scalar::Util qw(reftype blessed);

our %observers = ();

sub add {
    my ( $self, $args ) = @_;
    confess '$args must be a hashref' if ref $args ne 'HASH';
    confess 'observer must be object'
      if ( !$args->{'observer'} and !blessed $args->{'observer'} );
    confess 'method name must be given' if ( !$args->{'method'} );

    my $event = delete $args->{'event'} || 'DEFAULT';

    push @{ $observers{$event}->{ $args->{'observer'} } }, $args;
}

sub remove {
    my ( $self, $args ) = @_;
    confess '$args must be a hashref' if ref $args ne 'HASH';
    confess 'observer must be object'
      if ( !$args->{'observer'} and !blessed $args->{'observer'} );

    my $event = $args->{'event'} || 'DEFAULT';
    delete $observers{$event}->{ $args->{'observer'} };
}

1;
