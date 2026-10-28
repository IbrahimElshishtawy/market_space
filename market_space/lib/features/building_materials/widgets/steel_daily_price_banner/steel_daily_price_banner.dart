import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/steel_daily_price_model.dart';
import 'steel_daily_price_banner_layout.dart';

class SteelDailyPriceBanner extends StatelessWidget {
  final SteelDailyPriceModel dailyPrice;
  final VoidCallback? onOrderTap;
  final VoidCallback? onPriceLogTap;

  const SteelDailyPriceBanner({
    super.key,
    required this.dailyPrice,
    this.onOrderTap,
    this.onPriceLogTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark navy
          borderRadius: const BorderRadius.all(
            Radius.circular(SteelDailyPriceBannerLayout.borderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Title + Gold Coin Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dailyPrice.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.currency_bitcoin_rounded,
                    size: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6.0),

            // Middle Row: Price & Trend Badge "↗ +1.5%"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 16.0,
                      color: Color(0xFFF97316), // Orange
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      dailyPrice.trendText,
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Text(
                  dailyPrice.priceText,
                  style: const TextStyle(
                    color: Color(0xFFF59E0B), // Amber gold
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4.0),

            // Subtitle: "شامل النقل والتنزيل للموقع - تحديث يومي"
            Text(
              dailyPrice.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11.5,
              ),
            ),

            const SizedBox(height: 14.0),

            // Bottom CTA Buttons Row: "سجل الأسعار" & "اطلب كميتك"
            Row(
              children: [
                // Left CTA: "سجل الأسعار"
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPriceLogTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 9.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.lg,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 16.0,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          dailyPrice.priceLogCtaText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10.0),

                // Right CTA: "اطلب كميتك"
                Expanded(
                  child: ElevatedButton(
                    onPressed: onOrderTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.neutral,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 9.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.lg,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded, // Arrow pointing left in RTL
                          size: 16.0,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          dailyPrice.orderCtaText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral,
                          ),
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
    );
  }
}
