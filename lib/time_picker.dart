import 'package:flutter/material.dart';
import 'src/models/time_model.dart';
import 'src/widgets/time_picker/time_picker.dart';

enum TimePickerMode { keyboard, dial }

class TimeWithSeconds {
  final TimeOfDay time;
  final int second;

  TimeWithSeconds(this.time, this.second);
}

/// 显示带秒数的时间选择器对话框
Future<TimeWithSeconds?> showTimePickerWithSeconds({
  required BuildContext context,
  required TimeOfDay initialTime,
  int initialSecond = 0,
  bool showSeconds = true,
}) async {
  TimeOfDay? selectedTime = initialTime;
  int selectedSecond = initialSecond;

  return showDialog<TimeWithSeconds>(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8,
        backgroundColor: theme.colorScheme.surface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480, maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '选择时间',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: TimePicker(
                      initialTime: initialTime,
                      initialSecond: initialSecond,
                      showSeconds: showSeconds,
                      onTimeChanged: (time, second) {
                        selectedTime = time;
                        selectedSecond = second;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                        final result = TimeWithSeconds(
                          selectedTime!,
                          selectedSecond,
                        );
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

class TimePickerWithSeconds extends StatefulWidget {
  final TimeOfDay initialTime;
  final int initialSecond;
  final Function(TimeOfDay, int) onTimeChanged;

  const TimePickerWithSeconds({
    super.key,
    required this.initialTime,
    required this.initialSecond,
    required this.onTimeChanged,
  });

  @override
  State<TimePickerWithSeconds> createState() => _TimePickerWithSecondsState();
}

class _TimePickerWithSecondsState extends State<TimePickerWithSeconds>
    with SingleTickerProviderStateMixin {
  TimePickerMode _mode = TimePickerMode.dial;
  late TextEditingController _hourController;
  late TextEditingController _minuteController;
  late TextEditingController _secondController;

  // 修复：为每个模式创建单独的控制器
  late FixedExtentScrollController _hourDialController;
  late FixedExtentScrollController _minuteDialController;
  late FixedExtentScrollController _secondDialController;

  late TimeOfDay _selectedTime;
  late int _selectedSecond;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedSecond = widget.initialSecond;

    _hourController = TextEditingController(
      text: _selectedTime.hour.toString().padLeft(2, '0'),
    );
    _minuteController = TextEditingController(
      text: _selectedTime.minute.toString().padLeft(2, '0'),
    );
    _secondController = TextEditingController(
      text: _selectedSecond.toString().padLeft(2, '0'),
    );

    // 初始化表盘模式的控制器
    _hourDialController = FixedExtentScrollController(
      initialItem: _selectedTime.hour,
    );
    _minuteDialController = FixedExtentScrollController(
      initialItem: _selectedTime.minute,
    );
    _secondDialController = FixedExtentScrollController(
      initialItem: _selectedSecond,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _hourDialController.dispose();
    _minuteDialController.dispose();
    _secondDialController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _mode = _mode == TimePickerMode.keyboard
          ? TimePickerMode.dial
          : TimePickerMode.keyboard;

      if (_mode == TimePickerMode.dial) {
        // 切换到表盘模式时，确保控制器位置正确
        _hourDialController.jumpToItem(_selectedTime.hour);
        _minuteDialController.jumpToItem(_selectedTime.minute);
        _secondDialController.jumpToItem(_selectedSecond);
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildModeSwitch() {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        _mode == TimePickerMode.keyboard
            ? Icons.watch_later_rounded
            : Icons.keyboard_rounded,
        color: theme.colorScheme.primary,
        size: 20,
      ),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
        padding: const EdgeInsets.all(8),
      ),
      onPressed: _toggleMode,
      tooltip: _mode == TimePickerMode.keyboard ? '切换到表盘模式' : '切换到键盘输入',
    );
  }

  Widget _buildKeyboardInput() {
    final theme = Theme.of(context);
    final inputDecoration = InputDecoration(
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeField(
            controller: _hourController,
            label: '时',
            color: theme.colorScheme.primary,
            decoration: inputDecoration,
            onChanged: (value) {
              if (value.isNotEmpty) {
                int? hour = int.tryParse(value);
                if (hour != null && hour >= 0 && hour < 24) {
                  setState(() {
                    _selectedTime = _selectedTime.replacing(hour: hour);
                    widget.onTimeChanged(_selectedTime, _selectedSecond);
                  });
                }
              }
            },
          ),
          _buildTimeSeparator(theme),
          _buildTimeField(
            controller: _minuteController,
            label: '分',
            color: theme.colorScheme.secondary,
            decoration: inputDecoration,
            onChanged: (value) {
              if (value.isNotEmpty) {
                int? minute = int.tryParse(value);
                if (minute != null && minute >= 0 && minute < 60) {
                  setState(() {
                    _selectedTime = _selectedTime.replacing(minute: minute);
                    widget.onTimeChanged(_selectedTime, _selectedSecond);
                  });
                }
              }
            },
          ),
          _buildTimeSeparator(theme),
          _buildTimeField(
            controller: _secondController,
            label: '秒',
            color: theme.colorScheme.tertiary,
            decoration: inputDecoration,
            onChanged: (value) {
              if (value.isNotEmpty) {
                int? second = int.tryParse(value);
                if (second != null && second >= 0 && second < 60) {
                  setState(() {
                    _selectedSecond = second;
                    widget.onTimeChanged(_selectedTime, _selectedSecond);
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required Color color,
    required InputDecoration decoration,
    required Function(String) onChanged,
  }) {
    return SizedBox(
      width: 55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: decoration,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDialPicker() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final pickerWidth = (maxWidth - 20) / 3;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPicker(
                      controller: _hourDialController,
                      itemCount: 24,
                      label: '时',
                      color: theme.colorScheme.primary,
                      width: pickerWidth,
                      onSelectedItemChanged: (hour) {
                        setState(() {
                          _selectedTime = _selectedTime.replacing(hour: hour);
                          widget.onTimeChanged(_selectedTime, _selectedSecond);
                          _hourController.text = hour.toString().padLeft(
                                2,
                                '0',
                              );
                        });
                      },
                    ),
                    _buildSeparator(theme),
                    _buildPicker(
                      controller: _minuteDialController,
                      itemCount: 60,
                      label: '分',
                      color: theme.colorScheme.secondary,
                      width: pickerWidth,
                      onSelectedItemChanged: (minute) {
                        setState(() {
                          _selectedTime = _selectedTime.replacing(
                            minute: minute,
                          );
                          widget.onTimeChanged(_selectedTime, _selectedSecond);
                          _minuteController.text = minute.toString().padLeft(
                                2,
                                '0',
                              );
                        });
                      },
                    ),
                    _buildSeparator(theme),
                    _buildPicker(
                      controller: _secondDialController,
                      itemCount: 60,
                      label: '秒',
                      color: theme.colorScheme.tertiary,
                      width: pickerWidth,
                      onSelectedItemChanged: (second) {
                        setState(() {
                          _selectedSecond = second;
                          widget.onTimeChanged(_selectedTime, _selectedSecond);
                          _secondController.text = second.toString().padLeft(
                                2,
                                '0',
                              );
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String label,
    required Color color,
    required double width,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: 100,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(color: color.withOpacity(0.3), width: 1),
      // ),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 30,
        perspective: 0.005,
        diameterRatio: 1.5,
        onSelectedItemChanged: onSelectedItemChanged,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final isSelected = index == controller.selectedItem;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: isSelected ? 16 : 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? color
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildModeSwitch()],
        ),
        const SizedBox(height: 8),
        _mode == TimePickerMode.keyboard
            ? _buildKeyboardInput()
            : _buildDialPicker(),
      ],
    );
  }
}
