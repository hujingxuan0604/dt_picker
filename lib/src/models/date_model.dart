import 'package:flutter/material.dart';
import '../controllers/date_picker_controller.dart';
import 'package:jiffy/jiffy.dart';

/// 日期选择结果类
class DateTimeResult {
  final DateTime date;
  final TimeOfDay? time;
  final int? second;
  /// 日期显示模式，用于格式化输出
  final DatePickerDisplayMode dateDisplayMode;

  DateTimeResult({
    required this.date,
    this.time,
    this.second,
    this.dateDisplayMode = DatePickerDisplayMode.full,
  });

  /// 转换为完整的DateTime
  DateTime toDateTime() {
    if (time == null) {
      return date;
    }
    return DateTime(
      date.year,
      date.month,
      date.day,
      time!.hour,
      time!.minute,
      second ?? 0,
    );
  }

  /// 格式化日期时间字符串
  String format({
    bool? showDate,
    bool? showTime = true,
    bool? showSeconds,
    String dateSeparator = '-',
    String dateTimeSeparator = ' ',
  }) {
    String result = '';
    final bool effectiveShowDate = showDate ?? true;
    final bool effectiveShowSeconds = showSeconds ?? (second != null);
    if (effectiveShowDate) {
      String pattern = '';
      if (dateDisplayMode.showYear) {
        pattern += 'yyyy';
        if (dateDisplayMode.showMonth) pattern += dateSeparator;
      }
      if (dateDisplayMode.showMonth) {
        pattern += 'MM';
        if (dateDisplayMode.showDay) pattern += dateSeparator;
      }
      if (dateDisplayMode.showDay) {
        pattern += 'dd';
      }
      result += Jiffy.parseFromDateTime(date).format(pattern: pattern);
    }
    if (showTime ?? true && time != null) {
      if (effectiveShowDate && result.isNotEmpty) {
        result += dateTimeSeparator;
      }
      final hour = time!.hour.toString().padLeft(2, '0');
      final minute = time!.minute.toString().padLeft(2, '0');
      result += '$hour:$minute';
      if (effectiveShowSeconds && second != null) {
        final secondStr = second.toString().padLeft(2, '0');
        result += ':$secondStr';
      }
    }
    return result;
  }
} 