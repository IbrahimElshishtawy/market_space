import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/ac_promo_banner_model.dart';
import 'ac_promo_banner_layout.dart';

class AcPromoBanner extends StatelessWidget {
  final AcPromoBannerModel banner;
  final VoidCallback? onCtaTap;

  const AcPromoBanner({super.key, required this.banner, this.onCtaTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AcPromoBannerLayout.horizontalPadding,
        vertical: 8.0,
      ),
      child: Container(
        height: AcPromoBannerLayout.bannerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AcPromoBannerLayout.borderRadius,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AcPromoBannerLayout.borderRadius,
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: SafeNetworkImage(
                  imageUrl: banner.imageUrl,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.ac_unit_rounded,
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.50),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top-right Tag (in RTL)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: AppRadii.full,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 13.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            banner.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Main Headline with Highlighted 15%
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          const TextSpan(text: 'خصم '),
                          TextSpan(
                            text: banner.discountHighlight,
                            style: const TextStyle(
                              color: Color(0xFFFBBF24), // Amber/Gold
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(
                            text: ' على جميع خدمات الصيانة والغسيل',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3.0),

                    // Subtitle
                    Text(
                      banner.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Bottom Row: CTA Button on Left in RTL
                    Row(
                      children: [
                        const Spacer(),
                        InkWell(
                          onTap: onCtaTap,
                          borderRadius: AppRadii.full,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppRadii.full,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  banner.ctaText,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                const SizedBox(width: 4.0),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14.0,
                                  color: AppColors.neutral,
                                ),
                              ],
                            ),
                          ),
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
}
