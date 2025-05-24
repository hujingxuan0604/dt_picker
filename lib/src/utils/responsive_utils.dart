import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 1200;
  }

  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 1200;
  }

  static double getDialSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isMobile(context)) {
      return math.min(size.width * 0.8, 280.0);
    } else if (isTablet(context)) {
      return math.min(size.width * 0.5, 320.0);
    }
    return math.min(size.width * 0.3, 360.0);
  }

  static EdgeInsets getDialPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12.0);
    }
    return const EdgeInsets.all(16.0);
  }

  static double getTimeInputWidth(BuildContext context) {
    if (isMobile(context)) {
      return 56.0;
    } else if (isTablet(context)) {
      return 64.0;
    }
    return 72.0;
  }

  static double getCalendarCellSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isMobile(context)) {
      return math.min(size.width / 7 - 8, 40.0);
    } else if (isTablet(context)) {
      return math.min(size.width / 7 - 12, 48.0);
    }
    return math.min(size.width / 7 - 16, 56.0);
  }
}
