import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class RealEstateSearchBarLayout {
  static EdgeInsets padding(BuildContext context) {
    return const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    );
  }

  static double height = 48.0;
}
