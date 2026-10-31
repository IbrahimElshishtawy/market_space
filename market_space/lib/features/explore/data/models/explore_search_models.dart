import 'package:flutter/material.dart';

enum SectorType {
  all('all', 'الكل', Icons.apps_rounded),
  realEstate('real_estate', 'العقارات', Icons.business_rounded),
  cars('cars', 'السيارات', Icons.directions_car_rounded),
  fashion('fashion', 'الملابس والأزياء', Icons.checkroom_rounded),
  buildingMaterials('building_materials', 'مواد البناء', Icons.foundation_rounded),
  services('services', 'الخدمات المنزلية', Icons.build_rounded),
  homeAppliances('home_appliances', 'الأجهزة المنزلية', Icons.kitchen_rounded);

  final String id;
  final String titleAr;
  final IconData icon;

  const SectorType(this.id, this.titleAr, this.icon);

  static SectorType fromId(String id) {
    return SectorType.values.firstWhere(
      (element) => element.id == id,
      orElse: () => SectorType.all,
    );
  }
}

class ExploreSearchResultItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String sectorId;
  final String sectorName;
  final double? price;
  final String? priceUnit;
  final String resultType; // 'عقار', 'مادة بناء', 'خدمة', 'جهاز منزلي'
  final bool isAvailable;
  final double? rating;
  final String targetRoute;

  const ExploreSearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.sectorId,
    required this.sectorName,
    this.price,
    this.priceUnit,
    required this.resultType,
    this.isAvailable = true,
    this.rating,
    required this.targetRoute,
  });

  String get formattedPrice {
    if (price == null) return 'حسب الطلب';
    final unit = priceUnit != null ? ' $priceUnit' : ' ج.م';
    return '${price!.toStringAsFixed(0)}$unit';
  }
}

class ExploreSubcategoryItem {
  final String id;
  final String title;
  final String sectorId;
  final String targetRoute;

  const ExploreSubcategoryItem({
    required this.id,
    required this.title,
    required this.sectorId,
    required this.targetRoute,
  });
}

class ExploreSectorCategoryItem {
  final String sectorId;
  final String sectorTitle;
  final IconData icon;
  final Color themeColor;
  final String targetRoute;
  final List<ExploreSubcategoryItem> subcategories;

  const ExploreSectorCategoryItem({
    required this.sectorId,
    required this.sectorTitle,
    required this.icon,
    required this.themeColor,
    required this.targetRoute,
    required this.subcategories,
  });
}

class DiscoveryCardItem {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badgeText;
  final String sectorId;
  final String sectorName;
  final double? price;
  final double? rating;
  final String targetRoute;

  const DiscoveryCardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badgeText,
    required this.sectorId,
    required this.sectorName,
    this.price,
    this.rating,
    required this.targetRoute,
  });
}
