import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class RealEstateHeaderLayout {
  static EdgeInsets padding(BuildContext context) {
    return const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.xs,
    );
  }

  static double avatarRadius = 22.0;
  static double actionButtonSize = 42.0;
}
