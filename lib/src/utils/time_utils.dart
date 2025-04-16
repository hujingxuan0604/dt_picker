import 'package:flutter/material.dart';

/// 时间工具类
class TimeUtils {
  /// 格式化时间字符串
  static String formatTime(
    TimeOfDay time, {
    int? second,
    bool showSeconds = false,
    String separator = ':',
  }) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    
    if (showSeconds && second != null) {
      final secondStr = second.toString().padLeft(2, '0');
      return '$hour$separator$minute$separator$secondStr';
    }
    
    return '$hour$separator$minute';
  }

  /// 将TimeOfDay转换为分钟数（自午夜起）
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// 将分钟数转换为TimeOfDay
  static TimeOfDay minutesToTimeOfDay(int minutes) {
    return TimeOfDay(
      hour: (minutes ~/ 60) % 24,
      minute: minutes % 60,
    );
  }

  /// 计算两个时间之间的分钟差
  static int minutesDifference(TimeOfDay start, TimeOfDay end) {
    return timeOfDayToMinutes(end) - timeOfDayToMinutes(start);
  }

  /// 将秒数转换为时分秒字符串
  static String secondsToString(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    
    return '$hours:$minutes:$secs';
  }
  
  /// 将字符串解析为TimeOfDay
  static TimeOfDay? parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // 解析失败
    }
    
    return null;
  }
  
  /// 从TimeOfDay和秒数创建DateTime
  static DateTime createDateTime(TimeOfDay time, [int second = 0]) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      second,
    );
  }
} 