import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/ac_part_item_model.dart';
import 'ac_part_card.dart';
import 'ac_parts_grid_layout.dart';

class AcPartsGridSection extends StatelessWidget {
  final List<AcPartItemModel> parts;
  final ValueChanged<AcPartItemModel>? onPartTap;
  final ValueChanged<AcPartItemModel>? onAddToCartTap;
  final VoidCallback? onViewAllTap;

  const AcPartsGridSection({
    super.key,
    required this.parts,
    this.onPartTap,
    this.onAddToCartTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AcPartsGridLayout.horizontalPadding,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Right "قطع غيار وملحقات التكييف", Left "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'قطع غيار وملحقات التكييف',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // 2x2 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: parts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: AcPartsGridLayout.itemHeight,
              crossAxisSpacing: AcPartsGridLayout.crossAxisSpacing,
              mainAxisSpacing: AcPartsGridLayout.mainAxisSpacing,
            ),
            itemBuilder: (context, index) {
              final part = parts[index];
              return AcPartCard(
                part: part,
                onTap: () => onPartTap?.call(part),
                onAddToCartTap: () => onAddToCartTap?.call(part),
              );
            },
          ),
        ],
      ),
    );
  }
}
