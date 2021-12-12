import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(DateTime dateTime, String format) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(dateTime);
    return formatted;
  }

  static DateTime timeStampToDateTime(Timestamp time) {
    DateTime dateToCheck =
        DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
    DateTime aDate = DateTime(dateToCheck.year, dateToCheck.month,
        dateToCheck.day, dateToCheck.hour, dateToCheck.minute);
    return aDate;
  }

  static DateTime timeStampToDay(Timestamp time) {
    DateTime dateToCheck =
        DateTime.fromMicrosecondsSinceEpoch(time.microsecondsSinceEpoch);
    DateTime aDate =
        DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
    return aDate;
  }
}
