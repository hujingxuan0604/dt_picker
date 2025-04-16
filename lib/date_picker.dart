import 'package:flutter/material.dart';
import 'src/models/date_model.dart';
import 'src/controllers/date_picker_controller.dart';
import 'src/widgets/date_picker/date_picker.dart';
import 'time_picker.dart';

// 导出核心组件和函数
export 'src/widgets/date_picker/date_picker.dart';
export 'src/widgets/date_picker/date_time_picker.dart';
export 'src/models/date_model.dart';
export 'src/controllers/date_picker_controller.dart';

/// 显示日期选择器对话框（重命名以避免与Flutter自带的冲突）
Future<DateTimeResult?> showCustomDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  TimeOfDay? initialTime,
  int? initialSecond,
  DateTime? firstDate,
  DateTime? lastDate,
  bool showSeconds = false,
  DatePickerDisplayMode dateDisplayMode = DatePickerDisplayMode.full,
}) async {
  final date = await showDatePicker2(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    displayMode: dateDisplayMode,
  );

  if (date == null) {
    return null;
  }

  // 仅当displayMode.showTime为true时才显示时间选择器
  TimeWithSeconds? time;
  int? second;

  if (dateDisplayMode.showTime) {
    time = await showTimePickerWithSeconds(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 0, minute: 0),
      initialSecond: initialSecond ?? 0,
      showSeconds: showSeconds,
    );

    second = showSeconds ? (time?.second ?? initialSecond ?? 0) : null;
  }

  return DateTimeResult(
    date: date,
    time: time?.time,
    second: second,
    dateDisplayMode: dateDisplayMode,
  );
}

class CustomDateTimePicker extends StatefulWidget {
  final bool showTimePicker;

  const CustomDateTimePicker({
    super.key,
    this.showTimePicker = true,
  });

  @override
  State<CustomDateTimePicker> createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedSecond = DateTime.now().second;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedTime = TimeOfDay.fromDateTime(now);
    _selectedSecond = now.second;
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePickerWithSeconds(
      context: context,
      initialTime: _selectedTime,
      initialSecond: _selectedSecond,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked.time;
        _selectedSecond = picked.second;
      });
    }
  }

  void _onDaySelected(DateTime day) {
    setState(() => _selectedDate = day);
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + delta,
        1,
      );
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  List<DateTime> _getCalendarDays() {
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDay = daysInMonth.first;
    final firstDayOffset = (firstDay.weekday - 1) % 7;

    final previousMonthDays = firstDayOffset > 0
        ? _getDaysInMonth(
            DateTime(_currentMonth.year, _currentMonth.month - 1, 1),
          ).sublist(
            _getDaysInMonth(
                  DateTime(_currentMonth.year, _currentMonth.month - 1, 1),
                ).length -
                firstDayOffset,
          )
        : <DateTime>[];

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

  @override
  Widget build(BuildContext context) {
    final calendarDays = _getCalendarDays();
    const weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    //final monthNames = List.generate(12, (i) => '${i + 1}月');
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.showTimePicker ? '选择日期和时间' : '选择日期',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 月份选择
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    onPressed: () => _changeMonth(-1),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 年份选择按钮
                        InkWell(
                          onTap: () => _showYearPicker(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_currentMonth.year}年',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // 月份选择按钮
                        InkWell(
                          onTap: () => _showMonthPicker(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_currentMonth.month}月',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: () => _changeMonth(1),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 日历
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // 星期标题
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    childAspectRatio: 1.5,
                    children: weekdayNames
                        .map(
                          (day) => Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // 日期网格 - 固定高度
                  SizedBox(
                    height: 220, // 固定高度
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 7,
                      childAspectRatio: 1.5,
                      padding: const EdgeInsets.all(4),
                      children: calendarDays.map((day) {
                        final isCurrentMonth = day.month == _currentMonth.month;
                        final isSelected = isCurrentMonth &&
                            day.day == _selectedDate.day &&
                            day.month == _selectedDate.month &&
                            day.year == _selectedDate.year;
                        final isToday = day.day == DateTime.now().day &&
                            day.month == DateTime.now().month &&
                            day.year == DateTime.now().year;

                        return GestureDetector(
                          onTap:
                              isCurrentMonth ? () => _onDaySelected(day) : null,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isToday
                                      ? theme.colorScheme.primary
                                          .withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday && !isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.5),
                                      width: 1.5,
                                    )
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : isCurrentMonth
                                          ? isToday
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.3),
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 时间选择器和快捷日期按钮放在同一行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 快捷日期按钮组
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuickDateButton(
                      "今",
                      () {
                        final now = DateTime.now();
                        setState(() {
                          _selectedDate = now;
                          _currentMonth = DateTime(now.year, now.month, 1);
                          _selectedTime = TimeOfDay.fromDateTime(now);
                          _selectedSecond = now.second;
                        });
                      },
                      _isToday(_selectedDate),
                      theme,
                    ),
                    const SizedBox(width: 4),
                    _buildQuickDateButton(
                      "昨",
                      () {
                        final yesterday = DateTime.now().subtract(
                          const Duration(days: 1),
                        );
                        setState(() {
                          _selectedDate = yesterday;
                          _currentMonth = DateTime(
                            yesterday.year,
                            yesterday.month,
                            1,
                          );
                        });
                      },
                      _isYesterday(_selectedDate),
                      theme,
                    ),
                    const SizedBox(width: 4),
                    _buildQuickDateButton(
                      "前",
                      () {
                        final dayBeforeYesterday = DateTime.now().subtract(
                          const Duration(days: 2),
                        );
                        setState(() {
                          _selectedDate = dayBeforeYesterday;
                          _currentMonth = DateTime(
                            dayBeforeYesterday.year,
                            dayBeforeYesterday.month,
                            1,
                          );
                        });
                      },
                      _isDayBeforeYesterday(_selectedDate),
                      theme,
                    ),
                  ],
                ),

                // 时间选择按钮
                if (widget.showTimePicker)
                  ElevatedButton.icon(
                    onPressed: () => _selectTime(context),
                    icon: Icon(Icons.access_time,
                        size: 16, color: theme.colorScheme.primary),
                    label: Text(
                      "${_selectedTime.hour.toString().padLeft(2, '0')}:"
                      "${_selectedTime.minute.toString().padLeft(2, '0')}"
                      "${widget.showTimePicker && (_selectedSecond > 0) ? ':${_selectedSecond.toString().padLeft(2, '0')}' : ''}",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.primaryContainer.withOpacity(0.3),
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: theme.colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    "取消",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    final selectedDateTime = widget.showTimePicker
                        ? DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                            _selectedSecond,
                          )
                        : DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                          );
                    Navigator.pop(context, selectedDateTime);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("确定"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(
    String text,
    VoidCallback onPressed,
    bool isActive,
    ThemeData theme,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor:
            isActive ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        backgroundColor:
            isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: isActive ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isActive
                ? Colors.transparent
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  bool _isDayBeforeYesterday(DateTime date) {
    final dayBeforeYesterday = DateTime.now().subtract(const Duration(days: 2));
    return date.year == dayBeforeYesterday.year &&
        date.month == dayBeforeYesterday.month &&
        date.day == dayBeforeYesterday.day;
  }

  /// 显示年份选择器对话框
  void _showYearPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: YearPickerDialog(
            initialYear: _currentMonth.year,
            onYearSelected: (year) {
              setState(() {
                _currentMonth = DateTime(year, _currentMonth.month, 1);
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  /// 显示月份选择器对话框
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: MonthPickerDialog(
            initialMonth: _currentMonth.month,
            onMonthSelected: (month) {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, month, 1);
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

/// 年份选择器对话框
class YearPickerDialog extends StatefulWidget {
  final int initialYear;
  final Function(int) onYearSelected;

  const YearPickerDialog({
    super.key,
    required this.initialYear,
    required this.onYearSelected,
  });

  @override
  State<YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<YearPickerDialog> {
  late FixedExtentScrollController _scrollController;

  // 年份范围从1970开始，持续100年
  static const int startYear = 1970;
  static const int yearCount = 100;

  @override
  void initState() {
    super.initState();
    // 计算初始位置
    final initialIndex = widget.initialYear - startYear;
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex.clamp(0, yearCount - 1),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择年份',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // 年份选择器
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 40,
                  perspective: 0.005,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: yearCount,
                    builder: (context, index) {
                      final year = startYear + index;
                      final isSelected = year == widget.initialYear;

                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Text(
                            '$year年',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 中间的选中指示器
                Center(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '取消',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  final selectedYear =
                      startYear + _scrollController.selectedItem;
                  widget.onYearSelected(selectedYear);
                },
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 月份选择器对话框
class MonthPickerDialog extends StatelessWidget {
  final int initialMonth;
  final Function(int) onMonthSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择月份',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // 月份网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == initialMonth;

              return InkWell(
                onTap: () => onMonthSelected(month),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$month月',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
