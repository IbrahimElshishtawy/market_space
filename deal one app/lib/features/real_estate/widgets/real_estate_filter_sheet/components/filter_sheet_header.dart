import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

class FilterSheetHeader extends StatelessWidget {
  final VoidCallback onClose;

  const FilterSheetHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Subtitle centered or right-aligned in RTL
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'تصفية البحث',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'حدد مواصفات عقارك المفضل لنتائج أدق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: AppColors.lightTextMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Close button (X inside circle or rounded button)
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20.0,
                  color: AppColors.neutral,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
