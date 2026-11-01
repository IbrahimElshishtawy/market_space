import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/market_widgets/safe_network_image.dart';
import '../../data/models/ac_service_item_model.dart';
import 'ac_services_list_layout.dart';

class AcServiceCard extends StatelessWidget {
  final AcServiceItemModel service;
  final VoidCallback? onTap;
  final VoidCallback? onBookTap;

  const AcServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(
          AcServicesListLayout.borderRadius,
        ),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AcServicesListLayout.borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Right Image (Start in RTL)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SafeNetworkImage(
                  imageUrl: service.imageUrl,
                  width: AcServicesListLayout.imageSize,
                  height: AcServicesListLayout.imageSize,
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.ac_unit_rounded,
                ),
              ),

              const SizedBox(width: 10.0),

              // 2. Center Content: Title, Description, Rating & Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14.0,
                          color: Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${service.rating.toStringAsFixed(1)} (+${service.reviewsCount})',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(
                          Icons.access_time_rounded,
                          size: 13.0,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.neutralLight,
                        ),
                        const SizedBox(width: 2.0),
                        Text(
                          '${service.durationMinutes} دقيقة',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // 3. Left Actions: Book Button & Price (End in RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Book Button "احجز الآن"
                  InkWell(
                    onTap: onBookTap,
                    borderRadius: AppRadii.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimary : AppColors.neutral,
                        borderRadius: AppRadii.md,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12.0,
                            color: isDark ? AppColors.darkOnPrimary : Colors.white,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'احجز الآن',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkOnPrimary : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // Price
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 12.0,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 3.0),
                      Text(
                        service.priceText,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
