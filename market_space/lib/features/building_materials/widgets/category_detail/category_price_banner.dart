import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/category_detail_model.dart';

class CategoryPriceBanner extends StatelessWidget {
  final CategoryDetailModel detail;
  final VoidCallback? onOrderTap;
  final VoidCallback? onPriceLogTap;

  const CategoryPriceBanner({
    super.key,
    required this.detail,
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
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
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
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  detail.bannerTitle,
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
                    Icons.architecture_rounded,
                    size: 16.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6.0),

            // Price & Trend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      detail.isTrendUp
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 16.0,
                      color: detail.isTrendUp
                          ? const Color(0xFFF97316)
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 3.0),
                    Text(
                      detail.bannerTrendText,
                      style: TextStyle(
                        color: detail.isTrendUp
                            ? const Color(0xFFF97316)
                            : const Color(0xFF10B981),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8.0),
                Text(
                  detail.bannerPriceText,
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4.0),

            // Subtitle
            Text(
              detail.bannerSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11.5,
              ),
            ),

            const SizedBox(height: 14.0),

            // Buttons Row
            Row(
              children: [
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
                          detail.priceLogCtaText,
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
                          Icons.arrow_back_rounded,
                          size: 16.0,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          detail.orderCtaText,
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
