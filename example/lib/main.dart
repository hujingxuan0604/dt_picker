import 'package:flutter/material.dart';
import 'package:dt_picker/dt_picker_index.dart';
import 'package:dt_picker/time_picker.dart' show TimeWithSeconds;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateTimePicker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
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
  TimeWithSeconds? _timeWithSecondsResult; // 时间(含秒)
  TimeWithSeconds? _timeNoSecondsResult; // 时间(不含秒)
  DateTimeResult? _dateTimeNoTimeResult; // 仅日期（无时间）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日期时间选择器示例'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 选择日期和时间（今昨前）
            _buildSectionTitle('1. 选择日期和时间（今昨前）'),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showDialog<DateTime>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      insetPadding: const EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: CustomDateTimePicker(
                          showTimePicker: true,
                        ),
                      ),
                    );
                  },
                );
                
                if (result != null) {
                  setState(() {
                    _dateTimeResult = DateTimeResult(
                      date: DateTime(result.year, result.month, result.day),
                      time: TimeOfDay.fromDateTime(result),
                      second: result.second,
                      dateDisplayMode: DatePickerDisplayMode.full,
                    );
                  });
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('选择日期和时间（今昨前）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateTimeResult != null)
              _buildResultCard(
                '选择结果: ${_dateTimeResult!.format(showSeconds: true)}',
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            
            const SizedBox(height: 20),
            
            // 2. 选择年月
            _buildSectionTitle('2. 选择年月'),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showCustomDatePicker(
                  context: context,
                  initialDate: _yearMonthResult?.date,
                  dateDisplayMode: DatePickerDisplayMode.yearMonth,
                );
                if (result != null) {
                  setState(() {
                    _yearMonthResult = result;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: const Text('选择年月'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
            ),
            if (_yearMonthResult != null)
              _buildResultCard(
                '选择结果: ${_yearMonthResult!.date.year}年${_yearMonthResult!.date.month}月',
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
            
            const SizedBox(height: 20),
            
            // 3. 仅选择日期
            _buildSectionTitle('3. 仅选择日期'),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker2(
                  context: context,
                  initialDate: _dateOnlyResult,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _dateOnlyResult = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('仅选择日期'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateOnlyResult != null)
              _buildResultCard(
                '选择结果: ${_dateOnlyResult!.year}年${_dateOnlyResult!.month}月${_dateOnlyResult!.day}日',
                Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              ),
            
            const SizedBox(height: 20),
            
            // 3.1. 仅选择日期（不显示时间选择器）
            _buildSectionTitle('3.1 仅选择日期（无时间选择器）'),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showCustomDatePicker(
                  context: context,
                  initialDate: _dateOnlyResult,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  dateDisplayMode: DatePickerDisplayMode.dateOnly,
                );
                if (result != null) {
                  setState(() {
                    _dateTimeNoTimeResult = result;
                  });
                }
              },
              icon: const Icon(Icons.event_available),
              label: const Text('选择日期（无时间选择器）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                foregroundColor: Colors.white,
              ),
            ),
            if (_dateTimeNoTimeResult != null)
              _buildResultCard(
                '选择结果: ${_dateTimeNoTimeResult!.format(showTime: false)}',
                Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
              ),
            
            const SizedBox(height: 20),
            
            // 4. 选择时间（含秒）
            _buildSectionTitle('4. 选择时间（含秒）'),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showTimePickerWithSeconds(
                  context: context,
                  initialTime: _timeWithSecondsResult?.time ?? TimeOfDay.now(),
                  initialSecond: _timeWithSecondsResult?.second ?? 0,
                  showSeconds: true,
                );
                if (result != null) {
                  setState(() {
                    _timeWithSecondsResult = result;
                  });
                }
              },
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
            
            // 5. 选择时间（不含秒）
            _buildSectionTitle('5. 选择时间（不含秒）'),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await showTimePickerWithSeconds(
                  context: context,
                  initialTime: _timeNoSecondsResult?.time ?? TimeOfDay.now(),
                  showSeconds: false,
                );
                if (result != null) {
                  setState(() {
                    _timeNoSecondsResult = result;
                  });
                }
              },
              icon: const Icon(Icons.more_time),
              label: const Text('选择时间（不含秒）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            if (_timeNoSecondsResult != null)
              _buildResultCard(
                '选择结果: ${_timeNoSecondsResult!.time.hour.toString().padLeft(2, '0')}:${_timeNoSecondsResult!.time.minute.toString().padLeft(2, '0')}',
                Colors.teal.withOpacity(0.1),
              ),
          ],
        ),
      ),
    );
  }
  
  // 构建区域标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
  
  // 构建结果显示卡片
  Widget _buildResultCard(String text, Color backgroundColor) {
    return Card(
      elevation: 0,
      color: backgroundColor,
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
} 