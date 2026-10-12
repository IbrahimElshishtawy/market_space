import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../data/models/real_estate_listing_model.dart';
import 'property_main_header_layout.dart';

class PropertyMainHeader extends StatelessWidget {
  final String title;
  final String location;
  final String priceFormatted;
  final String? pricePeriod;
  final RealEstateType type;

  const PropertyMainHeader({
    super.key,
    required this.title,
    required this.location,
    required this.priceFormatted,
    this.pricePeriod,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property Title
        Text(
          title,
          style: const TextStyle(
            fontSize: PropertyMainHeaderLayout.titleFontSize,
            fontWeight: FontWeight.w800,
            color: AppColors.neutral,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 4.0),

        // Location Subtitle
        Text(
          location,
          style: const TextStyle(
            fontSize: PropertyMainHeaderLayout.locationFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextMuted,
          ),
        ),

        const SizedBox(height: 10.0),

        // Price and Type Badge Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Price Text
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: priceFormatted,
                    style: const TextStyle(
                      fontSize: PropertyMainHeaderLayout.priceFontSize,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD97706),
                    ),
                  ),
                  if (pricePeriod != null) ...[
                    const TextSpan(text: ' / '),
                    TextSpan(
                      text: pricePeriod,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Type Pill Tag (e.g. لليجار)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 5.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutral,
                borderRadius: AppRadii.sm,
              ),
              child: Text(
                type == RealEstateType.forRent ? 'لليجار' : 'للبيع',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
