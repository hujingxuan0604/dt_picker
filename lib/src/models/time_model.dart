import 'package:flutter/material.dart';

/// 时间选择模式
enum TimePickerMode {
  /// 键盘输入模式
  keyboard,
  /// 表盘选择模式
  dial,
  /// 小时选择
  hour,
  /// 分钟选择
  minute,
  /// 秒数选择
  second,
}

/// 带秒数的时间类
class TimeWithSeconds {
  final TimeOfDay time;
  final int second;

  TimeWithSeconds(this.time, this.second);

  /// 转换为DateTime
  DateTime toDateTime() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.hour,
      time.minute,
      second,
    );
  }

  /// 从DateTime创建
  factory TimeWithSeconds.fromDateTime(DateTime dateTime) {
    return TimeWithSeconds(
      TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      dateTime.second,
    );
  }

  /// 格式化时间字符串
  String format({bool showSeconds = true}) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final secondStr = second.toString().padLeft(2, '0');
    return showSeconds ? '$hour:$minute:$secondStr' : '$hour:$minute';
  }
} 