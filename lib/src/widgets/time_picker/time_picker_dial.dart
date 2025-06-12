import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../controllers/time_picker_controller.dart';

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
  TimePickerMode _currentMode = TimePickerMode.hour;
  // 用于指针拖动
  Offset _pointerPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // 如果不显示秒，则强制使用小时模式
    if (!widget.controller.showSeconds && _currentMode == TimePickerMode.second) {
      _currentMode = TimePickerMode.hour;
    }
  }

  void _setCurrentMode(TimePickerMode mode) {
    // 如果不显示秒且尝试设置为秒模式，则默认设置为小时模式
    if (!widget.controller.showSeconds && mode == TimePickerMode.second) {
      setState(() => _currentMode = TimePickerMode.hour);
    } else {
      setState(() => _currentMode = mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    // 调整表盘大小，使用屏幕宽度的0.4倍，但不超过250
    final dialSize = math.min(size.width * 0.5, 250.0);
    // 增加外圆半径，让外侧数字有更多空间显示
    final outerRadius = (dialSize / 2.0) * 0.85;
    final innerRadius = outerRadius * 0.6;
    
    // 设置表盘颜色
    final dialBackgroundColor = isDarkMode
        ? theme.colorScheme.surfaceVariant.withOpacity(0.12)
        : theme.colorScheme.surfaceVariant.withOpacity(0.2);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        // 移除边框和背景色
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时间显示和模式切换
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeSegment(
                context: context,
                value: widget.controller.time.hour.toString().padLeft(2, '0'),
                isSelected: _currentMode == TimePickerMode.hour,
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
                isSelected: _currentMode == TimePickerMode.minute,
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
                  isSelected: _currentMode == TimePickerMode.second,
                  onTap: () => _setCurrentMode(TimePickerMode.second),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // 表盘
          GestureDetector(
            onPanStart: (details) {
              _updatePointerPosition(details.localPosition, dialSize, outerRadius, innerRadius);
              _isDragging = true;
            },
            onPanUpdate: (details) {
              if (_isDragging) {
                _updatePointerPosition(details.localPosition, dialSize, outerRadius, innerRadius);
              }
            },
            onPanEnd: (_) {
              _isDragging = false;
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
                  if (_currentMode == TimePickerMode.hour) ...[
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
                              color: hour == widget.controller.time.hour || (hour == 24 && widget.controller.time.hour == 0)
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                            child: Text(
                              hour == 24 ? '0' : hour.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: hour == widget.controller.time.hour || (hour == 24 && widget.controller.time.hour == 0)
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: hour == widget.controller.time.hour || (hour == 24 && widget.controller.time.hour == 0)
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
                  ] else if (_currentMode == TimePickerMode.minute) ...[
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
                                fontWeight: minute == widget.controller.time.minute
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
          ),
        ],
      ),
    );
  }

  // 更新指针位置并选择对应的时间值
  void _updatePointerPosition(Offset position, double dialSize, double outerRadius, double innerRadius) {
    final center = Offset(dialSize / 2, dialSize / 2);
    final relativePos = position - center;
    
    setState(() {
      _pointerPosition = relativePos;
    });
    
    // 计算角度（0-360度）
    final angle = (math.atan2(relativePos.dy, relativePos.dx) * 180 / math.pi + 90) % 360;
    
    // 根据当前模式和角度更新时间
    if (_currentMode == TimePickerMode.hour) {
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
    } else if (_currentMode == TimePickerMode.minute) {
      final minute = ((angle / 6).round()) % 60;
      widget.controller.updateTime(TimeOfDay(
        hour: widget.controller.time.hour,
        minute: minute,
      ));
    } else if (widget.controller.showSeconds && _currentMode == TimePickerMode.second) {
      final second = ((angle / 6).round()) % 60;
      widget.controller.updateSecond(second);
    }
  }

  // 构建小时指针
  Widget _buildHourHand(double dialSize, ThemeData theme, double outerRadius, double innerRadius) {
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
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
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

    // 直接使用提供的角度，不需要额外的转换
    // angle已经是从12点钟方向开始的弧度值
    final x = center.dx + length * math.cos(angle);
    final y = center.dy + length * math.sin(angle);
    
    canvas.drawLine(center, Offset(x, y), paint);
  }

  @override
  bool shouldRepaint(covariant HandPainter oldDelegate) {
    return oldDelegate.angle != angle || 
           oldDelegate.length != length || 
           oldDelegate.color != color;
  }
}

// 专门用于时钟指针的画笔
class ClockHandPainter extends CustomPainter {
  final int valueCount; // 总刻度数量（小时12，分钟/秒60）
  final int value;      // 当前值 (小时0-11, 分钟/秒0-59)
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
    
    // 计算指针角度（弧度）
    // 12点钟方向为0值，顺时针旋转
    // 例如，对于小时，0表示12点方向，3表示3点方向，等等
    double angle;
    if (value == 0) {
      // 指向12点方向
      angle = -math.pi / 2;
    } else {
      // 根据值计算角度 
      // 例如，小时：每小时30度(2π/12)；分钟和秒：每单位6度(2π/60)
      final unitAngle = 2 * math.pi / valueCount;
      angle = value * unitAngle - math.pi / 2;
    }
    
    // 计算指针端点位置
    final x = center.dx + length * math.cos(angle);
    final y = center.dy + length * math.sin(angle);
    
    // 绘制指针
    canvas.drawLine(center, Offset(x, y), paint);
  }

  @override
  bool shouldRepaint(covariant ClockHandPainter oldDelegate) {
    return oldDelegate.value != value || 
           oldDelegate.valueCount != valueCount ||
           oldDelegate.length != length || 
           oldDelegate.color != color;
  }
}

enum TimePickerMode {
  hour,
  minute,
  second,
} 