import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonthYearFormat = DateFormat('d MMMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('d MMM');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _timeAmPmFormat = DateFormat('hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String formatDate(DateTime date) {
    return _dayMonthYearFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatTimeAmPm(DateTime date) {
    return _timeAmPmFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String getIndonesianDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '';
    }
  }

  static String getIndonesianFullDayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  static String getRelativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Besok';
    if (diff == -1) return 'Kemarin';
    if (diff > 1 && diff <= 7) return '${getIndonesianFullDayName(date)} depan';
    return formatDate(date);
  }
}
