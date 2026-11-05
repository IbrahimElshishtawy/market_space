import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../data/models/real_estate_listing_model.dart';

class PropertyPriceMarker extends StatelessWidget {
  final RealEstateListingModel property;
  final bool isSelected;
  final VoidCallback onTap;

  const PropertyPriceMarker({
    super.key,
    required this.property,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary : AppColors.neutral;
    const textColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.35 : 0.2),
              blurRadius: isSelected ? 8.0 : 4.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              property.type == RealEstateType.forRent
                  ? Icons.key_rounded
                  : Icons.home_work_rounded,
              size: 13.0,
              color: textColor,
            ),
            const SizedBox(width: 3.0),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  property.priceFormatted,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
