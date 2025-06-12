import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';

/// 日期选择器头部组件
class DatePickerHeader extends StatelessWidget {
  final DatePickerController controller;

  const DatePickerHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final currentYear = controller.currentYear;
    final currentMonth = controller.currentMonth;

    // 根据当前主题确定颜色
    final headerBgColor = isDarkMode 
        ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
        : const Color(0xFFEEEEEE);
    
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    
    // 选中状态的背景色
    final selectedBgColor = isDarkMode
        ? primaryColor.withOpacity(0.2)
        : const Color(0xFFE3F2FD);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 上个月按钮
          if (controller.showMonth || controller.showDay)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded, 
                size: 16, 
                color: theme.colorScheme.primary,
              ),
              onPressed: () => controller.previousMonth(),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            const SizedBox(width: 40), // 占位符

          // 年月选择
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 年份选择按钮
                if (controller.showYear)
                  InkWell(
                    onTap: () {
                      if (controller.viewMode != DatePickerViewMode.year) {
                        controller.switchToYearMode();
                      } else {
                        // 显示年份选择器对话框
                        _showYearPickerDialog(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        color: controller.viewMode == DatePickerViewMode.year
                            ? selectedBgColor
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentYear年',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  controller.viewMode == DatePickerViewMode.year
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  controller.viewMode == DatePickerViewMode.year
                                      ? primaryColor
                                      : onSurfaceColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color:
                                controller.viewMode == DatePickerViewMode.year
                                    ? primaryColor
                                    : onSurfaceColor.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (controller.showYear && controller.showMonth)
                  const SizedBox(width: 8),

                // 月份选择按钮
                if (controller.showMonth)
                  InkWell(
                    onTap: () {
                      if (controller.viewMode != DatePickerViewMode.month) {
                        controller.switchToMonthMode();
                      } else {
                        // 显示月份选择器对话框
                        _showMonthPickerDialog(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        color: controller.viewMode == DatePickerViewMode.month
                            ? selectedBgColor
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentMonth月',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.viewMode ==
                                      DatePickerViewMode.month
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: controller.viewMode ==
                                      DatePickerViewMode.month
                                  ? primaryColor
                                  : onSurfaceColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color:
                                controller.viewMode == DatePickerViewMode.month
                                    ? primaryColor
                                    : onSurfaceColor.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 下个月按钮
          if (controller.showMonth || controller.showDay)
            IconButton(
              icon: Icon(Icons.arrow_forward_ios_rounded, 
                size: 16,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => controller.nextMonth(),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            const SizedBox(width: 40), // 占位符
        ],
      ),
    );
  }

  // 显示年份选择器对话框
  void _showYearPickerDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          child: YearPickerDialog(
            initialYear: controller.currentYear,
            onYearSelected: (year) {
              controller.updateMonth(year, controller.currentMonth);
              if (controller.showMonth) {
                controller.switchToMonthMode();
              } else if (controller.showDay) {
                controller.switchToDayMode();
              }
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  // 显示月份选择器对话框
  void _showMonthPickerDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          child: MonthPickerDialog(
            initialMonth: controller.currentMonth,
            onMonthSelected: (month) {
              controller.updateMonth(controller.currentYear, month);
              if (controller.showDay) {
                controller.switchToDayMode();
              }
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
}

/// 年份选择器对话框
class YearPickerDialog extends StatefulWidget {
  final int initialYear;
  final Function(int) onYearSelected;

  const YearPickerDialog({
    super.key,
    required this.initialYear,
    required this.onYearSelected,
  });

  @override
  State<YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<YearPickerDialog> {
  late FixedExtentScrollController _scrollController;

  // 年份范围从1970开始，持续100年
  static const int startYear = 1970;
  static const int yearCount = 100;

  // 当前选中的年份
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    // 初始化选中的年份
    _selectedYear = widget.initialYear;
    // 计算初始位置
    final initialIndex = widget.initialYear - startYear;
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex.clamp(0, yearCount - 1),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 根据主题确定颜色
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final containerBgColor = isDarkMode 
        ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
        : const Color(0xFFF5F5F5);
    final selectedBgColor = isDarkMode
        ? primaryColor.withOpacity(0.2)
        : const Color(0xFFE3F2FD);
    
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择年份',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // 年份选择器
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 40,
                  perspective: 0.005,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    // 当选中项改变时更新选中的年份
                    setState(() {
                      _selectedYear = startYear + index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: yearCount,
                    builder: (context, index) {
                      final year = startYear + index;
                      final isSelected = year == _selectedYear;

                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: selectedBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                )
                              : null,
                          child: Text(
                            '$year年',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? primaryColor : textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 中间的选中指示器
                Center(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 操作按钮
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
                  widget.onYearSelected(_selectedYear);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 月份选择器对话框
class MonthPickerDialog extends StatelessWidget {
  final int initialMonth;
  final Function(int) onMonthSelected;

  const MonthPickerDialog({
    super.key,
    required this.initialMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 根据主题确定颜色
    final primaryColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;
    final containerBgColor = isDarkMode 
        ? theme.colorScheme.surfaceVariant.withOpacity(0.1)
        : const Color(0xFFF5F5F5);
    final selectedBgColor = isDarkMode
        ? primaryColor.withOpacity(0.2)
        : const Color(0xFFE3F2FD);
    final borderColor = theme.colorScheme.outline;
        
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择月份',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),

          // 月份网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == initialMonth;

              return InkWell(
                onTap: () => onMonthSelected(month),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedBgColor
                        : containerBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : borderColor.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$month月',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),

          // 操作按钮
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
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('关闭'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
