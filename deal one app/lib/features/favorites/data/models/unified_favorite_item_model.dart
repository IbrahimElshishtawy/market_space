import 'package:flutter/material.dart';

enum FavoriteSectorFilter {
  all('all', 'الكل', Icons.favorite_rounded),
  realEstate('real_estate', 'العقارات', Icons.business_rounded),
  cars('cars', 'السيارات', Icons.directions_car_rounded),
  fashion('fashion', 'الملابس والأزياء', Icons.checkroom_rounded),
  buildingMaterials('building_materials', 'مواد البناء', Icons.foundation_rounded),
  services('services', 'الخدمات', Icons.build_rounded),
  homeAppliances('home_appliances', 'الأجهزة المنزلية', Icons.kitchen_rounded);

  final String id;
  final String label;
  final IconData icon;

  const FavoriteSectorFilter(this.id, this.label, this.icon);
}

class UnifiedFavoriteItem {
  final String favoriteId;
  final String itemId;
  final String sectorId;
  final String sectorName;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double? price;
  final String? priceUnit;
  final double? rating;
  final bool isAvailable;
  final String deepLinkRoute;
  final String? customPriceFormatted;
  final bool canAddToCart;
  final bool canBookService;

  const UnifiedFavoriteItem({
    required this.favoriteId,
    required this.itemId,
    required this.sectorId,
    required this.sectorName,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.price,
    this.priceUnit,
    this.customPriceFormatted,
    this.rating,
    this.isAvailable = true,
    required this.deepLinkRoute,
    this.canAddToCart = false,
    this.canBookService = false,
  });

  String get formattedPrice {
    if (customPriceFormatted != null) return customPriceFormatted!;
    if (price == null) return 'حسب الطلب';
    final unit = priceUnit != null ? ' $priceUnit' : ' ج.م';
    return '${price!.toStringAsFixed(0)}$unit';
  }
}
