import 'package:flutter/material.dart';

import '../models/hero_banner_data.dart';
import '../models/home_category_data.dart';
import '../models/home_header_data.dart';
import '../models/home_service_data.dart';

class MockHomeData {
  static const HomeHeaderData headerData = HomeHeaderData(
    userName: 'مصطفي هيكل',
    location: 'الغربية - طنطا',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    unreadNotificationsCount: 1,
    cartItemsCount: 0,
  );

  static const List<HeroBannerData> heroBanners = [
    HeroBannerData(
      id: 'hero-1',
      badgeText: 'عقارات موثوقة',
      title: 'احجز بيت أحلامك',
      subtitle: 'آلاف العقارات للبيع والإيجار بدون وسيط',
      ctaLabel: 'تصفح الآن',
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
    ),
    HeroBannerData(
      id: 'hero-2',
      badgeText: 'خدمات ممتازة',
      title: 'جدد منزلك اليوم',
      subtitle: 'أفضل مهندسي الديكور والخدمات في طنطا',
      ctaLabel: 'اكتشف المزيد',
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    ),
  ];

  static const List<HomeCategoryData> categories = [
    HomeCategoryData(
      id: 'cat-real-estate',
      title: 'عقارات',
      icon: Icons.business_rounded,
      iconColor: Color(0xFF1E293B),
    ),
    HomeCategoryData(
      id: 'cat-appliances',
      title: 'أجهزة منزلية',
      icon: Icons.kitchen_rounded,
      iconColor: Color(0xFF0284C7),
    ),
    HomeCategoryData(
      id: 'cat-services',
      title: 'خدمات منزلية',
      icon: Icons.build_rounded,
      iconColor: Color(0xFFEA580C),
    ),
    HomeCategoryData(
      id: 'cat-building-materials',
      title: 'مواد بناء',
      icon: Icons.foundation_rounded,
      iconColor: Color(0xFFD97706),
    ),
  ];

  static const List<HomeServiceData> mostRequestedServices = [
    HomeServiceData(
      id: 'service-1',
      badgeText: 'نقاشة ودهانات',
      title: 'صيانة وتنظيف تكييفات',
      subtitle: 'تبريد أسرع وصيانة فورية',
      priceText: 'يبدأ من 250 ج.م',
      rating: 4.9,
      avatarStackText: '+115',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
    ),
    HomeServiceData(
      id: 'service-2',
      badgeText: 'مواد بناء وتأسيس',
      title: 'توريد أسمنت وبلوك',
      subtitle: 'خامات بناء بأفضل سعر',
      priceText: 'السعر حسب الكمية',
      rating: 4.9,
      avatarStackText: '+115',
      imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3',
    ),
  ];
}
