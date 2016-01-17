package Date::Holidays::RO;

our $VERSION = '0.001';

# ABSTRACT: Determine Romanian public holidays; see Date::Holidays::GB

use strict;
use warnings;
use utf8;

use base qw( Date::Holidays::Super Exporter );
our @EXPORT_OK = qw(
  holidays
  ro_holidays
  holidays_ymd
  is_holiday
  is_ro_holiday
);

my %ISO_REGION_NAMES = (
  'AB' => 'Alba',                 # department
  'AR' => 'Arad',                 # department
  'AG' => 'Argeș',                # department
  'BC' => 'Bacău',                # department
  'BH' => 'Bihor',                # department
  'BN' => 'Bistrița-Năsăud',      # department
  'BT' => 'Botoșani',             # department
  'BV' => 'Brașov',               # department
  'BR' => 'Brăila',               # department
  'BZ' => 'Buzău',                # department
  'CS' => 'Caraș-Severin',        # department
  'CL' => 'Călărași',             # department
  'CJ' => 'Cluj',                 # department
  'CT' => 'Constanța',            # department
  'CV' => 'Covasna',              # department
  'DB' => 'Dâmbovița',            # department
  'DJ' => 'Dolj',                 # department
  'GL' => 'Galați',               # department
  'GR' => 'Giurgiu',              # department
  'GJ' => 'Gorj',                 # department
  'HR' => 'Harghita',             # department
  'HD' => 'Hunedoara',            # department
  'IL' => 'Ialomița',             # department
  'IS' => 'Iași',                 # department
  'IF' => 'Ilfov',                # department
  'MM' => 'Maramureș',            # department
  'MH' => 'Mehedinți',            # department
  'MS' => 'Mureș',                # department
  'NT' => 'Neamț',                # department
  'OT' => 'Olt',                  # department
  'PH' => 'Prahova',              # department
  'SM' => 'Satu Mare',            # department
  'SJ' => 'Sălaj',                # department
  'SB' => 'Sibiu',                # department
  'SV' => 'Suceava',              # department
  'TR' => 'Teleorman',            # department
  'TM' => 'Timiș',                # department
  'TL' => 'Tulcea',               # department
  'VS' => 'Vaslui',               # department
  'VL' => 'Vâlcea',               # department
  'VN' => 'Vrancea',              # department
  'B'  => 'București',            # municipality
);

my @ISO_REGIONS = keys %ISO_REGION_NAMES;

my %holidays;
set_holidays( \*DATA );

sub set_holidays {
  my ($fh) = @_;
  while (<$fh>) {
    chomp;
    my ( $date, $region, $name ) = split /\t/;
    next unless $date && $region && $name;
    my ( $y, $m, $d ) = split /-/, $date;
    if ( $region eq '*' ) {
      $holidays{$y}->{$date}->{$_} = $name for @ISO_REGIONS;
    }
    else {
      $holidays{$y}->{$date}->{$region} = $name;
    }
  }

  # Define an 'all' if all regions have a holiday on this day, taking
  # B name as the canonical name
  while ( my ( $year, $dates ) = each %holidays ) {
    foreach my $holiday ( values %{$dates} ) {
      $holiday->{all} = $holiday->{B}
        if keys %{$holiday} == @ISO_REGIONS;
    }
  }

}

sub ro_holidays { return holidays(@_) }

sub holidays {
  my %args =
      $_[0] =~ m/\D/
    ? @_
    : ( year => $_[0], regions => $_[1] );

  unless ( exists $args{year} && defined $args{year} ) {
    $args{year} = ( localtime(time) )[5];
    $args{year} += 1900;
  }

  unless ( $args{year} =~ /^\d{4}$/ ) {
    die "Year must be numeric and four digits, eg '2004'";
  }

  # return if empty regions list (undef gets full list)
  my @region_codes = @{ $args{regions} || \@ISO_REGIONS }
    or return {};

  my %return;

  while ( my ( $date, $holiday ) = each %{ $holidays{ $args{year} } } ) {
    my $string = _holiday( $holiday, \@region_codes )
      or next;

    if ( $args{ymd} ) {
      $return{$date} = $string;
    }
    else {
      my ( undef, $m, undef, $d ) = unpack( 'A5A2A1A2', $date );
      $return{ $m . $d } = $string;
    }
  }

  return \%return;
}

sub holidays_ymd {
  my %args =
      $_[0] =~ m/\D/
    ? @_
    : ( year => $_[0], regions => $_[1] );

  return holidays( %args, ymd => 1 );
}

sub is_ro_holiday { return is_holiday(@_) }

sub is_holiday {
  my %args =
      $_[0] =~ m/\D/
    ? @_
    : ( year => $_[0], month => $_[1], day => $_[2], regions => $_[3] );

  my ( $y, $m, $d ) = @args{qw/ year month day /};
  die "Must specify year, month and day" unless $y && $m && $d;

  # return if empty regions list (undef gets full list)
  my @region_codes = $args{regions} ? @{ $args{regions} } : @ISO_REGIONS
    or return;

  # return if no region has holiday
  my $holiday = $holidays{$y}->{ sprintf( "%04d-%02d-%02d", $y, $m, $d ) }
    or return;

  return _holiday( $holiday, \@region_codes );
}

sub next_holiday {
  my @regions = (shift) || @ISO_REGIONS;

  my ( $d, $m, $year ) = ( localtime() )[ 3 .. 5 ];
  my $today = sprintf( "%04d-%02d-%02d", $year + 1900, $m + 1, $d );

  my %next_holidays;

  foreach my $date ( sort keys %{ $holidays{$year} } ) {

    next unless $date gt $today;

    my $holiday = $holidays{$year}->{$date};

    foreach my $region ( 'all', @regions ) {
      my $name = $holiday->{$region} or next;

      $next_holidays{$region} ||= $name;
    }

    last if $next_holidays{all} or keys %next_holidays == @ISO_REGIONS;
  }

  return \%next_holidays;
}

sub _holiday {
  my ( $holiday, $region_codes ) = @_;

  # return canonical name (B) if all regions have holiday
  return $holiday->{all} if $holiday->{all};

  my %region_codes = map { $_ => 1 } @{$region_codes};

  # return comma separated string of holidays with region(s) in
  # parentheses
  my %names;
  foreach my $region ( sort keys %region_codes ) {
    next unless $holiday->{$region};

    push @{ $names{ $holiday->{$region} } }, $ISO_REGION_NAMES{$region};
  }

  return unless %names;

  my @strings;
  foreach my $name ( sort keys %names ) {
    push @strings, "$name (" . join( ', ', @{ $names{$name} } ) . ")";
  }

  return join( ', ', @strings );
}

sub date_generated { '2015-12-28' }

1;

__DATA__
2015-01-01	*	New Year's Day
2015-01-02	*	Day after New Year's Day
2015-01-24	*	Unification Day
2015-04-12	*	Orthodox Easter Day
2015-04-13	*	Orthodox Easter Monday
2015-05-01	*	Labor Day / May Day
2015-05-31	*	Orthodox Pentecost
2015-06-01	*	Orthodox Pentecost Monday
2015-08-15	*	St Mary's Day
2015-11-30	*	St Andrew's Day
2015-12-01	*	National holiday
2015-12-25	*	Christmas Day
2015-12-26	*	Second day of Christmas
2016-01-01	*	New Year's Day
2016-01-02	*	Day after New Year's Day
2016-01-24	*	Unification Day
2016-02-19	*	Constantin Brancusi Day
2016-05-01	*	Labor Day / May Day
2016-05-01	*	Orthodox Easter Day
2016-05-02	*	Orthodox Easter Monday
2016-06-19	*	Orthodox Pentecost
2016-06-20	*	Orthodox Pentecost Monday
2016-08-15	*	St Mary's Day
2016-11-30	*	St Andrew's Day
2016-12-01	*	National holiday
2016-12-25	*	Christmas Day
2016-12-26	*	Second day of Christmas
