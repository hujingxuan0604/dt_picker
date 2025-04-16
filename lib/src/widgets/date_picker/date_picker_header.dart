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
    final currentYear = controller.currentMonth.year;
    final currentMonth = controller.currentMonth.month;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              onPressed: () => controller.changeMonth(-1),
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
                    onTap: () => controller.switchToYearMode(),
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
                            ? theme.colorScheme.primaryContainer
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentYear年',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.viewMode == DatePickerViewMode.year
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: controller.viewMode == DatePickerViewMode.year
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: controller.viewMode == DatePickerViewMode.year
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
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
                    onTap: () => controller.switchToMonthMode(),
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
                            ? theme.colorScheme.primaryContainer
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentMonth月',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: controller.viewMode == DatePickerViewMode.month
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: controller.viewMode == DatePickerViewMode.month
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: controller.viewMode == DatePickerViewMode.month
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
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
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onPressed: () => controller.changeMonth(1),
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
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          // 年份选择器
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // 监听滚动停止事件，更新选中的年份
                    if (notification is ScrollEndNotification) {
                      setState(() {
                        _selectedYear = startYear + _scrollController.selectedItem;
                      });
                    }
                    // 监听滚动更新事件，实时更新选中的年份
                    else if (notification is ScrollUpdateNotification) {
                      // 获取当前选中的项索引
                      if (_scrollController.position.hasContentDimensions) {
                        final index = _scrollController.selectedItem;
                        final year = startYear + index;
                        if (_selectedYear != year) {
                          setState(() {
                            _selectedYear = year;
                          });
                        }
                      }
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
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
                            decoration: isSelected ? BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ) : null,
                            child: Text(
                              '$year年',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  widget.onYearSelected(_selectedYear);
                },
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
              color: theme.colorScheme.onSurface,
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
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$month月',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 