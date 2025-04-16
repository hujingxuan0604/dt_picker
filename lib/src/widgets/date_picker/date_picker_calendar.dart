import 'package:flutter/material.dart';
import '../../controllers/date_picker_controller.dart';

/// 日期选择器日历组件
class DatePickerCalendar extends StatelessWidget {
  final DatePickerController controller;
  
  const DatePickerCalendar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // 根据当前视图模式选择显示的组件
    switch (controller.viewMode) {
      case DatePickerViewMode.day:
        return _buildDayView(context);
      case DatePickerViewMode.month:
        return _buildMonthView(context);
      case DatePickerViewMode.year:
        return _buildYearView(context);
    }
  }
  
  /// 构建日期视图
  Widget _buildDayView(BuildContext context) {
    final calendarDays = controller.getCalendarDays();
    const weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final theme = Theme.of(context);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 星期头部
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdayNames
              .map(
                (day) => SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Text(
                      day,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        
        // 日历网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 0,
            childAspectRatio: 1,
          ),
          itemCount: calendarDays.length,
          itemBuilder: (context, index) {
            final day = calendarDays[index];
            final isCurrentMonth = controller.isCurrentMonth(day);
            final isSelected = controller.isSelectedDate(day);
            final isToday = controller.isToday(day);
            
            return _buildDayCell(
              context: context,
              day: day,
              isCurrentMonth: isCurrentMonth,
              isSelected: isSelected,
              isToday: isToday,
              onTap: () => controller.updateSelectedDate(day),
            );
          },
        ),
      ],
    );
  }
  
  /// 构建月份选择视图
  Widget _buildMonthView(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = controller.currentMonth.year;
    final selectedMonth = controller.selectedDate.month;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currentYear年',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == controller.currentMonth.month;
              
              return InkWell(
                onTap: () => controller.updateMonth(currentYear, month),
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
  
  /// 构建年份选择视图
  Widget _buildYearView(BuildContext context) {
    final theme = Theme.of(context);
    const int startYear = 1970;
    const int yearCount = 100;
    final currentYear = controller.currentMonth.year;
    
    // 使用StatefulBuilder来在构建后执行滚动操作
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          // 创建滚动控制器
          final scrollController = ScrollController();
          
          // 在构建后执行滚动
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 计算当前年份在网格中的位置
            final index = currentYear - startYear;
            final row = index ~/ 4; // 每行4列
            
            // 估算的行高（根据childAspectRatio和间距计算）
            const rowHeight = 48.0 + 16.0; // 行高 + 垂直间距
            
            // 计算滚动位置，使选中的年份尽量居中
            final offset = row * rowHeight - (scrollController.position.viewportDimension - rowHeight) / 2;
            
            // 确保滚动位置在有效范围内
            final maxScrollExtent = scrollController.position.maxScrollExtent;
            final scrollOffset = offset.clamp(0.0, maxScrollExtent);
            
            // 执行滚动
            scrollController.jumpTo(scrollOffset);
          });
          
          return GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
            ),
            itemCount: yearCount,
            itemBuilder: (context, index) {
              final year = startYear + index;
              final isSelected = year == controller.currentMonth.year;
              
              return InkWell(
                onTap: () => controller.updateYear(year),
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
                      year.toString(),
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
          );
        },
      ),
    );
  }
  
  /// 构建日期单元格
  Widget _buildDayCell({
    required BuildContext context,
    required DateTime day,
    required bool isCurrentMonth,
    required bool isSelected,
    required bool isToday,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    // 根据状态设置颜色和样式
    Color textColor;
    Color? backgroundColor;
    BoxBorder? border;
    
    if (isSelected) {
      textColor = theme.colorScheme.onPrimary;
      backgroundColor = theme.colorScheme.primary;
    } else if (isToday) {
      textColor = theme.colorScheme.primary;
      backgroundColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
      border = Border.all(color: theme.colorScheme.primary);
    } else if (isCurrentMonth) {
      textColor = theme.colorScheme.onSurface;
      backgroundColor = null;
    } else {
      textColor = theme.colorScheme.onSurface.withOpacity(0.4);
      backgroundColor = null;
    }
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Center(
          child: Text(
            day.day.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected || isToday ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }
} 