import 'package:intl/intl.dart';

/// Date helpers with localized (zh_CN) formatting.
class DateHelper {
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// e.g. 08月09日 2026年
  static String formatShort(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}月${d.day.toString().padLeft(2, '0')}日';

  static String formatFull(DateTime d) =>
      '${d.year}年${d.month.toString().padLeft(2, '0')}月${d.day.toString().padLeft(2, '0')}日';

  /// Day-of-week prefix, e.g. 周日
  static String weekdayCn(DateTime d) {
    const labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return labels[d.weekday - 1];
  }

  /// HH:mm (24-hour) for a task due time.
  static String formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Friendly "today" / "tomorrow" / "MM月dd日"
  static String relative(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    return DateFormat('MM月dd日').format(d);
  }
}