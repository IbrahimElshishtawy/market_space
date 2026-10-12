import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../data/models/real_estate_listing_model.dart';
import 'real_estate_filter_bar_layout.dart';

class RealEstateFilterBar extends StatelessWidget {
  final RealEstateType selectedType;
  final ValueChanged<RealEstateType> onTypeSelected;
  final VoidCallback? onSortTap;

  const RealEstateFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RealEstateFilterBarLayout.padding(context),
      child: SizedBox(
        height: RealEstateFilterBarLayout.height,
        child: Row(
          children: [
            // Filter Chips list
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: RealEstateType.values.map((type) {
                  final isSelected = selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      onTap: () => onTypeSelected(type),
                      borderRadius: AppRadii.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: AppRadii.md,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neutral
                                : AppColors.lightBorder,
                            width: isSelected ? 1.2 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          type.label,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: AppColors.neutral,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 8.0),

            // Sort button ⇅
            InkWell(
              onTap: onSortTap,
              borderRadius: AppRadii.md,
              child: Container(
                width: RealEstateFilterBarLayout.height,
                height: RealEstateFilterBarLayout.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadii.md,
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  size: 20.0,
                  color: AppColors.neutral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
