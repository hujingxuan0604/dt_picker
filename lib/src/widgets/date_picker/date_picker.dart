import 'package:dt_picker/src/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';
import 'date_picker_calendar.dart';
import '../../utils/date_utils.dart';

/// 日期选择器组件
class DatePicker extends StatefulWidget {
  /// 初始选中的日期
  final DateTime? initialDate;

  /// 最早可选择的日期
  final DateTime? firstDate;

  /// 最晚可选择的日期
  final DateTime? lastDate;

  /// 日期格式（默认：yyyy-MM-dd）
  final String? dateFormat;

  /// 日期选择器显示模式
  final DatePickerDisplayMode displayMode;

  /// 日期变更回调
  final ValueChanged<DateTime>? onDateChanged;

  /// 是否显示快捷日期按钮
  final bool showQuickButtons;

  /// 时间选择器组件（可选）
  final Widget? timePickerWidget;

  /// 构造函数
  const DatePicker({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.displayMode = DatePickerDisplayMode.full,
    this.onDateChanged,
    this.showQuickButtons = false,
    this.timePickerWidget,
  }) : super(key: key);

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// 日期选择器控制器
  late DatePickerController _controller;
  // 优化：用 ValueNotifier 代替 setState
  final ValueNotifier<int> _refreshNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    // 初始化控制器
    _controller = DatePickerController(
      initialDate: widget.initialDate,
      displayMode: widget.displayMode,
    );
    // 添加监听
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayMode != widget.displayMode) {
      final newController = DatePickerController(
        initialDate: _controller.selectedDate,
        displayMode: widget.displayMode,
      );
      final currentYear = _controller.currentYear;
      final currentMonth = _controller.currentMonth;
      _controller.removeListener(_onControllerChanged);
      _controller.dispose();
      _controller = newController;
      _controller.updateMonth(currentYear, currentMonth);
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _refreshNotifier.dispose();
    super.dispose();
  }

  /// 控制器变更回调
  void _onControllerChanged() {
    // 只刷新局部
    _refreshNotifier.value++;
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(_controller.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<int>(
          valueListenable: _refreshNotifier,
          builder: (context, _, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                DatePickerCalendar(
                  controller: _controller,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) {
                    if (widget.onDateChanged != null) {
                      widget.onDateChanged!(date);
                    }
                  },
                ),
                if (widget.showQuickButtons &&
                    _controller.viewMode == DatePickerViewMode.day) ...[
                  const SizedBox(height: 12),
                  _buildQuickButtons(context),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  /// 构建日期选择器头部
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;

    // 根据当前视图模式显示不同的标题
    String title = '';
    VoidCallback? onTitleTap;

    switch (_controller.viewMode) {
      case DatePickerViewMode.day:
        // 显示年月
        title = '${_controller.currentYear}年${_controller.currentMonth}月';
        if (_controller.showMonth) {
          onTitleTap = () {
            _controller.switchToMonthMode();
          };
        }
        break;
      case DatePickerViewMode.month:
        // 显示年
        title = '${_controller.currentYear}年';
        if (_controller.showYear) {
          onTitleTap = () {
            _controller.switchToYearMode();
          };
        }
        break;
      case DatePickerViewMode.year:
        // 显示年份范围
        final startYear = _controller.currentYear - 5;
        final endYear = _controller.currentYear + 6;
        title = '$startYear - $endYear';
        break;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.isDesktop(context) ? 420 : double.infinity,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 上一个按钮
            IconButton(
              icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
              onPressed: () {
                switch (_controller.viewMode) {
                  case DatePickerViewMode.day:
                    _controller.previousMonth();
                    break;
                  case DatePickerViewMode.month:
                    _controller.previousYear();
                    break;
                  case DatePickerViewMode.year:
                    _controller.updateMonth(
                        _controller.currentYear - 12, _controller.currentMonth);
                    break;
                }
              },
            ),

            // 标题
            GestureDetector(
              onTap: onTitleTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (onTitleTap != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: primaryColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 下一个按钮
            IconButton(
              icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
              onPressed: () {
                switch (_controller.viewMode) {
                  case DatePickerViewMode.day:
                    _controller.nextMonth();
                    break;
                  case DatePickerViewMode.month:
                    _controller.nextYear();
                    break;
                  case DatePickerViewMode.year:
                    _controller.updateMonth(
                        _controller.currentYear + 12, _controller.currentMonth);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快捷日期按钮
  Widget _buildQuickButton(
    BuildContext context,
    String text,
    DateTime date,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return ElevatedButton(
      onPressed: () {
        _controller.updateSelectedDate(date);
        _controller.updateMonth(date.year, date.month);
        if (widget.onDateChanged != null) {
          widget.onDateChanged!(date);
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isActive ? theme.colorScheme.onPrimary : primaryColor,
        backgroundColor: isActive ? primaryColor : theme.colorScheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isActive
                ? Colors.transparent
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }

  /// 构建快捷按钮组
  Widget _buildQuickButtons(BuildContext context) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final dayBeforeYesterday = now.subtract(const Duration(days: 2));

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.isDesktop(context) ? 420 : double.infinity,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 快捷日期按钮
            Row(
              children: [
                _buildQuickButton(
                  context,
                  "今天",
                  now,
                  DateUtil.isToday(_controller.selectedDate),
                ),
                const SizedBox(width: 8),
                _buildQuickButton(
                  context,
                  "昨天",
                  yesterday,
                  DateUtil.isYesterday(_controller.selectedDate),
                ),
                const SizedBox(width: 8),
                _buildQuickButton(
                  context,
                  "前天",
                  dayBeforeYesterday,
                  DateUtil.isDayBeforeYesterday(_controller.selectedDate),
                ),
              ],
            ),

            // 时间选择器组件（如果有）
            if (widget.timePickerWidget != null) widget.timePickerWidget!,
          ],
        ),
      ),
    );
  }
}
