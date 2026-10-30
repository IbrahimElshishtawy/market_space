import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';

class SearchThisAreaButton extends StatelessWidget {
  final VoidCallback onTap;

  const SearchThisAreaButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadii.full,
      elevation: 4.0,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.full,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: AppRadii.full,
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: AppColors.primary, size: 16.0),
              SizedBox(width: 6.0),
              Text(
                'إعادة البحث في هذه المنطقة',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
