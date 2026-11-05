import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/contractor_project_banner_model.dart';
import 'contractor_projects_banner_layout.dart';

class ContractorProjectsBanner extends StatelessWidget {
  final ContractorProjectBannerModel banner;
  final VoidCallback? onRequestQuoteTap;

  const ContractorProjectsBanner({
    super.key,
    required this.banner,
    this.onRequestQuoteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: ContractorProjectsBannerLayout.minHeight,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(ContractorProjectsBannerLayout.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(ContractorProjectsBannerLayout.borderRadius),
          ),
          child: Stack(
            children: [
              // Image Background
              Positioned.fill(
                child: SafeNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.business_center_rounded,
                ),
              ),

              // Dark Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.black.withValues(alpha: 0.90),
                      ],
                    ),
                  ),
                ),
              ),

              // Text & CTA Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6.0),

                    Text(
                      banner.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 14.0),

                    // White CTA Button "اطلب مقايسة مخصصة"
                    ElevatedButton(
                      onPressed: onRequestQuoteTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.neutral,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 9.0,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.lg,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.assignment_outlined,
                            size: 18.0,
                            color: AppColors.neutral,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            banner.ctaText,
                            style: const TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
