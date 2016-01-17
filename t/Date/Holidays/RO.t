use strict;
use warnings;

use Test::More tests => 10;
BEGIN { use_ok "Date::Holidays::RO", qw/ is_holiday holidays holidays_ymd / }

use Test::Most;
use Test::Fatal;
note "is_holiday";

ok !is_holiday( 2015, 1, 3 ), "2015-01-03 is not a holiday";

ok my $christmas = is_holiday( 2015, 12, 25 ), "2015-12-25 is a holiday";
is $christmas, "Christmas Day", "Christmas Day name ok (all)";

ok !is_holiday( 2015, 12, 25, [] ),
  "2015-12-25 is not a holiday if empty region list";

is_deeply holidays(2000), {}, "No data for year 2000 - outside range";
is_deeply holidays(2020), {}, "No data for year 2020 - outside range";

is_deeply holidays(2015),
  {
  "0101" => "New Year's Day",
  "0102" => "Day after New Year's Day",
  "0124" => "Unification Day",
  "0412" => "Orthodox Easter Day",
  "0413" => "Orthodox Easter Monday",
  "0501" => "Labor Day / May Day",
  "0531" => "Orthodox Pentecost",
  "0601" => "Orthodox Pentecost Monday",
  "0815" => "St Mary's Day",
  "1130" => "St Andrew's Day",
  "1201" => "National holiday",
  "1225" => "Christmas Day",
  "1226" => "Second day of Christmas",
  },
  "2015 holidays ok";

is_deeply holidays_ymd(2015),
  {
  "2015-01-01" => "New Year's Day",
  "2015-01-02" => "Day after New Year's Day",
  "2015-01-24" => "Unification Day",
  "2015-04-12" => "Orthodox Easter Day",
  "2015-04-13" => "Orthodox Easter Monday",
  "2015-05-01" => "Labor Day / May Day",
  "2015-05-31" => "Orthodox Pentecost",
  "2015-06-01" => "Orthodox Pentecost Monday",
  "2015-08-15" => "St Mary's Day",
  "2015-11-30" => "St Andrew's Day",
  "2015-12-01" => "National holiday",
  "2015-12-25" => "Christmas Day",
  "2015-12-26" => "Second day of Christmas",
  },
  "2015 holidays_ymd ok";

is_deeply holidays( year => 2015, regions => ['IS'] ), {
  "0101" => "New Year's Day",
  "0102" => "Day after New Year's Day",
  "0124" => "Unification Day",
  "0412" => "Orthodox Easter Day",
  "0413" => "Orthodox Easter Monday",
  "0501" => "Labor Day / May Day",
  "0531" => "Orthodox Pentecost",
  "0601" => "Orthodox Pentecost Monday",
  "0815" => "St Mary's Day",
  "1130" => "St Andrew's Day",
  "1201" => "National holiday",
  "1225" => "Christmas Day",
  "1226" => "Second day of Christmas",

  },
  "got holidays for Iași, 2015";

done_testing;
