import 'package:jiffy/jiffy.dart';

/// 日期工具类
class DateUtil {
  /// 获取月份中的所有日期
  static List<DateTime> getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  /// 获取日历中显示的所有日期（包括上下月的部分日期）
  static List<DateTime> getCalendarDays(
    DateTime month, {
    bool sixWeeks = true,
  }) {
    final daysInMonth = getDaysInMonth(month);
    final firstDay = daysInMonth.first;
    final firstDayOffset = (firstDay.weekday - 1) % 7;

    // 上个月的日期
    final previousMonthDays = firstDayOffset > 0
        ? getDaysInMonth(
            DateTime(month.year, month.month - 1, 1),
          ).sublist(
            getDaysInMonth(
                  DateTime(month.year, month.month - 1, 1),
                ).length -
                firstDayOffset,
          )
        : <DateTime>[];

    // 下个月的日期
    final totalDays = previousMonthDays.length + daysInMonth.length;
    final nextMonthDays = (7 - (totalDays % 7)) % 7 == 0
        ? <DateTime>[]
        : List<DateTime>.generate(
            (7 - (totalDays % 7)) % 7,
            (i) => DateTime(month.year, month.month + 1, i + 1),
          );

    // 合并日期
    final List<DateTime> allDays = [
      ...previousMonthDays,
      ...daysInMonth,
      ...nextMonthDays,
    ];

    // 如果需要固定6周，则添加额外的日期
    if (sixWeeks) {
      final weeksCount = (allDays.length / 7).ceil();
      if (weeksCount < 6) {
        final daysToAdd = (6 - weeksCount) * 7;
        final lastDate = allDays.last;
        final List<DateTime> additionalDays = List<DateTime>.generate(
          daysToAdd,
          (i) => DateTime(lastDate.year, lastDate.month, lastDate.day + i + 1),
        );
        allDays.addAll(additionalDays);
      }
    }

    return allDays;
  }

  /// 判断两个日期是否是同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return Jiffy.parseFromDateTime(a).isSame(Jiffy.parseFromDateTime(b), unit: Unit.day);
  }

  /// 判断是否是今天
  static bool isToday(DateTime date) {
    return Jiffy.parseFromDateTime(date).isSame(Jiffy.now(), unit: Unit.day);
  }

  /// 判断日期是否为昨天
  static bool isYesterday(DateTime date) {
    return Jiffy.parseFromDateTime(date).isSame(Jiffy.now().subtract(days: 1), unit: Unit.day);
  }

  /// 判断日期是否为前天
  static bool isDayBeforeYesterday(DateTime date) {
    return Jiffy.parseFromDateTime(date).isSame(Jiffy.now().subtract(days: 2), unit: Unit.day);
  }

  /// 判断是否是本月
  static bool isSameMonth(DateTime a, DateTime b) {
    return Jiffy.parseFromDateTime(a).isSame(Jiffy.parseFromDateTime(b), unit: Unit.month);
  }

  /// 格式化日期字符串
  static String formatDate(
    DateTime date, {
    String separator = '-',
    bool showYear = true,
    bool showMonth = true,
    bool showDay = true,
  }) {
    String pattern = '';
    if (showYear) {
      pattern += 'yyyy';
      if (showMonth) pattern += separator;
    }
    if (showMonth) {
      pattern += 'MM';
      if (showDay) pattern += separator;
    }
    if (showDay) {
      pattern += 'dd';
    }
    return Jiffy.parseFromDateTime(date).format(pattern: pattern);
  }
}
