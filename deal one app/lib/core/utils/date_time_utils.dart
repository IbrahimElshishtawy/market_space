import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatIsoDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime, {String locale = 'ar'}) {
    return DateFormat('d MMM yyyy', locale).format(dateTime);
  }

  static String formatDateTime(DateTime dateTime, {String locale = 'ar'}) {
    return DateFormat('d MMM yyyy, h:mm a', locale).format(dateTime);
  }

  static DateTime? tryParseIsoDate(String? rawDateString) {
    if (rawDateString == null || rawDateString.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDateString);
  }
}
