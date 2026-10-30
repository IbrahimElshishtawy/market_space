import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/ac_service_item_model.dart';
import 'ac_service_card.dart';
import 'ac_services_list_layout.dart';

class AcServicesListSection extends StatelessWidget {
  final List<AcServiceItemModel> services;
  final ValueChanged<AcServiceItemModel>? onServiceTap;
  final ValueChanged<AcServiceItemModel>? onBookTap;
  final VoidCallback? onViewAllTap;

  const AcServicesListSection({
    super.key,
    required this.services,
    this.onServiceTap,
    this.onBookTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AcServicesListLayout.horizontalPadding,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Right "اختر الخدمة المناسبة", Left "عرض الكل"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'اختر الخدمة المناسبة',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral,
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          // Vertical list of cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AcServicesListLayout.itemSpacing),
            itemBuilder: (context, index) {
              final service = services[index];
              return AcServiceCard(
                service: service,
                onTap: () => onServiceTap?.call(service),
                onBookTap: () => onBookTap?.call(service),
              );
            },
          ),
        ],
      ),
    );
  }
}
