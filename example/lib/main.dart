import 'package:flutter/material.dart';
import 'package:dt_picker/date_time_picker.dart';
import 'package:dt_picker/time_picker.dart';
import 'package:dt_picker/date_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateTimePicker Demo',
      theme: _getLightTheme(),
      darkTheme: _getDarkTheme(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
  
  // 获取亮色主题
  ThemeData _getLightTheme() {
    const primaryColor = Color(0xFF2196F3);
    const secondaryColor = Color(0xFF03A9F4);
    
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: const Color(0xFFF8F9FA),
        error: const Color(0xFFE53935),
        surface: Colors.white,
        onSurface: const Color(0xFF424242),
        primaryContainer: primaryColor.withOpacity(0.12),
        secondaryContainer: secondaryColor.withOpacity(0.12),
        surfaceVariant: const Color(0xFFEEEEEE),
        outline: const Color(0xFFBDBDBD),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  // 获取暗色主题
  ThemeData _getDarkTheme() {
    const primaryColor = Color(0xFF2196F3);
    const secondaryColor = Color(0xFF03A9F4);
    
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: const Color(0xFFE53935),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        onSurface: const Color(0xFFE0E0E0),
        primaryContainer: primaryColor.withOpacity(0.15),
        secondaryContainer: secondaryColor.withOpacity(0.15),
        surfaceVariant: const Color(0xFF2D2D2D),
        outline: const Color(0xFF555555),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF2D2D2D),
      shadowColor: Colors.black.withOpacity(0.2),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 不同类型的选择结果
  DateTimeResult? _dateTimeResult; // 日期时间
  DateTimeResult? _yearMonthResult; // 年月
  DateTime? _dateOnlyResult; // 仅日期
  DateTimeResult? _dateTimePickerResult; // 日期时间
  TimeWithSeconds? _timeWithSecondsResult; // 时间(含秒)
  TimeWithSeconds? _timeNoSecondsResult; // 时间(不含秒)
  DateTimeResult? _dateTimeNoTimeResult; // 仅日期（无时间）
  DateTimeResult? _dateTimeWithQuickButtons; // 带快捷按钮的日期时间

  // 显示年月选择对话框
  Future<void> _showYearMonthPicker() async {
    DateTime? selectedDate = _yearMonthResult?.date ?? DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetDatePicker(
        title: '选择年月',
        child: DatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          displayMode: DatePickerDisplayMode.yearMonth,
          onDateChanged: (date) {
            selectedDate = date;
          },
        ),
        onConfirm: () => Navigator.pop(context, selectedDate),
      ),
    );

    if (result != null) {
      setState(() {
        _yearMonthResult = DateTimeResult(
          date: result,
          dateDisplayMode: DatePickerDisplayMode.yearMonth,
        );
      });
    }
  }

  // 显示日期选择对话框
  Future<void> _showDatePicker() async {
    DateTime? selectedDate = _dateOnlyResult ?? DateTime.now();
    final result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetDatePicker(
        title: '选择日期',
        child: DatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          displayMode: DatePickerDisplayMode.full,
          onDateChanged: (date) {
            selectedDate = date;
          },
          showQuickButtons: true,
        ),
        onConfirm: () => Navigator.pop(context, selectedDate),
      ),
    );

    if (result != null) {
      setState(() {
        _dateOnlyResult = result;
      });
    }
  }

  // 显示日期时间选择对话框
  Future<void> _showDateTimePicker() async {
    DateTimeResult? selectedResult;
    final initialDate = _dateTimePickerResult?.date ?? DateTime.now();

    final result = await showModalBottomSheet<DateTimeResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetDatePicker(
        title: '选择日期和时间',
        child: DateTimePicker(
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          showQuickButtons: false,
          displayMode: DatePickerDisplayMode.dateTime,
          onDateTimeChanged: (date) {
            selectedResult = DateTimeResult(
              date: date,
              time: TimeOfDay.fromDateTime(date),
              second: date.second,
              dateDisplayMode: DatePickerDisplayMode.dateTime,
            );
          },
        ),
        onConfirm: () => Navigator.pop(context, selectedResult),
      ),
    );

    if (result != null) {
      setState(() {
        _dateTimePickerResult = result;
      });
    }
  }

  // 显示带快捷按钮的日期时间选择对话框
  Future<void> _showDateTimePickerWithQuickButtons() async {
    DateTimeResult? selectedResult;
    final initialDate = _dateTimeWithQuickButtons?.date ?? DateTime.now();

    final result = await showModalBottomSheet<DateTimeResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetDatePicker(
        title: '选择日期和时间',
        child: DateTimePicker(
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          showQuickButtons: true,
          showSeconds: true,
          displayMode: DatePickerDisplayMode.dateTime,
          onDateTimeChanged: (date) {
            selectedResult = DateTimeResult(
              date: date,
              time: TimeOfDay.fromDateTime(date),
              second: date.second,
              dateDisplayMode: DatePickerDisplayMode.dateTime,
            );
          },
        ),
        onConfirm: () => Navigator.pop(context, selectedResult),
      ),
    );

    if (result != null) {
      setState(() {
        _dateTimeWithQuickButtons = result;
      });
    }
  }

  // 显示日期选择对话框(带快捷按钮)
  Future<void> _showDatePickerWithQuickButtons() async {
    DateTimeResult? selectedResult;
    final initialDate =
        _dateTimeNoTimeResult?.date ?? _dateOnlyResult ?? DateTime.now();

    final result = await showModalBottomSheet<DateTimeResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetDatePicker(
        title: '选择日期',
        child: DatePicker(
          initialDate: initialDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          displayMode: DatePickerDisplayMode.full,
          showQuickButtons: true,
          onDateChanged: (date) {
            selectedResult = DateTimeResult(
              date: date,
              dateDisplayMode: DatePickerDisplayMode.full,
            );
          },
        ),
        onConfirm: () => Navigator.pop(context, selectedResult),
      ),
    );

    if (result != null) {
      setState(() {
        _dateTimeNoTimeResult = result;
      });
    }
  }

  // 显示时间选择对话框（含秒）
  Future<void> _showTimePickerWithSeconds() async {
    TimeOfDay selectedTime = _timeWithSecondsResult?.time ?? TimeOfDay.now();
    int selectedSecond = _timeWithSecondsResult?.second ?? 0;

    final result = await showModalBottomSheet<TimeWithSeconds>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetTimePicker(
        title: '选择时间',
        child: TimePicker(
          initialTime: selectedTime,
          initialSecond: selectedSecond,
          showSeconds: true,
          onTimeChanged: (time, second) {
            selectedTime = time;
            selectedSecond = second;
          },
        ),
        onConfirm: () => Navigator.pop(
          context,
          TimeWithSeconds(selectedTime, selectedSecond),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _timeWithSecondsResult = result;
      });
    }
  }

  // 显示时间选择对话框（不含秒）
  Future<void> _showTimePicker() async {
    TimeOfDay selectedTime = _timeNoSecondsResult?.time ?? TimeOfDay.now();
    int selectedSecond = _timeNoSecondsResult?.second ?? 0;

    final result = await showModalBottomSheet<TimeWithSeconds>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildBottomSheetTimePicker(
        title: '选择时间',
        child: TimePicker(
          initialTime: selectedTime,
          initialSecond: selectedSecond,
          showSeconds: false,
          onTimeChanged: (time, second) {
            selectedTime = time;
            selectedSecond = second;
          },
        ),
        onConfirm: () => Navigator.pop(
          context,
          TimeWithSeconds(selectedTime, selectedSecond),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _timeNoSecondsResult = result;
      });
    }
  }

  // 构建底部弹出的日期选择器
  Widget _buildBottomSheetDatePicker({
    required String title,
    required Widget child,
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.0, 
        right: 16.0, 
        top: 8.0,
        bottom: mediaQuery.viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          // 日期选择器内容
          child,
          // const SizedBox(height: 24),
          // 按钮行 - 居中显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  side: BorderSide(color: theme.colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建底部弹出的时间选择器
  Widget _buildBottomSheetTimePicker({
    required String title,
    required Widget child,
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.0, 
        right: 16.0, 
        top: 16.0,
        bottom: mediaQuery.viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 时间选择器内容
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 按钮行 - 居中显示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  side: BorderSide(color: theme.colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '确定',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('日期时间选择器示例'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 选择年月
            _buildSectionTitle('1. 选择年月'),
            ElevatedButton.icon(
              onPressed: _showYearMonthPicker,
              icon: const Icon(Icons.date_range),
              label: const Text('选择年月'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            if (_yearMonthResult != null)
              _buildResultCard(
                '选择结果: ${_yearMonthResult!.date.year}年${_yearMonthResult!.date.month}月',
                Colors.purple.withOpacity(0.1),
              ),

            // 添加直接使用DatePicker的测试组件
            const SizedBox(height: 10),
            _buildSectionTitle('1.1 直接显示年月选择器'),
            const DatePicker(
              displayMode: DatePickerDisplayMode.yearMonth,
            ),

            const SizedBox(height: 20),

            // 2. 仅选择日期
            _buildSectionTitle('2. 仅选择日期'),
            ElevatedButton.icon(
              onPressed: _showDatePicker,
              icon: const Icon(Icons.calendar_today),
              label: const Text('仅选择日期'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateOnlyResult != null)
              _buildResultCard(
                '选择结果: ${_dateOnlyResult!.year}年${_dateOnlyResult!.month}月${_dateOnlyResult!.day}日',
                Colors.indigo.withOpacity(0.1),
              ),

            const SizedBox(height: 20),

            _buildSectionTitle('3. 选择日期和时间'),
            ElevatedButton.icon(
              onPressed: _showDateTimePicker,
              icon: const Icon(Icons.calendar_today),
              label: const Text('选择日期和时间'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateTimePickerResult != null)
              _buildResultCard(
                '选择结果: ${_dateTimePickerResult!.format(showSeconds: true)}',
                Colors.pink.withOpacity(0.1),
              ),

            // 添加直接使用DateTimePicker的测试组件
            const SizedBox(height: 10),
            DateTimePicker(
              initialDate: DateTime.now(),
              showQuickButtons: true,
              displayMode: DatePickerDisplayMode.dateTime,
              onDateTimeChanged: (result) {
                // 仅用于测试
              },
            ),

            const SizedBox(height: 20),

            // 4. 带快捷按钮的日期和时间选择
            _buildSectionTitle('4. 带快捷按钮的日期和时间'),
            ElevatedButton.icon(
              onPressed: _showDateTimePickerWithQuickButtons,
              icon: const Icon(Icons.calendar_month),
              label: const Text('带快捷按钮的日期和时间'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateTimeWithQuickButtons != null)
              _buildResultCard(
                '选择结果: ${_dateTimeWithQuickButtons!.format(showSeconds: true)}',
                Colors.blue.withOpacity(0.1),
              ),

            const SizedBox(height: 20),

            // 5. 仅选择日期（带快捷按钮）
            _buildSectionTitle('5. 仅选择日期（带快捷按钮）'),
            ElevatedButton.icon(
              onPressed: _showDatePickerWithQuickButtons,
              icon: const Icon(Icons.event_available),
              label: const Text('选择日期（带快捷按钮）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateTimeNoTimeResult != null)
              _buildResultCard(
                '选择结果: ${_dateTimeNoTimeResult!.format(showTime: false)}',
                Colors.teal.withOpacity(0.1),
              ),

            const SizedBox(height: 20),

            // 6. 选择时间（含秒）
            _buildSectionTitle('6. 选择时间（含秒）'),
            ElevatedButton.icon(
              onPressed: _showTimePickerWithSeconds,
              icon: const Icon(Icons.access_time),
              label: const Text('选择时间（含秒）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            if (_timeWithSecondsResult != null)
              _buildResultCard(
                '选择结果: ${_timeWithSecondsResult!.time.hour.toString().padLeft(2, '0')}:${_timeWithSecondsResult!.time.minute.toString().padLeft(2, '0')}:${_timeWithSecondsResult!.second.toString().padLeft(2, '0')}',
                Colors.orange.withOpacity(0.1),
              ),

            const SizedBox(height: 20),

            // 7. 选择时间（不含秒）
            _buildSectionTitle('7. 选择时间（不含秒）'),
            ElevatedButton.icon(
              onPressed: _showTimePicker,
              icon: const Icon(Icons.more_time),
              label: const Text('选择时间（不含秒）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
            if (_timeNoSecondsResult != null)
              _buildResultCard(
                '选择结果: ${_timeNoSecondsResult!.time.hour.toString().padLeft(2, '0')}:${_timeNoSecondsResult!.time.minute.toString().padLeft(2, '0')}',
                Colors.deepOrange.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }

  // 构建区域标题
  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  // 构建结果显示卡片
  Widget _buildResultCard(String text, Color backgroundColor) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // 在暗色模式下调整背景色不透明度
    final bgColor = isDarkMode 
        ? backgroundColor.withOpacity(0.2) 
        : backgroundColor;
    
    return Card(
      elevation: 0,
      color: bgColor,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
