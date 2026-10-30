import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../../../core/theme/app_spacing.dart';

class FilterSheetActions extends StatelessWidget {
  final VoidCallback onApply;
  final VoidCallback onCancel;

  const FilterSheetActions({
    super.key,
    required this.onApply,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        children: [
          // Cancel button (Left in RTL view)
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                side: const BorderSide(color: AppColors.neutral, width: 1.2),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Apply Filter button (Right in RTL view)
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                backgroundColor: AppColors.neutral,
                elevation: 0,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
              ),
              child: const Text(
                'تطبيق الفلترة',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
