# hipchat-log-time-reminder

A "Log your time" HipChat reminder inspired by Jame Green's
\[[@jkg](https://github.com/jkg)\] version.

# Usage

## Synopsis

hipchat-log-time-reminder \[--help\] \[--verbose\] \[--test\] \[--room=&lt;room>\] \[--dow=<1-7>\] \[--date=YYYY-MM-DD\] \[--message=&lt;message>\] \[--config=&lt;file>\]

## Arguments

- --verbose

    Turns on verbose output; otherwise just warns out when notification fails.

    Default off.

- --test

    A test run, use test default options

- --help

    Prints usage, then exits.

- --room=&lt;room\_name>

    Specifies the room to post to; room\_name is the "pretty" room name.

- --config=&lt;file>

    Specifies config file path. Defaults to "$HOME/.hipchat-log-time-rc.yaml".

- --date=YYYY-MM-DD

    Specifies the date in ISO8601 format. Defaults to current date.

- --dow=&lt;Integer:1..7>

    Specifies the DOW to treat as 1==Monday, 2==Tuesday, ... 7==Sunday

- --message=&lt;message\_html>

    Specifies the message string in HTML format; otherwise falls back to default
    behaviour.

- --option=&lt;keya.keyb.index0.keyc:value>

    Overrides config values using a flattened format. Multiple specifications
    allowed.


## Environment variables

- HIPCHAT\_TOKEN

    HipChat API token to use. Needs to have 'Send Message' and 'Send Notifications'
    permissions. If not provided expects $HOME/hipchat.secure file containing the
    token in GPG encrypted form.

# Deployment

To make a tar of this module do:

```bash
git archive --format tar -o hipchat-log-time-reminder-0.1.tar \
  --prefix hipchat-log-time-reminder-0.1/ HEAD
```

To roll out changes to within the $HOME directory do:

```bash
tar xvf hipchat-log-time-reminder-0.1.tar  -C $HOME
```

## System Requirements

### Perl version

- Perl 5.10.1+

### Non-core modules

For local installation see [local::lib](https://metacpan.org/pod/local::lib).

- [Config::Any](https://metacpan.org/pod/Config::Any)

- [Date::Holidays](https://metacpan.org/pod/Date::Holidays)

- [Date::Holidays::GB](https://metacpan.org/pod/Date::Holidays::GB)

- [DateTime](https://metacpan.org/pod/DateTime)

- [Digest::SHA](https://metacpan.org/pod/Digest::SHA)

- [EWS::Client](https://metacpan.org/pod/EWS::Client)

- [File::Fetch](https://metacpan.org/pod/File::Fetch)

- [Getopt::Long](https://metacpan.org/pod/Getopt::Long)

- [HTML::Entities](https://metacpan.org/pod/HTML::Entities)

- [HTML::FormatText](https://metacpan.org/pod/HTML::FormatText)

- [Image::Magick](https://metacpan.org/pod/Image::Magick) - I had problems
installing the distribution. The following seemed to work for me:

  1. Download [ImageMagick source](http://www.imagemagick.org/download/ImageMagick.tar.gz)

  2. Unpack, compile and install:

```bash
tar xvzf ImageMagick.tar.gz
cd ImageMagick-6.9.3
./configure --with-perl
make
cd PerlMagick
perl Makefile.PL
make
make install
```

- [MIME::Types](https://metacpan.org/pod/MIME::Types)

- [Moose](https://metacpan.org/pod/Moose)

- [Readonly](https://metacpan.org/pod/Readonly)

- [Term::ANSIColor](https://metacpan.org/pod/Term::ANSIColor)

- [Test::Fatal](https://metacpan.org/pod/Test::Fatal)

- [Test::More](https://metacpan.org/pod/Test::More)

- [Test::Most](https://metacpan.org/pod/Test::Most)

- [Time::Piece](https://metacpan.org/pod/Time::Piece)

- [WebService::HipChat](https://metacpan.org/pod/WebService::HipChat)

- [XML::Feed](https://metacpan.org/pod/XML::Feed)

- [YAML](https://metacpan.org/pod/YAML)
