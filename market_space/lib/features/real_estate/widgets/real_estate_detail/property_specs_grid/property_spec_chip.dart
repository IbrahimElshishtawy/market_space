import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../data/models/real_estate_detail_model.dart';

class PropertySpecChip extends StatelessWidget {
  final PropertySpecItem item;

  const PropertySpecChip({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.md,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.iconType.defaultIcon, size: 16.0, color: AppColors.neutral),
          const SizedBox(width: 5.0),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
