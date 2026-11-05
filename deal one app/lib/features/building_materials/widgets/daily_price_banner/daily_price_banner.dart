import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/daily_price_banner_model.dart';
import 'daily_price_banner_layout.dart';

class DailyPriceBanner extends StatelessWidget {
  final DailyPriceBannerModel banner;
  final VoidCallback? onOrderTap;

  const DailyPriceBanner({super.key, required this.banner, this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        height: DailyPriceBannerLayout.bannerHeight,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(DailyPriceBannerLayout.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(DailyPriceBannerLayout.borderRadius),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: SafeNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.foundation_rounded,
                ),
              ),

              // Dark Overlay Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Badge "تحديث يومي"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: AppRadii.full,
                            border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                banner.badgeText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Main Title
                    Center(
                      child: Text(
                        banner.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4.0),

                    // Price & Subtitle
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${banner.priceText} ',
                              style: const TextStyle(
                                color: Color(0xFF38BDF8), // Cyan / light blue
                                fontSize: 15.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: '• ${banner.subtitle}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom Row: CTA Button & Indicator Dots
                    Row(
                      children: [
                        // CTA Button "اطلب كميتك" (Right in RTL)
                        ElevatedButton(
                          onPressed: onOrderTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.neutral,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 8.0,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadii.lg,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner.ctaText,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutral,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              const Icon(
                                Icons.inventory_2_rounded,
                                size: 16.0,
                                color: Color(0xFFD97706),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Carousel Indicator Dots (Left in RTL)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 18.0,
                              height: 7.0,
                              decoration: const BoxDecoration(
                                color: Color(0xFF38BDF8),
                                borderRadius: AppRadii.full,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            _buildDot(),
                            const SizedBox(width: 4.0),
                            _buildDot(),
                            const SizedBox(width: 4.0),
                            _buildDot(),
                          ],
                        ),
                      ],
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

  Widget _buildDot() {
    return Container(
      width: 7.0,
      height: 7.0,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
