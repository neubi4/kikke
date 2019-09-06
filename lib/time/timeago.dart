import 'package:timeago/timeago.dart';

class DeMessages implements LookupMessages {
  String prefixAgo() => 'vor';
  String prefixFromNow() => 'in';
  String suffixAgo() => '';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => '$seconds Sekunden';
  String aboutAMinute(int minutes) => 'einer Minute';
  String minutes(int minutes) => '$minutes Minuten';
  String aboutAnHour(int minutes) => '~1 Stunde';
  String hours(int hours) => '$hours Stunden';
  String aDay(int hours) => '~1 Tag';
  String days(int days) => '$days Tagen';
  String aboutAMonth(int days) => '~1 Monat';
  String months(int months) => '$months Monaten';
  String aboutAYear(int year) => '~1 Jahr';
  String years(int years) => '$years Jahren';
  String wordSeparator() => ' ';
}

class EnMessages implements LookupMessages {
  String prefixAgo() => '';
  String prefixFromNow() => '';
  String suffixAgo() => 'ago';
  String suffixFromNow() => 'from now';
  String lessThanOneMinute(int seconds) => '$seconds seconds';
  String aboutAMinute(int minutes) => 'a minute';
  String minutes(int minutes) => '$minutes minutes';
  String aboutAnHour(int minutes) => 'about an hour';
  String hours(int hours) => '$hours hours';
  String aDay(int hours) => 'a day';
  String days(int days) => '$days days';
  String aboutAMonth(int days) => 'about a month';
  String months(int months) => '$months months';
  String aboutAYear(int year) => 'about a year';
  String years(int years) => '$years years';
  String wordSeparator() => ' ';
}
