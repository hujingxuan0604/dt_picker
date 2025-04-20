import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';

/// 日期选择器日历组件
class DatePickerCalendar extends StatefulWidget {
  /// 日期选择器控制器
  final DatePickerController controller;

  /// 第一个可选择的日期
  final DateTime? firstDate;

  /// 最后一个可选择的日期
  final DateTime? lastDate;

  /// 日期改变回调函数
  final ValueChanged<DateTime>? onDateChanged;

  /// 构造函数
  const DatePickerCalendar({
    Key? key,
    required this.controller,
    this.firstDate,
    this.lastDate,
    this.onDateChanged,
  }) : super(key: key);

  @override
  State<DatePickerCalendar> createState() => _DatePickerCalendarState();
}

class _DatePickerCalendarState extends State<DatePickerCalendar> {
  @override
  void initState() {
    super.initState();
    // 添加控制器监听，当控制器状态变化时重新构建界面
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    // 移除监听
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  // 控制器状态变化处理函数
  void _onControllerChanged() {
    setState(() {
      // 状态变化，触发重新构建
    });
  }

  @override
  Widget build(BuildContext context) {
    // 直接根据控制器状态构建不同的日历组件
    switch (widget.controller.viewMode) {
      case DatePickerViewMode.day:
        return _buildDayView(context);
      case DatePickerViewMode.month:
        return _buildMonthView(context);
      case DatePickerViewMode.year:
        return _buildYearView(context);
    }
  }

  /// 构建日期视图
  Widget _buildDayView(BuildContext context) {
    final currentYear = widget.controller.currentYear;
    final currentMonth = widget.controller.currentMonth;

    // 获取当前月的第一天和天数
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    // 计算本月第一天是星期几（0是星期一，6是星期日）
    int firstWeekday = firstDayOfMonth.weekday % 7;

    // 准备日历网格数据
    final calendarDays = <DateTime>[];

    // 添加上个月的日期
    final lastMonth = DateTime(currentYear, currentMonth, 0);
    final daysInLastMonth = lastMonth.day;
    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(DateTime(lastMonth.year, lastMonth.month,
          daysInLastMonth - firstWeekday + i + 1));
    }

    // 添加本月的日期
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(currentYear, currentMonth, i));
    }

    // 计算需要多少行来显示本月日期
    // 第一天的星期几 + 当月的总天数
    final int totalPositions = firstWeekday + daysInMonth;
    // 计算总共需要多少行，取上限为5
    final int rows = totalPositions <= 35 ? 5 : 6;

    // 如果行数超过5，那么截断到35天（5行 * 7列 = 35个日期）
    final int maxDays = rows * 7;

    // 添加下个月的日期（补齐到指定行数）
    final int remainingDays = maxDays - calendarDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(DateTime(currentYear, currentMonth + 1, i));
    }

    // 确保不会超过35天
    if (calendarDays.length > 35) {
      calendarDays.length = 35;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 星期标题行
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (String weekDay in ['一', '二', '三', '四', '五', '六', '日'])
                SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      weekDay,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 日期网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final date = calendarDays[index];
            final isCurrentMonth = date.month == currentMonth;
            final isToday = _isToday(date);
            final isSelected = _isSelectedDate(date);
            final isDisabled = _isDateDisabled(date);

            return GestureDetector(
              onTap: isDisabled ? null : () => _selectDate(date),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isSelected
                      ? Colors.blue
                      : isToday
                          ? const Color(0xFFE3F2FD)
                          : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : isToday
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.transparent,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.all(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                                ? isDisabled
                                    ? Colors.grey
                                    : Colors.black87
                                : Colors.grey.withOpacity(0.5),
                        fontWeight:
                            isToday || isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 构建月份视图
  Widget _buildMonthView(BuildContext context) {
    final currentYear = widget.controller.currentYear;

    // 月份名称列表
    final List<String> monthNames = [
      '一月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '十一月',
      '十二月'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isCurrentMonth = month == widget.controller.selectedDate.month &&
            currentYear == widget.controller.selectedDate.year;
        final isDisabled = _isMonthDisabled(currentYear, month);

        return GestureDetector(
          onTap: isDisabled ? null : () => _selectMonth(month),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentMonth ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color:
                    isCurrentMonth ? Colors.blue : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              monthNames[index],
              style: TextStyle(
                fontSize: 14,
                color: isDisabled
                    ? Colors.grey
                    : isCurrentMonth
                        ? Colors.blue
                        : Colors.black87,
                fontWeight: isCurrentMonth ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建年份视图
  Widget _buildYearView(BuildContext context) {
    final selectedYear = widget.controller.selectedDate.year;

    // 显示12年，当前年份居中
    final int startYear = widget.controller.currentYear - 5;
    final List<int> years = List.generate(12, (index) => startYear + index);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final isSelected = year == selectedYear;
        final isDisabled = _isYearDisabled(year);

        return GestureDetector(
          onTap: isDisabled ? null : () => _selectYear(year),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              year.toString(),
              style: TextStyle(
                fontSize: 14,
                color: isDisabled
                    ? Colors.grey
                    : isSelected
                        ? Colors.blue
                        : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 选择日期
  void _selectDate(DateTime date) {
    // 更新控制器
    if (date.month != widget.controller.currentMonth) {
      widget.controller.updateMonth(date.year, date.month);
    }

    // 更新选中的日期
    widget.controller.updateSelectedDate(date);

    // 调用回调
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(date);
    }
  }

  /// 选择月份
  void _selectMonth(int month) {
    widget.controller.updateMonth(widget.controller.currentYear, month);

    // 如果有日期视图，选择月份后切换到日期视图
    if (widget.controller.showDay) {
      widget.controller.switchToDayMode();
    } else {
      // 否则，更新选中的日期
      final newDate = DateTime(
        widget.controller.currentYear,
        month,
        widget.controller.selectedDate.day > 28
            ? _daysInMonth(widget.controller.currentYear, month)
            : widget.controller.selectedDate.day,
      );

      widget.controller.updateSelectedDate(newDate);

      // 调用回调
      if (widget.onDateChanged != null) {
        widget.onDateChanged!(newDate);
      }
    }
  }

  /// 选择年份
  void _selectYear(int year) {
    widget.controller.updateMonth(year, widget.controller.currentMonth);

    // 如果有月份视图，选择年份后切换到月份视图
    if (widget.controller.showMonth) {
      widget.controller.switchToMonthMode();
    } else {
      // 否则，更新选中的日期
      final newDate = DateTime(
        year,
        widget.controller.selectedDate.month,
        widget.controller.selectedDate.day > 28
            ? _daysInMonth(year, widget.controller.selectedDate.month)
            : widget.controller.selectedDate.day,
      );

      widget.controller.updateSelectedDate(newDate);

      // 调用回调
      if (widget.onDateChanged != null) {
        widget.onDateChanged!(newDate);
      }
    }
  }

  /// 计算指定年月的天数
  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// 判断日期是否为今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断日期是否为选中的日期
  bool _isSelectedDate(DateTime date) {
    final selected = widget.controller.selectedDate;
    return date.year == selected.year &&
        date.month == selected.month &&
        date.day == selected.day;
  }

  /// 判断日期是否在可选范围内
  bool _isDateDisabled(DateTime date) {
    if (widget.firstDate != null && date.isBefore(widget.firstDate!)) {
      return true;
    }
    if (widget.lastDate != null && date.isAfter(widget.lastDate!)) {
      return true;
    }
    return false;
  }

  /// 判断月份是否在可选范围内
  bool _isMonthDisabled(int year, int month) {
    // 获取该月的第一天和最后一天
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);

    // 检查是否在可选范围内
    if (widget.firstDate != null &&
        lastDayOfMonth.isBefore(widget.firstDate!)) {
      return true;
    }
    if (widget.lastDate != null && firstDayOfMonth.isAfter(widget.lastDate!)) {
      return true;
    }
    return false;
  }

  /// 判断年份是否在可选范围内
  bool _isYearDisabled(int year) {
    // 获取该年的第一天和最后一天
    final firstDayOfYear = DateTime(year, 1, 1);
    final lastDayOfYear = DateTime(year + 1, 1, 0);

    // 检查是否在可选范围内
    if (widget.firstDate != null && lastDayOfYear.isBefore(widget.firstDate!)) {
      return true;
    }
    if (widget.lastDate != null && firstDayOfYear.isAfter(widget.lastDate!)) {
      return true;
    }
    return false;
  }
}
