import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
