import 'package:flutter/material.dart';

import '../models/appliance_category_detail_model.dart';
import '../models/appliance_category_model.dart';
import '../models/appliance_hero_banner_model.dart';
import '../models/appliance_product_model.dart';

class MockHomeAppliancesData {
  static const ApplianceHeroBannerModel heroBanner = ApplianceHeroBannerModel(
    id: 'banner-appliances-1',
    discountTag: 'عرض اليوم',
    countdownText: 'ينتهي خلال 02 س : 14 د : 38 ث',
    title: 'خصم يصل إلى 30% على الأجهزة الكهربائية',
    subtitle: 'أحدث الموديلات السمارت بأسعار زمان وتوصيل لجميع مناطق طنطا',
    ctaText: 'تسوق الآن',
    imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6',
  );

  static const List<ApplianceCategoryModel> categories = [
    ApplianceCategoryModel(
      id: 'cat-tv',
      title: 'شاشات وتلفزيونات',
      iconData: Icons.tv_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-fridge',
      title: 'ثلاجات وديب فريزر',
      iconData: Icons.kitchen_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-washer',
      title: 'غسالات ومجففات',
      iconData: Icons.local_laundry_service_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-stove',
      title: 'بوتاجازات وأفران',
      iconData: Icons.countertops_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-ac',
      title: 'تكييفات ومراوح',
      iconData: Icons.ac_unit_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-kitchen',
      title: 'أجهزة المطبخ',
      iconData: Icons.blender_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-small',
      title: 'أجهزة صغيرة',
      iconData: Icons.coffee_maker_rounded,
    ),
    ApplianceCategoryModel(
      id: 'cat-heater',
      title: 'سخانات وفلاتر',
      iconData: Icons.water_drop_rounded,
    ),
  ];

  static const List<ApplianceProductModel> products = [
    ApplianceProductModel(
      id: 'prod-1',
      brandName: 'TOSHIBA',
      badgeText: 'الأكثر مبيعاً',
      title: 'ثلاجة توشيبا نوفروست',
      subtitle: '395 لتر - 2 باب',
      priceFormatted: '32,500 ج.م',
      oldPriceFormatted: '36,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,350 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a',
      categoryKey: 'cat-fridge',
    ),
    ApplianceProductModel(
      id: 'prod-2',
      brandName: 'SAMSUNG',
      badgeText: '4K UHD',
      title: 'شاشة سامسونج 55',
      subtitle: 'ريسيفر داخلي - بدون إطار',
      priceFormatted: '24,500 ج.م',
      oldPriceFormatted: '27,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,020 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'prod-3',
      brandName: 'carrier',
      badgeText: 'بارد / ساخن',
      title: 'تكييف كاريير أوبتيماكس',
      subtitle: 'تكنولوجيا انفرتر - 1.5 حصان',
      priceFormatted: '34,500 ج.م',
      oldPriceFormatted: '37,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,450 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
      categoryKey: 'cat-ac',
    ),
    ApplianceProductModel(
      id: 'prod-4',
      brandName: 'DeLonghi',
      badgeText: 'إيطالي الأصلي',
      title: 'ماكينة إسبريسو ديلونجي',
      subtitle: '15 بار - صانع رغوة الحليب',
      priceFormatted: '8,450 ج.م',
      oldPriceFormatted: '9,800 ج.م',
      monthlyInstallmentFormatted: 'قسط من 350 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1517668808822-9e428824603b',
      categoryKey: 'cat-small',
    ),
  ];

  static const List<ApplianceProductModel> tvCategoryProducts = [
    ApplianceProductModel(
      id: 'tv-samsung-55',
      brandName: 'SAMSUNG',
      badgeText: '4K UHD',
      title: 'شاشة سامسونج 55 بوصة Smart 4K',
      subtitle: 'ريسيفر داخلي • 4K Crystal • بدون إطار',
      priceFormatted: '24,500 ج.م',
      oldPriceFormatted: '27,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,020 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-lg-65',
      brandName: 'LG',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة إل جي (LG) 65 بوصة OLED 4K',
      subtitle: 'webOS • AI معالج • OLED 120Hz',
      priceFormatted: '42,000 ج.م',
      oldPriceFormatted: '46,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,750 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1577979749830-f1d742b96791',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-toshiba-43',
      brandName: 'TOSHIBA',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة توشيبا 43 بوصة Smart FHD',
      subtitle: 'Dolby • FHD Smart • ريسيفر داخلي',
      priceFormatted: '14,800 ج.م',
      oldPriceFormatted: '16,500 ج.م',
      monthlyInstallmentFormatted: 'قسط من 610 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-tornado-50',
      brandName: 'TORNADO',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة تورنيدو 50 بوصة Smart 4K',
      subtitle: 'تصميم عصري • Google TV • 4K Smart',
      priceFormatted: '17,500 ج.م',
      oldPriceFormatted: '19,300 ج.م',
      monthlyInstallmentFormatted: 'قسط من 730 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1509281373149-e957c6296406',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-sony-55',
      brandName: 'SONY',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة سوني (Sony) 55 بوصة Bravia 4K',
      subtitle: 'Google TV • X1 معالج • 4K Bravia',
      priceFormatted: '31,000 ج.م',
      oldPriceFormatted: '34,500 ج.م',
      monthlyInstallmentFormatted: 'قسط من 1,290 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1567690187548-f07b1d7bf5a9',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-jac-32',
      brandName: 'J.A.C',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة جاك (JAC) 32 بوصة LED HD',
      subtitle: 'HDMI/USB • مداخل • اقتصادية',
      priceFormatted: '6,900 ج.م',
      oldPriceFormatted: '7,600 ج.م',
      monthlyInstallmentFormatted: 'قسط من 290 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1461151304267-38535e780c79',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-sharp-55',
      brandName: 'SHARP',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة شارب 55 بوصة Smart 4K',
      subtitle: 'Harman Kardon • صوت • 4K Android TV',
      priceFormatted: '22,200 ج.م',
      oldPriceFormatted: '24,800 ج.م',
      monthlyInstallmentFormatted: 'قسط من 920 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1593784991095-a205069470b6',
      categoryKey: 'cat-tv',
    ),
    ApplianceProductModel(
      id: 'tv-fresh-43',
      brandName: 'FRESH',
      badgeText: 'الأكثر مبيعاً',
      title: 'شاشة فريش 43 بوصة Smart FHD',
      subtitle: 'حماية أطفال • نحيفة • FHD Android',
      priceFormatted: '12,500 ج.م',
      oldPriceFormatted: '14,000 ج.م',
      monthlyInstallmentFormatted: 'قسط من 520 ج.م / شهر',
      imageUrl: 'https://images.unsplash.com/photo-1522869635100-9f4c5e86aa37',
      categoryKey: 'cat-tv',
    ),
  ];

  static ApplianceCategoryDetailModel getCategoryDetail(String categoryId) {
    final cat = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => categories.first,
    );

    return ApplianceCategoryDetailModel(
      id: cat.id,
      title: cat.title,
      subtitle: 'أحدث شاشات Smart & 4K بأحدث التقنيات وأنسب باقات التقسيط لك',
      filterChips: const ['الكل', 'السعر ˅', 'الحجم ˅', 'الماركة ˅'],
    );
  }
}
