import 'package:day/day.dart';
/// convert a timestamp to given format string
String formatTimeByStr(num timestamp, {String str = 'YYYY-MM-DD HH:mm:ss'}) {
  if (timestamp == null || timestamp == 0) {
    return '';
  }
  var time = Day.fromUnix(timestamp * 1000);
  return time.format(str);
}