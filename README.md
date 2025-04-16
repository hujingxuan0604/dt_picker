# DT Picker

一个功能丰富的 Flutter 日期和时间选择器组件库，具有高度可定制性和美观的 UI。

## 特性

- **多样化选择模式**：
  - 日期选择（年月日）
  - 时间选择（小时、分钟、可选秒）
  - 日期时间组合选择
  - 年月选择

- **灵活的 UI 交互**：
  - 表盘式时间选择
  - 键盘式时间输入
  - 日历式日期选择
  - 支持"今天"、"昨天"等快捷选择

- **高度可定制**：
  - 自定义主题和颜色
  - 适配浅色/深色模式
  - 可自定义文案和格式化

- **易于集成**：模块化设计，可独立使用各组件或组合使用

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  dt_picker: ^1.0.0
```

然后运行：

```
flutter pub get
```

## 基本用法

### 导入包

```dart
import 'package:dt_picker/dt_picker_index.dart';
```

### 日期时间组合选择器

```dart
// 显示日期和时间选择对话框
final result = await showDateTimePicker(
  context: context,
  initialDateTime: DateTime.now(),
  showSeconds: true,
);

if (result != null) {
  print('选择结果: ${result.format()}');
}
```

### 仅选择日期

```dart
// 选择日期
final date = await showDatePicker2(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
);

if (date != null) {
  print('选择的日期: ${date.year}年${date.month}月${date.day}日');
}
```

### 仅选择时间

```dart
// 选择时间（带秒）
final time = await showTimePickerWithSeconds(
  context: context,
  initialTime: TimeOfDay.now(),
  initialSecond: 0,
);

if (time != null) {
  print('选择的时间: ${time.format()}');
}
```

### 选择年月

```dart
// 选择年月
final result = await showCustomDatePicker(
  context: context,
  initialDate: DateTime.now(),
  dateDisplayMode: DatePickerDisplayMode.yearMonth,
);

if (result != null) {
  print('选择结果: ${result.date.year}年${result.date.month}月');
}
```

## 高级用法

### 自定义日期选择器

```dart
CustomDateTimePicker(
  showTimePicker: true,
  initialDateTime: DateTime.now(),
  onDateTimeChanged: (dateTime) {
    print('日期时间已更改: $dateTime');
  },
  dateDisplayMode: DatePickerDisplayMode.full,
  timeDisplayMode: TimePickerDisplayMode.withSeconds,
)
```

### 自定义时间选择器

```dart
TimePicker(
  initialTime: TimeOfDay(hour: 10, minute: 30),
  initialSecond: 15,
  showSeconds: true,
  onTimeChanged: (time, second) {
    print('选择的时间: ${time.hour}:${time.minute}:$second');
  },
  inputType: TimePickerInputType.both, // 同时支持表盘和键盘输入
)
```

## 组件结构

- **DatePicker**: 日期选择器
- **TimePicker**: 时间选择器
- **DateTimePicker**: 日期时间组合选择器
- **TimePickerDial**: 表盘式时间选择器
- **TimePickerKeyboard**: 键盘式时间输入器

## 示例

查看示例项目了解更多用法：

```
example/lib/main.dart
```

## 兼容性

- **Flutter**: >=3.0.0
- **Dart SDK**: >=2.17.0 <4.0.0

## 许可证

MIT
