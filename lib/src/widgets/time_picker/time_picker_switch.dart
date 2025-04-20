import 'package:flutter/material.dart';
import '../../controllers/time_picker_controller.dart';
import '../../models/time_model.dart';

/// 时间选择器模式切换按钮
class TimePickerSwitch extends StatelessWidget {
  final TimePickerController controller;

  const TimePickerSwitch({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        controller.mode == TimePickerMode.keyboard
            ? Icons.watch_later_rounded
            : Icons.keyboard_rounded,
        color: Colors.blue,
        size: 20,
      ),
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFE3F2FD),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: controller.toggleMode,
      tooltip: controller.mode == TimePickerMode.keyboard
          ? '切换到表盘模式'
          : '切换到键盘输入',
    );
  }
} 