import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';
import '../../utils/responsive_utils.dart'; // 确保导入响应式工具类

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
    // 限制日历组件在大屏幕上的最大宽度
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.isDesktop(context) ? 420 : double.infinity,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCalendarContent(context),
        ),
      ),
    );
  }

  /// 根据不同视图模式构建日历内容
  Widget _buildCalendarContent(BuildContext context) {
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
    final theme = Theme.of(context);
    final currentYear = widget.controller.currentYear;
    final currentMonth = widget.controller.currentMonth;

    // 为日期视图添加key，以便在月份切换时启用动画
    final viewKey = ValueKey('day-$currentYear-$currentMonth');

    // 获取当前月的第一天和天数
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final daysInMonth = DateTime(currentYear, currentMonth + 1, 0).day;

    // 计算本月第一天是星期几（以周一为1，周日为7）
    int firstWeekday = firstDayOfMonth.weekday;

    // 因为我们的日历是从周一开始的，所以要调整值
    // 周一应该是0，周日应该是6
    int firstWeekdayAdjusted = firstWeekday - 1;

    // 准备日历网格数据
    final calendarDays = <DateTime>[];

    // 添加上个月的日期
    final lastMonth = DateTime(currentYear, currentMonth, 0);
    final daysInLastMonth = lastMonth.day;
    for (int i = 0; i < firstWeekdayAdjusted; i++) {
      calendarDays.add(DateTime(lastMonth.year, lastMonth.month,
          daysInLastMonth - firstWeekdayAdjusted + i + 1));
    }

    // 添加本月的日期
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(currentYear, currentMonth, i));
    }

    // 计算需要多少行来显示本月日期
    // 强制使用6行来显示日历，保持布局一致性
    const int rows = 6;

    // 计算总共需要的日期数量：6行 * 7列 = 42个日期
    const int maxDays = rows * 7;

    // 添加下个月的日期（补齐到指定行数）
    final int remainingDays = maxDays - calendarDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(DateTime(currentYear, currentMonth + 1, i));
    }

    // 根据屏幕尺寸调整网格间距
    double gridSpacing = ResponsiveUtils.isMobile(context)
        ? 1
        : (ResponsiveUtils.isTablet(context) ? 2 : 3);

    return Column(
      key: viewKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 星期标题行
        _buildCalendarHeader(theme),
        // 日期网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.0,
            mainAxisSpacing: gridSpacing,
            crossAxisSpacing: gridSpacing,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final date = calendarDays[index];
            final isCurrentMonth = date.month == currentMonth;
            return _buildDayCell(context, date, isCurrentMonth, theme);
          },
        ),
      ],
    );
  }

  /// 构建月份视图
  Widget _buildMonthView(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentYear = widget.controller.currentYear;

    // 根据主题确定颜色
    final primaryColor = theme.colorScheme.primary;
    final selectedBgColor =
        isDarkMode ? primaryColor.withOpacity(0.3) : const Color(0xFFE3F2FD);
    final normalBgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final disabledTextColor = theme.colorScheme.onSurface.withOpacity(0.4);
    final selectedTextColor = theme.colorScheme.primary;

    // 根据屏幕尺寸调整网格间距和字体大小
    double gridSpacing = ResponsiveUtils.isMobile(context)
        ? 6
        : (ResponsiveUtils.isTablet(context) ? 8 : 10);
    double fontSize = ResponsiveUtils.isMobile(context)
        ? 13
        : (ResponsiveUtils.isTablet(context) ? 14 : 16);
    double childAspectRatio = ResponsiveUtils.isMobile(context) ? 1.3 : 1.5;
    double borderRadius = ResponsiveUtils.isMobile(context) ? 4 : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
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
              color: isCurrentMonth ? selectedBgColor : normalBgColor,
              borderRadius: BorderRadius.circular(
                  ResponsiveUtils.isMobile(context) ? 4 : 6),
              border: Border.all(
                color: isCurrentMonth
                    ? primaryColor
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              monthNames[index],
              style: TextStyle(
                fontSize: fontSize,
                color: isDisabled
                    ? disabledTextColor
                    : isCurrentMonth
                        ? selectedTextColor
                        : textColor,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final selectedYear = widget.controller.selectedDate.year;

    // 添加唯一key，确保年份变化时视图会重新构建
    final viewKey = ValueKey('year-${widget.controller.currentYear}');

    // 根据主题确定颜色
    final primaryColor = theme.colorScheme.primary;
    final selectedBgColor =
        isDarkMode ? primaryColor.withOpacity(0.3) : const Color(0xFFE3F2FD);
    final normalBgColor = theme.colorScheme.surface;
    final textColor = theme.colorScheme.onSurface;
    final disabledTextColor = theme.colorScheme.onSurface.withOpacity(0.4);
    final selectedTextColor = theme.colorScheme.primary;

    // 显示12年，当前年份居中
    final int startYear = widget.controller.currentYear - 5;
    final List<int> years = List.generate(12, (index) => startYear + index);

    // 根据屏幕尺寸调整网格间距和字体大小
    double gridSpacing = ResponsiveUtils.isMobile(context)
        ? 6
        : (ResponsiveUtils.isTablet(context) ? 8 : 10);
    double fontSize = ResponsiveUtils.isMobile(context)
        ? 13
        : (ResponsiveUtils.isTablet(context) ? 14 : 16);
    double childAspectRatio = ResponsiveUtils.isMobile(context) ? 1.3 : 1.5;
    double borderRadius = ResponsiveUtils.isMobile(context) ? 4 : 6;

    return Column(
      key: viewKey, // 添加唯一key
      mainAxisSize: MainAxisSize.min,
      children: [
        // 添加年份范围显示
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            '$startYear - ${startYear + 11}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
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
                  color: isSelected ? selectedBgColor : normalBgColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: isDisabled
                        ? disabledTextColor
                        : isSelected
                            ? selectedTextColor
                            : textColor,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 选择日期
  void _selectDate(DateTime date) {
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

  /// 构建日历头部
  Widget _buildCalendarHeader(ThemeData theme) {
    // 星期几名称，从周一到周日
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];

    // 根据屏幕尺寸调整头部高度和字体大小
    double headerHeight = ResponsiveUtils.isMobile(context)
        ? 28
        : (ResponsiveUtils.isTablet(context) ? 32 : 36);
    double fontSize = ResponsiveUtils.isMobile(context)
        ? 12
        : (ResponsiveUtils.isTablet(context) ? 13 : 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        // 在我们的数组中，索引5是周六，索引6是周日
        final isWeekend = index == 5 || index == 6;
        return SizedBox(
          width: headerHeight,
          height: headerHeight,
          child: Center(
            child: Text(
              weekdays[index],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWeekend
                    ? theme.colorScheme.primary.withOpacity(0.8)
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 构建日期单元格
  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    bool isCurrentMonth,
    ThemeData theme,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(
      widget.controller.selectedDate.year,
      widget.controller.selectedDate.month,
      widget.controller.selectedDate.day,
    );

    // 判断日期是否为今天、选中日期
    final isSelected = date.isAtSameMomentAs(selectedDate);
    final isToday = date.isAtSameMomentAs(today);

    // 周六是6，周日是7
    final isWeekend = date.weekday == 6 || date.weekday == 7;

    final isDarkMode = theme.brightness == Brightness.dark;

    // 是否禁用（超出可选范围）
    final isDisabled = _isDateDisabled(date);

    // 文本颜色
    Color textColor;
    if (isDisabled) {
      textColor = theme.colorScheme.onSurface.withOpacity(0.3);
    } else if (isSelected) {
      textColor = theme.colorScheme.onPrimary;
    } else if (isToday) {
      textColor = theme.colorScheme.primary;
    } else if (!isCurrentMonth) {
      // 上个月或下个月的日期使用更柔和的颜色
      textColor = isDarkMode
          ? theme.colorScheme.onSurface.withOpacity(0.3)
          : theme.colorScheme.onSurface.withOpacity(0.35);
    } else if (isWeekend) {
      textColor = theme.colorScheme.primary.withOpacity(0.8);
    } else {
      textColor = theme.colorScheme.onSurface;
    }

    // 背景颜色
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = theme.colorScheme.primary;
    } else if (isToday) {
      backgroundColor = isDarkMode
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.primaryContainer;
    } else if (!isCurrentMonth) {
      // 非当前月的日期背景色，使其更柔和更低调
      backgroundColor = isDarkMode
          ? theme.colorScheme.surfaceVariant.withOpacity(0.08)
          : theme.colorScheme.surfaceVariant.withOpacity(0.1);
    }

    // 边框
    Border? border;
    if (isToday && !isSelected) {
      border = Border.all(
        color: theme.colorScheme.primary,
        width: 1,
      );
    }

    // 添加提示文本
    String? tooltip;
    if (!isCurrentMonth) {
      tooltip = '${date.year}年${monthNames[date.month - 1]} ${date.day}日';
    }

    // 根据屏幕尺寸调整单元格大小和字体大小
    double cellSize = ResponsiveUtils.getCalendarCellSize(context);
    double fontSize = ResponsiveUtils.isMobile(context)
        ? (!isCurrentMonth ? 10 : 12)
        : (ResponsiveUtils.isTablet(context)
            ? (!isCurrentMonth ? 11 : 13)
            : (!isCurrentMonth ? 12 : 14));

    return Tooltip(
      message: tooltip ?? '',
      showDuration: const Duration(milliseconds: 500),
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                // 如果点击的是当前月的日期，直接选中
                if (isCurrentMonth) {
                  _selectDate(date);
                } else {
                  // 如果是上个月或下个月的日期，先跳转到对应月份，再选中
                  widget.controller.updateMonth(date.year, date.month);
                  _selectDate(date);
                }
              },
        customBorder: const CircleBorder(),
        child: Container(
          width: cellSize,
          height: cellSize,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
