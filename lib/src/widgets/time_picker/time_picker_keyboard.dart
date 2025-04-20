import 'package:flutter/material.dart';
import '../../controllers/time_picker_controller.dart';

/// 时间选择器键盘输入模式
class TimePickerKeyboard extends StatelessWidget {
  final TimePickerController controller;

  const TimePickerKeyboard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeInput(
            context: context,
            controller: controller.hourController,
            hint: '00',
            maxLength: 2,
            onChanged: (_) => controller.updateFromKeyboard(),
          ),
          _buildSeparator(context),
          _buildTimeInput(
            context: context,
            controller: controller.minuteController,
            hint: '00',
            maxLength: 2,
            onChanged: (_) => controller.updateFromKeyboard(),
          ),
          if (controller.showSeconds) ...[
            _buildSeparator(context),
            _buildTimeInput(
              context: context,
              controller: controller.secondController,
              hint: '00',
              maxLength: 2,
              onChanged: (_) => controller.updateFromKeyboard(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 4,
          ),
          isDense: true,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        ),
        onChanged: onChanged,
      ),
    );
  }
}