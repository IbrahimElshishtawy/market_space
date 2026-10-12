import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class RealEstateCardLayout {
  static EdgeInsets margin(BuildContext context) {
    return const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs + 2,
    );
  }

  static EdgeInsets contentPadding(BuildContext context) {
    return const EdgeInsets.all(AppSpacing.md);
  }

  static double imageHeight = 175.0;
}
