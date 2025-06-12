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
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedSecond;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _selectedSecond = _selectedDate.second;
  }

  /// 更新选择的日期
  void _updateSelectedDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        _selectedTime.hour,
        _selectedTime.minute,
        _selectedSecond,
      );
    });
    _notifyDateTimeChanged();
  }

  /// 更新选择的时间
  void _updateSelectedTime(TimeOfDay time, int second) {
    setState(() {
      _selectedTime = time;
      _selectedSecond = second;
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        time.hour,
        time.minute,
        second,
      );
    });
    _notifyDateTimeChanged();
  }

  /// 通知日期时间变更
  void _notifyDateTimeChanged() {
    if (widget.onDateTimeChanged != null) {
      widget.onDateTimeChanged!(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DatePicker(
      initialDate: _selectedDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      displayMode: widget.displayMode,
      showQuickButtons: widget.showQuickButtons,
      onDateChanged: _updateSelectedDate,
      timePickerWidget: TimePickerButton(
        time: _selectedTime,
        second: _selectedSecond,
        showSeconds: widget.showSeconds,
        onTimeChanged: _updateSelectedTime,
      ),
    );
  }
}
