import 'package:flutter/material.dart';
import '../date_picker/date_picker.dart';
import 'time_picker_button.dart';
import '../../controllers/date_picker_controller.dart';

/// 日期时间选择器控件
class DateTimePicker extends StatefulWidget {
  /// 初始选择日期
  final DateTime? initialDate;

  /// 可选择的第一个日期
  final DateTime? firstDate;

  /// 可选择的最后一个日期
  final DateTime? lastDate;

  /// 显示模式，日期、月份或年份
  final DatePickerDisplayMode displayMode;

  /// 是否显示秒
  final bool showSeconds;

  /// 是否显示快速按钮（今天、昨天、前天）
  final bool showQuickButtons;

  /// 日期时间变更回调
  final Function(DateTime)? onDateTimeChanged;

  const DateTimePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.showSeconds = false,
    this.showQuickButtons = true,
    this.displayMode = DatePickerDisplayMode.full,
    this.onDateTimeChanged,
  });

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late final ValueNotifier<DateTime> _selectedDate;
  late final ValueNotifier<TimeOfDay> _selectedTime;
  late final ValueNotifier<int> _selectedSecond;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate ?? DateTime.now();
    _selectedDate = ValueNotifier(initial);
    _selectedTime = ValueNotifier(TimeOfDay.fromDateTime(initial));
    _selectedSecond = ValueNotifier(initial.second);
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _selectedTime.dispose();
    _selectedSecond.dispose();
    super.dispose();
  }

  /// 更新选择的日期
  void _updateSelectedDate(DateTime date) {
    _selectedDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      _selectedTime.value.hour,
      _selectedTime.value.minute,
      _selectedSecond.value,
    );
    _notifyDateTimeChanged();
  }

  /// 更新选择的时间
  void _updateSelectedTime(TimeOfDay time, int second) {
    _selectedTime.value = time;
    _selectedSecond.value = second;
    _selectedDate.value = DateTime(
      _selectedDate.value.year,
      _selectedDate.value.month,
      _selectedDate.value.day,
      time.hour,
      time.minute,
      second,
    );
    _notifyDateTimeChanged();
  }

  /// 通知日期时间变更
  void _notifyDateTimeChanged() {
    if (widget.onDateTimeChanged != null) {
      widget.onDateTimeChanged!(_selectedDate.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: _selectedDate,
      builder: (context, date, _) {
        return ValueListenableBuilder<TimeOfDay>(
          valueListenable: _selectedTime,
          builder: (context, time, __) {
            return ValueListenableBuilder<int>(
              valueListenable: _selectedSecond,
              builder: (context, second, ___) {
                return DatePicker(
                  initialDate: date,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  displayMode: widget.displayMode,
                  showQuickButtons: widget.showQuickButtons,
                  onDateChanged: _updateSelectedDate,
                  timePickerWidget: TimePickerButton(
                    time: time,
                    second: second,
                    showSeconds: widget.showSeconds,
                    onTimeChanged: _updateSelectedTime,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
