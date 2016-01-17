package HipChatLogTime::Image::Download;
use strict;
use warnings;

use Moose;

use namespace::autoclean;

has 'image_uri' => ( is => 'ro', required => 1 );

has 'download_dir' => (
  is      => 'rw',
  default => '.',
);

has 'image_maxheight' => ( isa => 'Int', is => 'rw', default => 511 );

has 'image_maxwidth' => (
  isa     => 'Int',
  is      => 'rw',
  default => sub { shift->image_maxheight }
);

has 'lazy_download' => (
  is      => 'rw',
  default => 1,
);

has 'local_dir' => (
  is      => 'rw',
  default => sub { shift->download_dir },
);

has 'local_filesuffix' => ( 'is' => 'rw', );

has 'local_path' => (
  is      => 'rw',
  lazy    => 1,
  builder => '_build_local_path',
);

has 'download_path' => (
  is      => 'rw',
  lazy    => 1,
  builder => '_build_download_path',
);

has 'local_filebase' => (
  'is'    => 'ro',
  lazy    => 1,
  builder => '_build_local_filebase',
);

sub _build_download_path {
  my $self = shift;
  if ( not $self->image_uri ) {
    warn "Image URI required.";
    return;
  }
  if ( not -w $self->download_dir ) {
    warn sprintf( 'Non-writeable download directory: %s', $self->download_dir );
    return;
  }
  require File::Fetch;
  my $ff = File::Fetch->new( uri => $self->image_uri );

  # XXX work around non implemented https scheme in File::Fetch
  my $NO_HTTPS_FETCH = eval(
         ( not $File::Fetch::METHODS->{'https'} )
      or ( not scalar( @{ $File::Fetch::METHODS->{'https'} } ) )
  );
  if ( $ff->scheme eq 'https' and $NO_HTTPS_FETCH ) {
    $File::Fetch::METHODS->{'https'} = $File::Fetch::METHODS->{'http'};
  }
  my $path = $ff->fetch( to => $self->download_dir );
  if ( not $path ) {
    warn sprintf( 'Download failed: %s', ( $ff->error // 'Unknown error' ) );
    return;
  }
  return $path;
}

sub _build_local_path {
  my $self = shift;
  return if not $self->download_path;
  if ( not -w $self->local_dir ) {
    warn sprintf( 'Non-writeable local directory: %s', $self->local_dir );
    return;
  }
  if ( $self->lazy_download ) {
    if ( not -r $self->local_dir ) {
      warn sprintf( 'Non-readable local directory: %s', $self->local_dir );
      return;
    }
    require File::Spec;
    require File::Basename;
    my ($cached_file) = grep {
           ( not $self->local_filesuffix )
        or ( [ File::Basename::fileparse($_) ]->[2] // '' ) eq
        $self->local_filesuffix
      } glob(
      sprintf( '%s.*',
        File::Spec->catfile( $self->local_dir, $self->local_filebase ) )
      );

    return $cached_file if $cached_file;
  }
  require Image::Magick;
  my $image = Image::Magick->new;
  $image->Read( $self->download_path );
  my ($mime_class) = split( '/', $image->Get("mime") );
  if ( ( $mime_class // '' ) ne 'image' ) {
    warn sprintf( 'Downloaded file of unexpected type: %s',
      ( $mime_class // 'UNKNOWN' ) );
    return;
  }
  require MIME::Types;
  my ($mime_ext) = MIME::Types->new->type( $image->Get('mime') )->extensions;
  $image->Resize( geometry =>
      sprintf( '%dx%d', $self->image_maxwidth, $self->image_maxheight ) );
  $self->local_filesuffix || $self->local_filesuffix($mime_ext);
  require File::Spec;
  my $target_path = File::Spec->catfile( $self->local_dir,
    sprintf( '%s.%s', $self->local_filebase, $self->local_filesuffix ) );
  my $wi_err = $image->Write($target_path);

  if ($wi_err) {
    warn sprintf( 'Writing image file failed: %s', $wi_err );
    return;
  }
  return $target_path;
}

sub _build_local_filebase {
  my $self = shift;
  return if not $self->image_uri;
  require Digest::SHA;
  return Digest::SHA->new->add(
    join(
      ':', $self->image_uri, $self->image_maxheight, $self->image_maxwidth
    )
  )->hexdigest;
}

__PACKAGE__->meta->make_immutable;

1;
