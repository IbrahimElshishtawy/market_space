import 'package:flutter/material.dart';

/// Screen breakpoint constants for mobile form factors.
class AppBreakpoints {
  /// Devices with screen width under 360dp (e.g. small Androids, iPhone SE 1st gen).
  static const double compact = 360.0;

  /// Standard phone screen width boundary.
  static const double standard = 410.0;

  /// Large phones / Phablets.
  static const double large = 600.0;
}

/// Extension providing responsive layout dimensions and helpers.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isCompactPhone => screenWidth < AppBreakpoints.compact;
  bool get isStandardPhone => screenWidth >= AppBreakpoints.compact && screenWidth < AppBreakpoints.standard;
  bool get isLargePhone => screenWidth >= AppBreakpoints.standard;

  /// Responsive horizontal screen margin: 12dp on compact, 16dp on standard and larger.
  double get horizontalScreenPadding => isCompactPhone ? 12.0 : 16.0;

  /// Returns a responsive value tailored to mobile sizes.
  T responsiveValue<T>({
    required T compact,
    T? standard,
    T? large,
  }) {
    if (isCompactPhone) {
      return compact;
    }
    if (isLargePhone && large != null) {
      return large;
    }
    return standard ?? compact;
  }
}
