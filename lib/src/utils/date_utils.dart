import 'package:flutter/material.dart';

/// 日期工具类
class DateUtils {
  /// 获取月份中的所有日期
  static List<DateTime> getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  /// 获取日历中显示的所有日期（包括上下月的部分日期）
  static List<DateTime> getCalendarDays(DateTime month, {bool sixWeeks = true}) {
    final DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
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
            ).length - firstDayOffset,
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
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 判断是否是今天
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// 判断是否是本月
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// 格式化日期字符串
  static String formatDate(
    DateTime date, {
    String separator = '-',
    bool showYear = true,
    bool showMonth = true,
    bool showDay = true,
  }) {
    final parts = <String>[];
    
    if (showYear) {
      parts.add(date.year.toString());
    }
    
    if (showMonth) {
      parts.add(date.month.toString().padLeft(2, '0'));
    }
    
    if (showDay) {
      parts.add(date.day.toString().padLeft(2, '0'));
    }
    
    return parts.join(separator);
  }
} 