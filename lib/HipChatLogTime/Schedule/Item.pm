package HipChatLogTime::Schedule::Item;
use strict;
use warnings;

use Moose;

use namespace::autoclean;

has 'start' => (
  is       => 'rw',
  required => 1,
);

has 'end' => (
  is       => 'rw',
  required => 1,
);

has 'subject' => (
  is       => 'rw',
  required => 1,
);

has 'location' => ( is => 'rw' );

has 'starleaf' => ( is => 'rw' );

has 'data' => ( is => 'rw', );

__PACKAGE__->meta->make_immutable;

1;
