import 'package:intl/intl.dart';

class DateUtils {
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  static final DateFormat _apiFormatter = DateFormat(apiDateFormat);
  static final DateFormat _displayFormatter = DateFormat(displayDateFormat);
  static final DateFormat _displayDateTimeFormatter = DateFormat(
    displayDateTimeFormat,
  );

  static String formatForApi(DateTime date) {
    return _apiFormatter.format(date);
  }

  static String formatForDisplay(DateTime date) {
    return _displayFormatter.format(date);
  }

  static String formatDateTimeForDisplay(DateTime dateTime) {
    return _displayDateTimeFormatter.format(dateTime);
  }

  static DateTime parseFromApi(String dateString) {
    return _apiFormatter.parse(dateString);
  }

  static DateTime? tryParseFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _apiFormatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static String getRelativeTimeString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatForDisplay(date);
    }
  }

  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}
