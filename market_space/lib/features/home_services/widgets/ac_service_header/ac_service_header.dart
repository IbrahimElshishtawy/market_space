import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import 'ac_service_header_layout.dart';

class AcServiceHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final String title;
  final String subtitle;

  const AcServiceHeader({
    super.key,
    this.onBackTap,
    this.title = 'صيانة وتركيب التكييفات',
    this.subtitle =
        'خدمات فك، تركيب، وتنظيف شامل مع ضمان فنيين معتمدين بأسرع استجابة.',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AcServiceHeaderLayout.horizontalPadding,
        vertical: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Back Button & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AcServiceHeaderLayout.titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              InkWell(
                onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                borderRadius: AppRadii.full,
                child: Container(
                  width: AcServiceHeaderLayout.backButtonSize,
                  height: AcServiceHeaderLayout.backButtonSize,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.0,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6.0),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AcServiceHeaderLayout.subtitleFontSize,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
