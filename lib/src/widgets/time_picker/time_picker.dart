import 'package:flutter/material.dart';
import '../../controllers/time_picker_controller.dart';
import '../../models/time_model.dart' as model;
import 'time_picker_dial.dart';
import 'time_picker_keyboard.dart';
import 'time_picker_switch.dart';

/// 时间选择器组件
class TimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final int initialSecond;
  final Function(TimeOfDay, int) onTimeChanged;
  final bool showSeconds;

  const TimePicker({
    super.key,
    required this.initialTime,
    required this.initialSecond,
    required this.onTimeChanged,
    this.showSeconds = true,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  late final TimePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimePickerController();
    _controller.initialize(widget.initialTime, widget.initialSecond);
    _controller.showSeconds = widget.showSeconds;
    _controller.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTimeChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    widget.onTimeChanged(_controller.time, _controller.second);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TimePickerSwitch(controller: _controller),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _controller.mode == model.TimePickerMode.dial
                    ? TimePickerDial(controller: _controller)
                    : TimePickerKeyboard(controller: _controller),
              ),
            ],
          ),
        );
      },
    );
  }
}
