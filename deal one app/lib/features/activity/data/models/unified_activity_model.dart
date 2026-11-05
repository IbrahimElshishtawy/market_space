import 'package:flutter/material.dart';

enum ActivitySectorFilter {
  all('all', 'الكل', Icons.all_inbox_rounded),
  realEstate('real_estate', 'العقارات', Icons.business_rounded),
  cars('cars', 'السيارات', Icons.directions_car_rounded),
  fashion('fashion', 'الملابس والأزياء', Icons.checkroom_rounded),
  buildingMaterials('building_materials', 'مواد البناء', Icons.foundation_rounded),
  services('services', 'الخدمات المنزلية', Icons.build_rounded),
  homeAppliances('home_appliances', 'الأجهزة المنزلية', Icons.kitchen_rounded);

  final String id;
  final String label;
  final IconData icon;

  const ActivitySectorFilter(this.id, this.label, this.icon);
}

enum ActivityStatusGroup {
  all('all', 'الكل'),
  active('active', 'نشطة'),
  completed('completed', 'مكتملة'),
  cancelled('cancelled', 'ملغاة');

  final String id;
  final String label;

  const ActivityStatusGroup(this.id, this.label);
}

enum ActivityType {
  realEstateInquiry('طلب استفسار عقاري'),
  realEstateViewing('طلب معاينة عقار'),
  carTestDrive('طلب تجربة قيادة سيارة'),
  fashionOrder('طلب شراء ملابس وأزياء'),
  buildingMaterialSupply('أمر توريد مواد بناء'),
  serviceBooking('حجز خدمة منزلية'),
  applianceOrder('طلب شراء أجهزة منزلية');

  final String label;
  const ActivityType(this.label);
}

class UnifiedActivityItem {
  final String activityId;
  final String referenceNumber;
  final String sectorId;
  final String sectorName;
  final ActivityType activityType;
  final String title;
  final String subtitle;
  final String imageUrl;
  final DateTime date;
  final ActivityStatusGroup statusGroup;
  final String statusLabel;
  final Color statusColor;
  final double? price;
  final String? priceUnit;
  final String actionLabel;
  final String deepLinkRoute;
  final Map<String, String> details;

  const UnifiedActivityItem({
    required this.activityId,
    required this.referenceNumber,
    required this.sectorId,
    required this.sectorName,
    required this.activityType,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.date,
    required this.statusGroup,
    required this.statusLabel,
    required this.statusColor,
    this.price,
    this.priceUnit,
    required this.actionLabel,
    required this.deepLinkRoute,
    this.details = const {},
  });

  String get formattedPrice {
    if (price == null) return '';
    final unit = priceUnit != null ? ' $priceUnit' : ' ج.م';
    return '${price!.toStringAsFixed(0)}$unit';
  }
}
