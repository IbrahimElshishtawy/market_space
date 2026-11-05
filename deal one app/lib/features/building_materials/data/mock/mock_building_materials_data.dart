import 'package:flutter/material.dart';

import '../models/building_material_category_model.dart';
import '../models/building_material_product_model.dart';
import '../models/contractor_project_banner_model.dart';
import '../models/daily_price_banner_model.dart';

class MockBuildingMaterialsData {
  static const DailyPriceBannerModel dailyPriceBanner = DailyPriceBannerModel(
    id: 'daily-banner-1',
    title: 'سعر طن الأسمنت اليوم',
    priceText: '2,850 ج.م / طن',
    subtitle: 'شامل النقل والتنزيل للموقع',
    ctaText: 'اطلب كميتك',
    badgeText: 'تحديث يومي',
    imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
  );

  static const List<BuildingMaterialCategoryModel> categories = [
    BuildingMaterialCategoryModel(
      id: 'cat-steel',
      title: 'حديد التسليح',
      icon: Icons.compress_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    BuildingMaterialCategoryModel(
      id: 'cat-cement',
      title: 'الأسمنت والمونة',
      icon: Icons.hardware_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    BuildingMaterialCategoryModel(
      id: 'cat-bricks',
      title: 'الطوب والبلوك',
      icon: Icons.grid_view_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    BuildingMaterialCategoryModel(
      id: 'cat-sand',
      title: 'الرمل والزلط',
      icon: Icons.landscape_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    BuildingMaterialCategoryModel(
      id: 'cat-insulation',
      title: 'مواد العزل',
      icon: Icons.roofing_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    BuildingMaterialCategoryModel(
      id: 'cat-tools',
      title: 'أدوات التأسيس',
      icon: Icons.construction_rounded,
      iconColor: Color(0xFF1E293B),
    ),
  ];

  static const List<BuildingMaterialProductModel> mostRequestedProducts = [
    BuildingMaterialProductModel(
      id: 'bm-steel-12',
      title: 'حديد تسليح 12مم - مصانع معتمدة',
      description: 'مطابق للمواصفات القياسية - تسليم الموقع',
      priceText: '38,500 ج.م / طن',
      rating: 4.7,
      categoryTag: 'حديد تسليح',
      imageUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
    ),
    BuildingMaterialProductModel(
      id: 'bm-cement-portland',
      title: 'أسمنت بورتلاندي ممتاز (50 كجم)',
      description: 'شكائر معتمدة - مقاومة عالية للرطوبة',
      priceText: '2,850 ج.م / طن',
      rating: 4.8,
      categoryTag: 'أسمنت ومونة',
      imageUrl: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f',
    ),
    BuildingMaterialProductModel(
      id: 'bm-hollow-block',
      title: 'طوب خرساني مفرغ (25×12×13 سم)',
      description: 'جودة ممتازة - توريد باللوري للموقع',
      priceText: '1,950 ج.م/ألف طوبة',
      rating: 4.7,
      categoryTag: 'طوب وبلوك',
      imageUrl: 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
    ),
    BuildingMaterialProductModel(
      id: 'bm-coarse-sand',
      title: 'رمل حرش ممتاز للخرسانة والمونة',
      description: 'خالي من الشوائب والطفلة - توريد بالنقلة',
      priceText: '350 ج.م / متر مكعب',
      rating: 4.9,
      categoryTag: 'رمل وزلط',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    ),
  ];

  static const ContractorProjectBannerModel
  contractorBanner = ContractorProjectBannerModel(
    id: 'contractor-banner-1',
    title: 'طلبات المشاريع والمقاولات الخاصة',
    subtitle:
        'احصل على أسعار تنافسية، توريد مباشر للموقع، وجدول دفعات مخصص لمشروعك',
    ctaText: 'اطلب مقايسة مخصصة',
    imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3',
  );
}
