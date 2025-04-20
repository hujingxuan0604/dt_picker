import 'package:flutter/material.dart';

/// 日期选择器显示模式，控制哪些日期组件可见
class DatePickerDisplayMode {
  final bool showDay;
  final bool showMonth;
  final bool showYear;
  /// 是否显示时间
  final bool showTime;

  const DatePickerDisplayMode({
    required this.showDay,
    required this.showMonth,
    required this.showYear,
    this.showTime = false,
  });

  /// 完整模式：显示年、月、日
  static const DatePickerDisplayMode full = DatePickerDisplayMode(
    showDay: true,
    showMonth: true,
    showYear: true,
  );

  /// 年月模式：只显示年和月
  static const DatePickerDisplayMode yearMonth = DatePickerDisplayMode(
    showDay: false,
    showMonth: true,
    showYear: true,
  );

  /// 月日模式：只显示月和日
  static const DatePickerDisplayMode monthDay = DatePickerDisplayMode(
    showDay: true,
    showMonth: true,
    showYear: false,
  );

  /// 年模式：只显示年
  static const DatePickerDisplayMode year = DatePickerDisplayMode(
    showDay: false,
    showMonth: false,
    showYear: true,
  );

  /// 月模式：只显示月
  static const DatePickerDisplayMode month = DatePickerDisplayMode(
    showDay: false,
    showMonth: true,
    showYear: false,
  );

  /// 日模式：只显示日
  static const DatePickerDisplayMode day = DatePickerDisplayMode(
    showDay: true,
    showMonth: false,
    showYear: false,
  );
  
  /// 日期时间模式：显示年月日和时间
  static const DatePickerDisplayMode dateTime = DatePickerDisplayMode(
    showDay: true,
    showMonth: true,
    showYear: true,
    showTime: true,
  );
  
  /// 年月时间模式：显示年月和时间
  static const DatePickerDisplayMode yearMonthTime = DatePickerDisplayMode(
    showDay: false,
    showMonth: true,
    showYear: true,
    showTime: true,
  );
}

/// 日期选择器视图模式
enum DatePickerViewMode {
  /// 日期视图
  day,
  /// 月份视图
  month,
  /// 年份视图
  year,
}

/// 日期选择器控制器
class DatePickerController extends ChangeNotifier {
  /// 当前选中的日期
  DateTime _selectedDate;
  
  /// 当前显示的年份
  int _currentYear;
  
  /// 当前显示的月份
  int _currentMonth;
  
  /// 当前视图模式
  DatePickerViewMode _viewMode;
  
  /// 显示配置
  final DatePickerDisplayMode displayMode;

  /// 是否显示日期
  bool get showDay => displayMode.showDay;
  
  /// 是否显示月份
  bool get showMonth => displayMode.showMonth;
  
  /// 是否显示年份
  bool get showYear => displayMode.showYear;

  /// 获取当前选中的日期
  DateTime get selectedDate => _selectedDate;
  
  /// 获取当前显示的年份
  int get currentYear => _currentYear;
  
  /// 获取当前显示的月份
  int get currentMonth => _currentMonth;
  
  /// 获取当前视图模式
  DatePickerViewMode get viewMode => _viewMode;

  /// 构造函数
  DatePickerController({
    DateTime? initialDate,
    this.displayMode = DatePickerDisplayMode.full,
  }) : 
    _selectedDate = initialDate ?? DateTime.now(),
    _currentYear = (initialDate ?? DateTime.now()).year,
    _currentMonth = (initialDate ?? DateTime.now()).month,
    _viewMode = _getInitialViewMode(displayMode);
    
  /// 根据显示模式获取初始视图模式
  static DatePickerViewMode _getInitialViewMode(DatePickerDisplayMode displayMode) {
    // 如果不显示日视图，但显示月视图，则初始显示月视图
    if (!displayMode.showDay && displayMode.showMonth) {
      return DatePickerViewMode.month;
    }
    // 如果不显示日视图和月视图，但显示年视图，则初始显示年视图
    else if (!displayMode.showDay && !displayMode.showMonth && displayMode.showYear) {
      return DatePickerViewMode.year;
    }
    // 默认显示日视图
    else {
      return DatePickerViewMode.day;
    }
  }

  /// 更新选中的日期
  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// 更新年月
  void updateMonth(int year, int month) {
    _currentYear = year;
    _currentMonth = month;
    notifyListeners();
  }

  /// 切换到日期视图模式
  void switchToDayMode() {
    if (showDay) {
      _viewMode = DatePickerViewMode.day;
      print('DatePickerController: 切换到日期视图模式');
      notifyListeners();
    }
  }

  /// 切换到月份视图模式
  void switchToMonthMode() {
    if (showMonth) {
      _viewMode = DatePickerViewMode.month;
      print('DatePickerController: 切换到月份视图模式');
      notifyListeners();
    }
  }

  /// 切换到年份视图模式
  void switchToYearMode() {
    if (showYear) {
      _viewMode = DatePickerViewMode.year;
      print('DatePickerController: 切换到年份视图模式');
      notifyListeners();
    }
  }

  /// 下一个月
  void nextMonth() {
    if (_currentMonth == 12) {
      _currentMonth = 1;
      _currentYear++;
    } else {
      _currentMonth++;
    }
    notifyListeners();
  }

  /// 上一个月
  void previousMonth() {
    if (_currentMonth == 1) {
      _currentMonth = 12;
      _currentYear--;
    } else {
      _currentMonth--;
    }
    notifyListeners();
  }

  /// 下一年
  void nextYear() {
    _currentYear++;
    notifyListeners();
  }

  /// 上一年
  void previousYear() {
    _currentYear--;
    notifyListeners();
  }
} 