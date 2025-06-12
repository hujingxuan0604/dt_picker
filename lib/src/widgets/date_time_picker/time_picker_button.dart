import 'dart:math' as math;

import 'package:dt_picker/src/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import '../../widgets/time_picker/time_picker.dart';

/// 时间选择按钮组件
class TimePickerButton extends StatefulWidget {
  /// 当前选择的时间
  final TimeOfDay time;
  
  /// 当前选择的秒数
  final int second;
  
  /// 是否显示秒数
  final bool showSeconds;
  
  /// 时间变更回调
  final Function(TimeOfDay, int) onTimeChanged;

  const TimePickerButton({
    super.key,
    required this.time,
    required this.second,
    required this.onTimeChanged,
    this.showSeconds = true,
  });

  @override
  State<TimePickerButton> createState() => _TimePickerButtonState();
}

class _TimePickerButtonState extends State<TimePickerButton> {
  // 显示时间选择对话框
  Future<void> _showTimePickerDialog() async {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    final dialogWidth = ResponsiveUtils.isMobile(context)
        ? size.width * 0.9
        : ResponsiveUtils.isTablet(context)
            ? math.min(size.width * 0.7, 480.0)
            : math.min(size.width * 0.5, 560.0);
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay tempTime = widget.time;
        int tempSecond = widget.second;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          child: Container(
            width: dialogWidth,
            padding: ResponsiveUtils.getDialPadding(context),
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
                TimePicker(
                  initialTime: widget.time,
                  initialSecond: widget.second,
                  showSeconds: widget.showSeconds,
                  onTimeChanged: (time, second) {
                    tempTime = time;
                    tempSecond = second;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'time': tempTime,
                          'second': tempSecond,
                        });
                      },
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

    if (result != null) {
      widget.onTimeChanged(result['time'], result['second']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.primaryContainer;
        
    return ElevatedButton.icon(
      onPressed: _showTimePickerDialog,
      icon: Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
      label: Text(
        "${widget.time.hour.toString().padLeft(2, '0')}:"
        "${widget.time.minute.toString().padLeft(2, '0')}"
        "${widget.showSeconds && (widget.second > 0) ? ':${widget.second.toString().padLeft(2, '0')}' : ''}",
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.primary,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}