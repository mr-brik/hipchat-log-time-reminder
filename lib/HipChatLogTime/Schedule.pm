package HipChatLogTime::Schedule;
use strict;
use warnings;

use Moose;

use namespace::autoclean;

has 'data' => (
  is       => 'ro',
  required => 1,
);

has 'now' => (
  is      => 'ro',
  lazy    => 1,
  builder => '_build_now',
);

has 'from_epoch' => (
  is      => 'ro',
);

sub _build_now {
  my ($self) = @_;
  require DateTime;
  return $self->from_epoch
    ? DateTime->from_epoch(
    time_zone => $self->time_zone,
    epoch     => $self->from_epoch
    )
    : DateTime->now( time_zone => $self->time_zone );
}

has 'time_zone' => (
  is      => 'ro',
  default => 'utc',
);

has 'tasks' => (
  is      => 'rw',
  lazy    => 1,
  builder => '_build_tasks',
);

sub _build_tasks {
  my ($self) = @_;
  my (@tasks);
  return if not $self->data;
  foreach my $start_date ( sort keys %{ $self->data } ) {
    foreach my $task ( @{ $self->data->{$start_date} } ) {
      require DateTime::Format::Strptime;
      my $dt_parser = DateTime::Format::Strptime->new(
        pattern   => q{%F %T},
        time_zone => "UTC"
      );
      my $start_dt = $dt_parser->parse_datetime(
        sprintf( '%s %s', $start_date, $task->{'start'} ) )
        ->set_time_zone( $self->time_zone );
      my $end_dt = $dt_parser->parse_datetime(
        sprintf( '%s %s', $start_date, $task->{'end'} ) )
        ->add( days => ( $task->{'start'} gt $task->{'end'} ? 1 : 0 )
        )    # no task longer than 24 hours
        ->set_time_zone( $self->time_zone );

      require HipChatLogTime::Schedule::Item;
      push @tasks,
        HipChatLogTime::Schedule::Item->new(
        start    => $start_dt,
        end      => $end_dt,
        subject  => $task->{'subject'},
        starleaf => $task->{'starleaf'},
        location => $task->{'location'},
        data     => $task
        );
    }
  }
  return \@tasks;
}

has 'today_tasks' => (
  is      => 'rw',
  lazy    => 1,
  builder => '_build_today_tasks',
);

sub _build_today_tasks {
  my ($self) = @_;
  return if not $self->tasks;
  return [ grep {
    $self->now->clone->ymd eq
      $_->start->clone->ymd
  } @{ $self->tasks } ];
}

__PACKAGE__->meta->make_immutable;

1;
