import 'package:flutter/material.dart';

import 'package:market_space/core/theme/app_colors.dart';
import 'package:market_space/core/theme/app_radii.dart';
import 'package:market_space/features/real_estate/reels/data/models/reel_model.dart';

import 'reel_owner_header.dart';

class ReelPropertyOverlay extends StatelessWidget {
  final ReelModel reel;
  final VoidCallback? onPropertyDetailsTap;
  final VoidCallback? onContactOwnerTap;

  const ReelPropertyOverlay({
    super.key,
    required this.reel,
    this.onPropertyDetailsTap,
    this.onContactOwnerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        bottom: 16.0,
        left: 60.0, // Reserves clear margin for side ReelActionsBar
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
            Colors.black.withValues(alpha: 0.88),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Owner Header Bar
          ReelOwnerHeader(
            advertiser: reel.advertiser,
            onContactTap: onContactOwnerTap,
          ),

          const SizedBox(height: 10.0),

          // Price Tag + Property Type Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.sm,
                ),
                child: Text(
                  reel.priceFormatted +
                      (reel.pricePeriod != null
                          ? ' / ${reel.pricePeriod}'
                          : ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadii.sm,
                ),
                child: Text(
                  reel.propertyType.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6.0),

          // Property Title
          Text(
            reel.propertyTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 4.0),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Colors.white70,
                size: 14.0,
              ),
              const SizedBox(width: 2.0),
              Expanded(
                child: Text(
                  reel.propertyLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8.0),

          // Property Specs Chips (Bed, Bath, Area)
          Row(
            children: [
              _buildSpecChip(Icons.bed_rounded, '${reel.bedsCount} غرفة'),
              const SizedBox(width: 6.0),
              _buildSpecChip(Icons.bathtub_outlined, '${reel.bathsCount} حمام'),
              const SizedBox(width: 6.0),
              _buildSpecChip(Icons.aspect_ratio_rounded, '${reel.areaM2} م²'),
              const SizedBox(width: 6.0),
              _buildSpecChip(Icons.brush_outlined, reel.finishType),
            ],
          ),

          if (reel.caption.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            Text(
              reel.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ],

          const SizedBox(height: 12.0),

          // Conversion CTA Button ("عرض تفاصيل العقار")
          SizedBox(
            width: double.infinity,
            height: 42.0,
            child: ElevatedButton.icon(
              onPressed: onPropertyDetailsTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
                elevation: 2.0,
              ),
              icon: const Icon(Icons.home_work_rounded, size: 18.0),
              label: const Text(
                'عرض تفاصيل العقار الكاملة',
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.0),
          const SizedBox(width: 3.0),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
