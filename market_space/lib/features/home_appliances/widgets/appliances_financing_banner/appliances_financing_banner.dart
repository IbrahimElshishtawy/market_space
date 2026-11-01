import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import 'appliances_financing_banner_layout.dart';

class AppliancesFinancingBanner extends StatelessWidget {
  final VoidCallback? onKnowLimitTap;
  final String imageUrl;

  const AppliancesFinancingBanner({
    super.key,
    this.onKnowLimitTap,
    this.imageUrl = 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        height: AppliancesFinancingBannerLayout.bannerHeight,
        decoration: BoxDecoration(
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadii.lg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Kitchen Background Image
              SafeNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                fallbackIcon: Icons.kitchen_rounded,
              ),

              // 2. Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: 0.5),
                            AppColors.darkSurface.withValues(alpha: 0.85),
                            AppColors.darkSurface.withValues(alpha: 0.95),
                          ]
                        : [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.85),
                            Colors.white.withValues(alpha: 0.95),
                          ],
                  ),
                ),
              ),

              // 3. Top Badges (ValU / Aman & No Interest Tag)
              Positioned(
                top: 10.0,
                right: 10.0,
                left: 10.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Right: ValU / Aman Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A3A6),
                        borderRadius: AppRadii.sm,
                      ),
                      child: const Text(
                        'valu | أمان',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Left: No interest Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.neutral,
                        borderRadius: AppRadii.full,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.percent_rounded,
                            size: 11.0,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'تقسيط بدون فوائد',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Center Lightning Callout
              Positioned(
                top: 50.0,
                right: 12.0,
                left: 12.0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 16.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'موافقة خلال دقائق',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Bottom Text & CTA Button
              Positioned(
                bottom: 12.0,
                right: 12.0,
                left: 12.0,
                child: Column(
                  children: [
                    Text(
                      'قسط أجهزتك على 12 أو 24 شهر',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'أسهل إجراءات بالتعاون مع Valu وأمان',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // Button (اعرف لمتك ->)
                    InkWell(
                      onTap: onKnowLimitTap,
                      borderRadius: AppRadii.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPrimary : AppColors.neutral,
                          borderRadius: AppRadii.md,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'اعرف لمتك',
                              style: TextStyle(
                                color: isDark ? AppColors.darkOnPrimary : Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15.0,
                              color: isDark ? AppColors.darkOnPrimary : Colors.white,
                            ),
                          ],
                        ),
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
