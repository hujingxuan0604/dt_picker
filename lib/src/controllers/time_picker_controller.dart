import 'package:flutter/material.dart';
import '../models/time_model.dart';

/// 时间选择器控制器
class TimePickerController extends ChangeNotifier {
  TimeOfDay _time = TimeOfDay.now();
  int _second = 0;
  TimePickerMode _mode = TimePickerMode.dial;
  TimePickerMode _dialMode = TimePickerMode.hour;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  final FixedExtentScrollController _hourDialController = FixedExtentScrollController();
  final FixedExtentScrollController _minuteDialController = FixedExtentScrollController();
  final FixedExtentScrollController _secondDialController = FixedExtentScrollController();
  bool showSeconds = true;

  TimeOfDay get time => _time;
  int get second => _second;
  TimePickerMode get mode => _mode;
  TimePickerMode get dialMode => _dialMode;
  TextEditingController get hourController => _hourController;
  TextEditingController get minuteController => _minuteController;
  TextEditingController get secondController => _secondController;
  FixedExtentScrollController get hourDialController => _hourDialController;
  FixedExtentScrollController get minuteDialController => _minuteDialController;
  FixedExtentScrollController get secondDialController => _secondDialController;

  /// 初始化控制器
  void initialize(TimeOfDay initialTime, int initialSecond) {
    _time = initialTime;
    _second = initialSecond;
    _updateControllers();
  }

  /// 更新控制器值
  void _updateControllers() {
    _hourController.text = _time.hour.toString().padLeft(2, '0');
    _minuteController.text = _time.minute.toString().padLeft(2, '0');
    _secondController.text = _second.toString().padLeft(2, '0');
    _hourDialController.jumpToItem(_time.hour);
    _minuteDialController.jumpToItem(_time.minute);
    _secondDialController.jumpToItem(_second);
  }

  /// 切换选择模式（键盘/表盘）
  void toggleMode() {
    _mode = _mode == TimePickerMode.keyboard ? TimePickerMode.dial : TimePickerMode.keyboard;
    if (_mode == TimePickerMode.dial) {
      _dialMode = TimePickerMode.hour;
    }
    notifyListeners();
  }

  /// 切换表盘模式（时/分/秒）
  void setDialMode(TimePickerMode mode) {
    if (_mode == TimePickerMode.dial) {
      _dialMode = mode;
      notifyListeners();
    }
  }

  /// 更新时间
  void updateTime(TimeOfDay newTime) {
    _time = newTime;
    _updateControllers();
    notifyListeners();
  }

  /// 更新秒数
  void updateSecond(int newSecond) {
    _second = newSecond;
    _updateControllers();
    notifyListeners();
  }

  /// 从键盘输入更新时间
  void updateFromKeyboard() {
    try {
      final hour = int.parse(_hourController.text);
      final minute = int.parse(_minuteController.text);
      final second = int.parse(_secondController.text);
      
      if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60 && second >= 0 && second < 60) {
        _time = TimeOfDay(hour: hour, minute: minute);
        _second = second;
        notifyListeners();
      }
    } catch (e) {
      // 输入无效时保持原值
      _updateControllers();
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _hourDialController.dispose();
    _minuteDialController.dispose();
    _secondDialController.dispose();
    super.dispose();
  }
} 