import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(DateTime dateTime, String format) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(dateTime);
    return formatted;
  }
}
