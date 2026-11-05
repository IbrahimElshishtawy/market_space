import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';

abstract class RealEstateFilterSheetLayout {
  static const EdgeInsets sheetPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );

  static const EdgeInsets sectionPadding = EdgeInsets.only(
    bottom: AppSpacing.xl,
  );

  static const double maxSheetHeightFraction = 0.90;
  static const double chipSpacing = AppSpacing.sm;
  static const double chipRunSpacing = AppSpacing.sm;

  static const ShapeBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xlValue)),
  );
}
