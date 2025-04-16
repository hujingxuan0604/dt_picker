import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';
import '../../models/date_model.dart';
import '../../models/time_model.dart';
import '../time_picker/time_picker.dart';
import 'date_picker.dart';

/// 日期时间组合选择器
class DateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTimeResult) onDateTimeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showSeconds;
  /// 日期选择器显示模式配置
  final DatePickerDisplayMode dateDisplayMode;
  
  const DateTimePicker({
    super.key,
    this.initialDateTime,
    required this.onDateTimeChanged,
    this.firstDate,
    this.lastDate,
    this.showSeconds = true,
    this.dateDisplayMode = DatePickerDisplayMode.full,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedSecond;
  
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDateTime ?? now;
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _selectedSecond = _selectedDate.second;
  }
  
  void _updateDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _notifyDateTimeChanged();
    });
  }
  
  void _updateTime(TimeOfDay time, int second) {
    setState(() {
      _selectedTime = time;
      _selectedSecond = second;
      _notifyDateTimeChanged();
    });
  }
  
  void _notifyDateTimeChanged() {
    widget.onDateTimeChanged(DateTimeResult(
      date: _selectedDate,
      time: _selectedTime,
      second: widget.showSeconds ? _selectedSecond : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 日期选择器
        DatePicker(
          initialDate: _selectedDate,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onDateChanged: _updateDate,
          displayMode: widget.dateDisplayMode,
        ),
        
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        
        // 时间选择器
        TimePicker(
          initialTime: _selectedTime,
          initialSecond: _selectedSecond,
          onTimeChanged: _updateTime,
        ),
      ],
    );
  }
}

/// 显示日期时间选择器对话框
Future<DateTimeResult?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  bool showSeconds = true,
  String title = '选择日期和时间',
  DatePickerDisplayMode dateDisplayMode = DatePickerDisplayMode.full,
}) async {
  DateTimeResult? result;

  return showDialog<DateTimeResult>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8,
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
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
                        Icons.event,
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
                DateTimePicker(
                  initialDateTime: initialDateTime,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  showSeconds: showSeconds,
                  dateDisplayMode: dateDisplayMode,
                  onDateTimeChanged: (dateTimeResult) {
                    result = dateTimeResult;
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
                        Navigator.pop(context, result);
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
        ),
      );
    },
  );
} 