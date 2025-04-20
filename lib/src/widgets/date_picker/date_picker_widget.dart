import 'package:flutter/material.dart';
import '../../../src/controllers/date_picker_controller.dart';
import 'date_picker_calendar.dart';
import 'date_picker_header.dart';

/// 日期选择器组件
class DatePickerWidget extends StatefulWidget {
  /// 初始选择的日期
  final DateTime? initialDate;
  
  /// 日期变化时的回调函数
  final Function(DateTime) onDateChanged;
  
  /// 可选择的最早日期
  final DateTime? firstDate;
  
  /// 可选择的最晚日期
  final DateTime? lastDate;
  
  /// 是否显示标题栏
  final bool showHeader;
  
  /// 显示模式配置，控制年月日选择的显示方式
  final DatePickerDisplayMode displayMode;
  
  /// 是否显示快捷日期按钮（今天、昨天、前天）
  final bool showQuickButtons;
  
  const DatePickerWidget({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.showHeader = true,
    this.displayMode = DatePickerDisplayMode.full,
    this.showQuickButtons = false,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late final DatePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DatePickerController(
      initialDate: widget.initialDate,
      displayMode: widget.displayMode,
    );
    _controller.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDateChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    widget.onDateChanged(_controller.selectedDate);
    setState(() {}); // 确保视图模式变化时重建UI
  }

  /// 判断日期是否为今天
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 判断日期是否为昨天
  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// 判断日期是否为前天
  bool _isDayBeforeYesterday(DateTime date) {
    final dayBeforeYesterday = DateTime.now().subtract(const Duration(days: 2));
    return date.year == dayBeforeYesterday.year &&
        date.month == dayBeforeYesterday.month &&
        date.day == dayBeforeYesterday.day;
  }

  /// 构建快捷日期按钮
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0, // 移除阴影效果，避免动画
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isActive
                ? Colors.transparent
                : theme.colorScheme.outline,
          ),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  /// 构建快捷按钮组
  Widget _buildQuickButtons() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 8, // 水平间距
      runSpacing: 4, // 垂直间距
      children: [
        _buildQuickDateButton(
          "今",
          () {
            final now = DateTime.now();
            if (_controller.viewMode == DatePickerViewMode.day) {
              _controller.updateSelectedDate(now);
              _controller.updateMonth(now.year, now.month);
            }
          },
          _isToday(_controller.selectedDate),
          theme,
        ),
        _buildQuickDateButton(
          "昨",
          () {
            final yesterday = DateTime.now().subtract(
              const Duration(days: 1),
            );
            if (_controller.viewMode == DatePickerViewMode.day) {
              _controller.updateSelectedDate(yesterday);
              _controller.updateMonth(yesterday.year, yesterday.month);
            }
          },
          _isYesterday(_controller.selectedDate),
          theme,
        ),
        _buildQuickDateButton(
          "前",
          () {
            final dayBeforeYesterday = DateTime.now().subtract(
              const Duration(days: 2),
            );
            if (_controller.viewMode == DatePickerViewMode.day) {
              _controller.updateSelectedDate(dayBeforeYesterday);
              _controller.updateMonth(dayBeforeYesterday.year, dayBeforeYesterday.month);
            }
          },
          _isDayBeforeYesterday(_controller.selectedDate),
          theme,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader) ...[
          DatePickerHeader(controller: _controller),
          const SizedBox(height: 16),
        ],
        DatePickerCalendar(controller: _controller),
        
        // 快捷日期按钮 - 仅在显示日期模式且启用快捷按钮时显示
        if (widget.showQuickButtons && widget.displayMode.showDay && _controller.viewMode == DatePickerViewMode.day) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickButtons(),
              // 这里可以添加其他按钮或功能，例如"清除选择"等
            ],
          ),
        ],
        
        // 添加返回按钮，当处于月份或年份视图且可以回到日期视图时显示
        if (_controller.viewMode != DatePickerViewMode.day && _controller.showDay) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _controller.switchToDayMode();
              },
              child: const Text('返回日期选择'),
            ),
          ),
        ],
        
        // 添加返回按钮，当处于年份视图且可以回到月份视图但不能回到日期视图时显示
        if (_controller.viewMode == DatePickerViewMode.year && 
            _controller.showMonth && 
            !_controller.showDay) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _controller.switchToMonthMode();
              },
              child: const Text('返回月份选择'),
            ),
          ),
        ],
      ],
    );
  }
} 