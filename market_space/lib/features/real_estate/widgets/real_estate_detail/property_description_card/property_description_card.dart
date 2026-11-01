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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: AppRadii.lg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
          Text(
            'الوصف التفصيلي',
            style: TextStyle(
              fontSize: PropertyDescriptionCardLayout.headerFontSize,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
            ),
          ),

          const SizedBox(height: 12.0),

          // Subtitle: عن الشقة
          Text(
            'عن الشقة:',
            style: TextStyle(
              fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            detail.aboutProperty,
            style: TextStyle(
              fontSize: PropertyDescriptionCardLayout.bodyFontSize,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
              height: 1.5,
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 14.0),

            // Subtitle: تفاصيل المساحة والتقسيم
            Text(
              'تفاصيل المساحة والتقسيم:',
              style: TextStyle(
                fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
              ),
            ),
            const SizedBox(height: 4.0),
            _buildBulletText(detail.spaceDetails, isDark),

            const SizedBox(height: 14.0),

            // Advertiser Profile Box
            advertiserWidget,

            const SizedBox(height: 14.0),

            // Bath & Kitchen details
            _buildBulletText(detail.bathAndKitchenDetails, isDark),

            const SizedBox(height: 14.0),

            // Subtitle: المميزات والمرافق
            Text(
              'المميزات والمرافق',
              style: TextStyle(
                fontSize: PropertyDescriptionCardLayout.subHeaderFontSize,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
              ),
            ),
            const SizedBox(height: 6.0),
            ...detail.featuresList.map((feature) => _buildBulletText(feature, isDark)),
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
                      style: TextStyle(
                        color: isDark ? AppColors.darkPrimary : AppColors.primary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
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

  Widget _buildBulletText(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: PropertyDescriptionCardLayout.bodyFontSize,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
