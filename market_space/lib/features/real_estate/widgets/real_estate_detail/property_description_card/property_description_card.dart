import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radii.dart';
import '../../../data/models/real_estate_detail_model.dart';
import 'property_description_card_layout.dart';

class PropertyDescriptionCard extends StatelessWidget {
  final RealEstateDetailModel detail;
  final Widget advertiserWidget;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const PropertyDescriptionCard({
    super.key,
    required this.detail,
    required this.advertiserWidget,
    required this.isExpanded,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: PropertyDescriptionCardLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Text(
            'الوصف التفصيلي',
            style: TextStyle(
              fontSize: PropertyDescriptionCardLayout.headerFontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.neutral,
            ),
          ),

          const SizedBox(height: 12.0),

          // Subtitle: عن الشقة
          const Text(
            'عن الشقة:',
            style: TextStyle(
              fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            detail.aboutProperty,
            style: const TextStyle(
              fontSize: PropertyDescriptionCardLayout.bodyFontSize,
              color: AppColors.lightTextPrimary,
              height: 1.5,
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 14.0),

            // Subtitle: تفاصيل المساحة والتقسيم
            const Text(
              'تفاصيل المساحة والتقسيم:',
              style: TextStyle(
                fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 4.0),
            _buildBulletText(detail.spaceDetails),

            const SizedBox(height: 14.0),

            // Advertiser Profile Box
            advertiserWidget,

            const SizedBox(height: 14.0),

            // Bath & Kitchen details
            _buildBulletText(detail.bathAndKitchenDetails),

            const SizedBox(height: 14.0),

            // Subtitle: المميزات والمرافق
            const Text(
              'المميزات والمرافق',
              style: TextStyle(
                fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 6.0),
            ...detail.featuresList.map((feature) => _buildBulletText(feature)),
          ],

          const SizedBox(height: 14.0),

          // Expand / Collapse Action
          Center(
            child: InkWell(
              onTap: onToggleExpand,
              borderRadius: AppRadii.sm,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpanded ? 'إخفاء' : 'إظهار التفاصيل',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: PropertyDescriptionCardLayout.bodyFontSize,
                color: AppColors.lightTextPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
