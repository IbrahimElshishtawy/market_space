import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../data/models/real_estate_listing_model.dart';

class RealEstateCardSpecs extends StatelessWidget {
  final RealEstateListingModel item;

  const RealEstateCardSpecs({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row: Rooms, Finish, Floor
        Row(
          children: [
            Expanded(
              child: _buildSpecChip(
                icon: Icons.bed_rounded,
                label: '${item.bedsCount} غرفة',
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildSpecChip(
                icon: Icons.brush_outlined,
                label: item.finishType,
              ),
            ),
            const SizedBox(width: 6.0),
            Expanded(
              child: _buildSpecChip(
                icon: Icons.apartment_rounded,
                label: item.floorLevel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        // Bottom Row: Area, Baths
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: _buildSpecChip(
                icon: Icons.bathtub_outlined,
                label: '${item.bathsCount} حمام',
              ),
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: _buildSpecChip(
                icon: Icons.aspect_ratio_rounded,
                label: '${item.areaM2} م²',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.sm,
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral,
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          Icon(icon, size: 14.0, color: AppColors.neutral),
        ],
      ),
    );
  }
}
