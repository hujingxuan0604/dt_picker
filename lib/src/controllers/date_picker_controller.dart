import 'package:flutter/material.dart';

/// 日期选择器视图模式
enum DatePickerViewMode {
  /// 日期选择模式
  day,
  /// 月份选择模式
  month,
  /// 年份选择模式
  year,
}

/// 日期选择器显示模式
enum DatePickerDisplayMode {
  /// 完整显示：年-月-日（含时间）
  full(showYear: true, showMonth: true, showDay: true, showTime: true, initialViewMode: DatePickerViewMode.day),
  
  /// 仅显示月-日（无时间）
  monthDay(showYear: false, showMonth: true, showDay: true, showTime: false, initialViewMode: DatePickerViewMode.day),
  
  /// 仅显示年-月（无时间）
  yearMonth(showYear: true, showMonth: true, showDay: false, showTime: false, initialViewMode: DatePickerViewMode.month),
  
  /// 仅显示月份（无时间）
  monthOnly(showYear: false, showMonth: true, showDay: false, showTime: false, initialViewMode: DatePickerViewMode.month),
  
  /// 仅显示年份（无时间）
  yearOnly(showYear: true, showMonth: false, showDay: false, showTime: false, initialViewMode: DatePickerViewMode.year),
  
  /// 完整显示：年-月-日（无时间）
  dateOnly(showYear: true, showMonth: true, showDay: true, showTime: false, initialViewMode: DatePickerViewMode.day);
  
  final bool showYear;
  final bool showMonth;
  final bool showDay;
  final bool showTime; // 是否显示时间
  final DatePickerViewMode initialViewMode;
  
  const DatePickerDisplayMode({
    required this.showYear,
    required this.showMonth,
    required this.showDay,
    required this.showTime,
    required this.initialViewMode,
  });
}

/// 日期选择器控制器
class DatePickerController extends ChangeNotifier {
  DateTime _selectedDate;
  DateTime _currentMonth;
  
  /// 当前视图模式
  DatePickerViewMode _viewMode;
  
  /// 显示模式配置
  final DatePickerDisplayMode displayMode;
  
  DatePickerController({
    DateTime? initialDate,
    this.displayMode = DatePickerDisplayMode.full,
  }) : _selectedDate = initialDate ?? DateTime.now(),
       _currentMonth = DateTime(
         initialDate?.year ?? DateTime.now().year,
         initialDate?.month ?? DateTime.now().month,
         1
       ),
       _viewMode = displayMode.initialViewMode;
  
  /// 当前选择的日期
  DateTime get selectedDate => _selectedDate;
  
  /// 当前显示的月份
  DateTime get currentMonth => _currentMonth;
  
  /// 当前视图模式
  DatePickerViewMode get viewMode => _viewMode;
  
  /// 是否显示日期选择
  bool get showDay => displayMode.showDay;
  
  /// 是否显示月份选择
  bool get showMonth => displayMode.showMonth;
  
  /// 是否显示年份选择
  bool get showYear => displayMode.showYear;
  
  /// 切换到日期视图模式
  void switchToDayMode() {
    if (displayMode.showDay) {
      _viewMode = DatePickerViewMode.day;
      notifyListeners();
    }
  }
  
  /// 切换到月份视图模式
  void switchToMonthMode() {
    if (displayMode.showMonth) {
      _viewMode = DatePickerViewMode.month;
      notifyListeners();
    }
  }
  
  /// 切换到年份视图模式
  void switchToYearMode() {
    if (displayMode.showYear) {
      _viewMode = DatePickerViewMode.year;
      notifyListeners();
    }
  }
  
  /// 更新选择的日期
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  /// 更改月份（加减月）
  void changeMonth(int delta) {
    _currentMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + delta,
      1,
    );
    notifyListeners();
  }
  
  /// 更新当前显示的月份
  void updateMonth(int year, int month) {
    _currentMonth = DateTime(year, month, 1);
    
    // 更新选中日期的月份
    _selectedDate = DateTime(
      year, 
      month, 
      _selectedDate.day > 28 
        ? _getDaysInMonth(year, month) 
        : _selectedDate.day
    );
    
    // 根据显示模式决定下一步操作
    if (displayMode.showDay) {
      // 如果显示日期模式，则选择月份后自动返回日期视图
      _viewMode = DatePickerViewMode.day;
    }
    
    notifyListeners();
  }
  
  /// 获取指定年月的天数
  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
  
  /// 更新当前显示的年份
  void updateYear(int year) {
    _currentMonth = DateTime(year, _currentMonth.month, 1);
    
    // 更新选中日期的年份
    _selectedDate = DateTime(
      year, 
      _selectedDate.month, 
      _selectedDate.day > 28 
        ? _getDaysInMonth(year, _selectedDate.month) 
        : _selectedDate.day
    );
    
    // 根据显示模式决定下一步操作
    if (displayMode.showMonth && !displayMode.showDay) {
      // 如果只显示年月，则选择年份后自动切换到月份视图
      _viewMode = DatePickerViewMode.month;
    } else if (!displayMode.showMonth && !displayMode.showDay) {
      // 如果只显示年份，则不切换视图
      // 视图保持在年份选择模式
    } else {
      // 默认情况，选择年份后切换到月份视图
      _viewMode = DatePickerViewMode.month;
    }
    
    notifyListeners();
  }
  
  /// 获取月份中的所有日期
  List<DateTime> getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }
  
  /// 获取日历中显示的所有日期（包括上下月的部分日期）
  List<DateTime> getCalendarDays() {
    final daysInMonth = getDaysInMonth(_currentMonth);
    final firstDay = daysInMonth.first;
    final firstDayOffset = (firstDay.weekday - 1) % 7;
    
    // 上个月的日期
    final previousMonthDays = firstDayOffset > 0
        ? getDaysInMonth(
            DateTime(_currentMonth.year, _currentMonth.month - 1, 1),
          ).sublist(
            getDaysInMonth(
              DateTime(_currentMonth.year, _currentMonth.month - 1, 1),
            ).length - firstDayOffset,
          )
        : <DateTime>[];
    
    // 下个月的日期
    final totalDays = previousMonthDays.length + daysInMonth.length;
    final nextMonthDays = (7 - (totalDays % 7)) % 7 == 0
        ? <DateTime>[]
        : List<DateTime>.generate(
            (7 - (totalDays % 7)) % 7,
            (i) => DateTime(_currentMonth.year, _currentMonth.month + 1, i + 1),
          );
    
    // 确保总是返回6行日历（6周）
    final List<DateTime> allDays = [
      ...previousMonthDays,
      ...daysInMonth,
      ...nextMonthDays,
    ];
    final weeksCount = (allDays.length / 7).ceil();
    
    if (weeksCount < 6) {
      // 如果不足6周，添加下个月的日期
      final daysToAdd = (6 - weeksCount) * 7;
      final lastDate = allDays.last;
      final List<DateTime> additionalDays = List<DateTime>.generate(
        daysToAdd,
        (i) => DateTime(lastDate.year, lastDate.month, lastDate.day + i + 1),
      );
      allDays.addAll(additionalDays);
    }
    
    return allDays;
  }
  
  /// 是否是当前月
  bool isCurrentMonth(DateTime date) {
    return date.year == _currentMonth.year && date.month == _currentMonth.month;
  }
  
  /// 是否是今天
  bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year && 
           date.month == today.month && 
           date.day == today.day;
  }
  
  /// 是否是选中的日期
  bool isSelectedDate(DateTime date) {
    return date.year == _selectedDate.year && 
           date.month == _selectedDate.month && 
           date.day == _selectedDate.day;
  }
} 