import 'package:dt_picker/src/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../controllers/time_picker_controller.dart';
import 'dart:async';

/// 时间选择器表盘模式
class TimePickerDial extends StatefulWidget {
  final TimePickerController controller;

  const TimePickerDial({
    super.key,
    required this.controller,
  });

  @override
  State<TimePickerDial> createState() => _TimePickerDialState();
}

class _TimePickerDialState extends State<TimePickerDial> {
  // 优化：用 ValueNotifier 代替 State 变量
  final ValueNotifier<TimePickerMode> _currentMode = ValueNotifier(TimePickerMode.hour);

  // 用于指针拖动
  bool _isDragging = false;
  Timer? _debounceTimer; // 拖动防抖定时器
  Offset? _lastDragPosition;

  @override
  void initState() {
    super.initState();
    // 如果不显示秒，则强制使用小时模式
    if (!widget.controller.showSeconds &&
        _currentMode.value == TimePickerMode.second) {
      _currentMode.value = TimePickerMode.hour;
    }
  }

  @override
  void dispose() {
    _currentMode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _setCurrentMode(TimePickerMode mode) {
    // 如果不显示秒且尝试设置为秒模式，则默认设置为小时模式
    if (!widget.controller.showSeconds && mode == TimePickerMode.second) {
      _currentMode.value = TimePickerMode.hour;
    } else {
      _currentMode.value = mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 使用 ResponsiveUtils 获取响应式尺寸
    final dialSize = ResponsiveUtils.getDialSize(context);
    final outerRadius = (dialSize / 2.0) * 0.85;
    final innerRadius = outerRadius * 0.6;

    final dialBackgroundColor = isDarkMode
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.12)
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.2);

    return Container(
      padding: ResponsiveUtils.getDialPadding(context),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        // 移除边框和背景色
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时间显示和模式切换
          ValueListenableBuilder<TimePickerMode>(
            valueListenable: _currentMode,
            builder: (context, mode, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTimeSegment(
                    context: context,
                    value: widget.controller.time.hour.toString().padLeft(2, '0'),
                    isSelected: mode == TimePickerMode.hour,
                    onTap: () => _setCurrentMode(TimePickerMode.hour),
                  ),
                  Text(
                    ':',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  _buildTimeSegment(
                    context: context,
                    value: widget.controller.time.minute.toString().padLeft(2, '0'),
                    isSelected: mode == TimePickerMode.minute,
                    onTap: () => _setCurrentMode(TimePickerMode.minute),
                  ),
                  if (widget.controller.showSeconds) ...[
                    Text(
                      ':',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    _buildTimeSegment(
                      context: context,
                      value: widget.controller.second.toString().padLeft(2, '0'),
                      isSelected: mode == TimePickerMode.second,
                      onTap: () => _setCurrentMode(TimePickerMode.second),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // 表盘
          ValueListenableBuilder<TimePickerMode>(
            valueListenable: _currentMode,
            builder: (context, mode, _) {
              return GestureDetector(
                onPanStart: (details) {
                  _handleDrag(details.localPosition, dialSize, outerRadius, innerRadius, mode);
                  _isDragging = true;
                },
                onPanUpdate: (details) {
                  if (_isDragging) {
                    _handleDrag(details.localPosition, dialSize, outerRadius, innerRadius, mode);
                  }
                },
                onPanEnd: (_) {
                  _isDragging = false;
                  // 拖动结束时再处理一次，确保最终位置准确
                  if (_lastDragPosition != null) {
                    _updatePointerPosition(_lastDragPosition!, dialSize, outerRadius, innerRadius, mode);
                  }
                  _debounceTimer?.cancel();
                },
                child: SizedBox(
                  width: dialSize,
                  height: dialSize,
                  child: Stack(
                    children: [
                      // 表盘背景
                      Center(
                        child: Container(
                          width: dialSize,
                          height: dialSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dialBackgroundColor,
                          ),
                        ),
                      ),
                      // 根据当前模式显示不同的选择器
                      if (mode == TimePickerMode.hour) ...[
                        // 外圆环（1-12小时）
                        ...List.generate(12, (index) {
                          final hour = index + 1;
                          // 修改角度计算，使数字顺时针排列
                          final angle = (hour * 30 - 90) * (math.pi / 180);
                          final x = outerRadius * math.cos(angle);
                          final y = outerRadius * math.sin(angle);

                          return Positioned(
                            left: dialSize / 2 + x - 10,
                            top: dialSize / 2 + y - 10,
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.updateTime(TimeOfDay(
                                  hour: hour,
                                  minute: widget.controller.time.minute,
                                ));
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.controller.time.hour == hour
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  hour.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.controller.time.hour == hour
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: widget.controller.time.hour == hour
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // 内圆环（13-24小时）
                        ...List.generate(12, (index) {
                          final hour = index + 13;
                          // 修改角度计算，使数字顺时针排列并与外环对应
                          final angle = ((index + 1) * 30 - 90) * (math.pi / 180);
                          final x = innerRadius * math.cos(angle);
                          final y = innerRadius * math.sin(angle);

                          return Positioned(
                            left: dialSize / 2 + x - 10,
                            top: dialSize / 2 + y - 10,
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.updateTime(TimeOfDay(
                                  hour: hour == 24 ? 0 : hour,
                                  minute: widget.controller.time.minute,
                                ));
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hour == widget.controller.time.hour ||
                                          (hour == 24 &&
                                              widget.controller.time.hour == 0)
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  hour == 24 ? '0' : hour.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: hour == widget.controller.time.hour ||
                                            (hour == 24 &&
                                                widget.controller.time.hour == 0)
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: hour ==
                                                widget.controller.time.hour ||
                                            (hour == 24 &&
                                                widget.controller.time.hour == 0)
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // 绘制小时指针
                        _buildHourHand(dialSize, theme, outerRadius, innerRadius),
                      ] else if (mode == TimePickerMode.minute) ...[
                        // 分钟选择（0-55，每5分钟一个刻度）
                        ...List.generate(12, (index) {
                          final minute = index * 5;
                          // 修改角度计算，使数字顺时针排列
                          final angle = (minute * 6 - 90) * (math.pi / 180);
                          final x = outerRadius * math.cos(angle);
                          final y = outerRadius * math.sin(angle);

                          return Positioned(
                            left: dialSize / 2 + x - 10,
                            top: dialSize / 2 + y - 10,
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.updateTime(TimeOfDay(
                                  hour: widget.controller.time.hour,
                                  minute: minute,
                                ));
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: minute == widget.controller.time.minute
                                      ? theme.colorScheme.secondary
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  minute.toString().padLeft(2, '0'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: minute == widget.controller.time.minute
                                        ? theme.colorScheme.onSecondary
                                        : theme.colorScheme.onSurface,
                                    fontWeight:
                                        minute == widget.controller.time.minute
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // 绘制分钟指针
                        _buildMinuteHand(dialSize, theme, outerRadius),
                      ] else if (widget.controller.showSeconds) ...[
                        // 秒数选择（0-55，每5秒一个刻度）
                        ...List.generate(12, (index) {
                          final second = index * 5;
                          // 修改角度计算，使数字顺时针排列
                          final angle = (second * 6 - 90) * (math.pi / 180);
                          final x = outerRadius * math.cos(angle);
                          final y = outerRadius * math.sin(angle);

                          return Positioned(
                            left: dialSize / 2 + x - 10,
                            top: dialSize / 2 + y - 10,
                            child: GestureDetector(
                              onTap: () {
                                widget.controller.updateSecond(second);
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: second == widget.controller.second
                                      ? theme.colorScheme.error
                                      : Colors.transparent,
                                ),
                                child: Text(
                                  second.toString().padLeft(2, '0'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: second == widget.controller.second
                                        ? theme.colorScheme.onError
                                        : theme.colorScheme.onSurface,
                                    fontWeight: second == widget.controller.second
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // 绘制秒针
                        _buildSecondHand(dialSize, theme, outerRadius),
                      ],
                      // 中心点
                      Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 拖动防抖处理
  void _handleDrag(Offset position, double dialSize, double outerRadius, double innerRadius, TimePickerMode mode) {
    _lastDragPosition = position;
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      if (_lastDragPosition != null) {
        _updatePointerPosition(_lastDragPosition!, dialSize, outerRadius, innerRadius, mode);
      }
    });
  }

  // 更新指针位置并选择对应的时间值
  void _updatePointerPosition(Offset position, double dialSize,
      double outerRadius, double innerRadius, TimePickerMode mode) {
    final center = Offset(dialSize / 2, dialSize / 2);
    final relativePos = position - center;

    // 计算角度（0-360度）
    final angle =
        (math.atan2(relativePos.dy, relativePos.dx) * 180 / math.pi + 90) % 360;

    // 根据当前模式和角度更新时间
    if (mode == TimePickerMode.hour) {
      // 检查是外环还是内环（基于距离）
      final distance = relativePos.distance;
      final thresholdRadius = (outerRadius + innerRadius) / 2;

      if (distance < thresholdRadius) {
        // 内环 (13-24)
        final hourIndex = ((angle / 30).round()) % 12;
        final hour = hourIndex == 0 ? 24 : hourIndex + 12;
        widget.controller.updateTime(TimeOfDay(
          hour: hour == 24 ? 0 : hour,
          minute: widget.controller.time.minute,
        ));
      } else {
        // 外环 (1-12)
        final hour = ((angle / 30).round()) % 12;
        widget.controller.updateTime(TimeOfDay(
          hour: hour == 0 ? 12 : hour,
          minute: widget.controller.time.minute,
        ));
      }
    } else if (mode == TimePickerMode.minute) {
      final minute = ((angle / 6).round()) % 60;
      widget.controller.updateTime(TimeOfDay(
        hour: widget.controller.time.hour,
        minute: minute,
      ));
    } else if (widget.controller.showSeconds &&
        mode == TimePickerMode.second) {
      final second = ((angle / 6).round()) % 60;
      widget.controller.updateSecond(second);
    }
  }

  // 构建小时指针
  Widget _buildHourHand(double dialSize, ThemeData theme, double outerRadius,
      double innerRadius) {
    final hour = widget.controller.time.hour;
    final isInnerHour = (hour > 12 && hour <= 23) || hour == 0;
    final handLength = isInnerHour ? innerRadius - 15 : outerRadius - 15;

    // 使用CustomPaint直接绘制指向特定小时位置的指针
    return CustomPaint(
      size: Size(dialSize, dialSize),
      painter: ClockHandPainter(
        valueCount: 12,
        value: hour % 12,
        length: handLength,
        color: theme.colorScheme.primary,
        strokeWidth: 3,
      ),
    );
  }

  // 构建分钟指针
  Widget _buildMinuteHand(double dialSize, ThemeData theme, double radius) {
    final minute = widget.controller.time.minute;

    return CustomPaint(
      size: Size(dialSize, dialSize),
      painter: ClockHandPainter(
        valueCount: 60,
        value: minute,
        length: radius - 15,
        color: theme.colorScheme.secondary,
        strokeWidth: 2,
      ),
    );
  }

  // 构建秒针
  Widget _buildSecondHand(double dialSize, ThemeData theme, double radius) {
    final second = widget.controller.second;

    return CustomPaint(
      size: Size(dialSize, dialSize),
      painter: ClockHandPainter(
        valueCount: 60,
        value: second,
        length: radius - 15,
        color: theme.colorScheme.error,
        strokeWidth: 1.5,
      ),
    );
  }

  Widget _buildTimeSegment({
    required BuildContext context,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? isDarkMode
            ? theme.colorScheme.primary.withOpacity(0.2)
            : theme.colorScheme.primaryContainer
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 用于绘制指针的自定义画笔
class HandPainter extends CustomPainter {
  final double angle;
  final double length;
  final Color color;
  final double strokeWidth;
  final Offset center;

  HandPainter({
    required this.angle,
    required this.length,
    required this.color,
    required this.strokeWidth,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = center.dx + length * math.cos(angle);
    final y = center.dy + length * math.sin(angle);
    canvas.drawLine(center, Offset(x, y), paint);
  }

  @override
  bool shouldRepaint(covariant HandPainter oldDelegate) {
    // 只在 angle、length、color、strokeWidth、center 变化时重绘
    return oldDelegate.angle != angle ||
        oldDelegate.length != length ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.center != center;
  }
}

// 专门用于时钟指针的画笔
class ClockHandPainter extends CustomPainter {
  final int valueCount; // 总刻度数量（小时12，分钟/秒60）
  final int value; // 当前值 (小时0-11, 分钟/秒0-59)
  final double length;
  final Color color;
  final double strokeWidth;

  ClockHandPainter({
    required this.valueCount,
    required this.value,
    required this.length,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    double angle;
    if (value == 0) {
      angle = -math.pi / 2;
    } else {
      final unitAngle = 2 * math.pi / valueCount;
      angle = value * unitAngle - math.pi / 2;
    }
    final x = center.dx + length * math.cos(angle);
    final y = center.dy + length * math.sin(angle);
    canvas.drawLine(center, Offset(x, y), paint);
  }

  @override
  bool shouldRepaint(covariant ClockHandPainter oldDelegate) {
    // 只在 value、valueCount、length、color、strokeWidth 变化时重绘
    return oldDelegate.value != value ||
        oldDelegate.valueCount != valueCount ||
        oldDelegate.length != length ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

enum TimePickerMode {
  hour,
  minute,
  second,
}
