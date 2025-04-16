import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';
import '../../models/date_model.dart';
import 'date_picker_calendar.dart';
import 'date_picker_header.dart';

/// 日期选择器组件
class DatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showHeader;
  /// 显示模式配置，控制年月日选择的显示方式
  final DatePickerDisplayMode displayMode;
  
  const DatePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
    this.showHeader = true,
    this.displayMode = DatePickerDisplayMode.full,
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
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

/// 显示日期选择器对话框
Future<DateTime?> showDatePicker2({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = '选择日期',
  DatePickerDisplayMode displayMode = DatePickerDisplayMode.full,
}) async {
  DateTime? selectedDate = initialDate ?? DateTime.now();

  final result = await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8,
        backgroundColor: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DatePicker(
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
                displayMode: displayMode,
                onDateChanged: (date) {
                  selectedDate = date;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context, selectedDate);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
} 