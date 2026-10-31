import 'package:flutter/material.dart';

import '../models/hero_banner_data.dart';
import '../models/home_category_data.dart';
import '../models/home_header_data.dart';
import '../models/home_nav_item_data.dart';
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
      ctaLabel: 'تصفح العقارات',
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
    ),
    HeroBannerData(
      id: 'hero-2',
      badgeText: 'سوق السيارات',
      title: 'سيارات كسر زيرو وضمان',
      subtitle: 'أفضل العروض والأسعار مع فحص شامل ومعتمد',
      ctaLabel: 'استكشف السيارات',
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
    ),
    HeroBannerData(
      id: 'hero-3',
      badgeText: 'أزياء وموضة',
      title: 'أرقى صيحات الموضة والأزياء',
      subtitle: 'خصومات تصل إلى %40 مع توصيل سريع ومعاينة مجانية',
      ctaLabel: 'تسوق الأزياء',
      imageUrl: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d',
    ),
    HeroBannerData(
      id: 'hero-4',
      badgeText: 'خدمات منزلية',
      title: 'فنيون محترفون لخدمتك',
      subtitle: 'صيانة تكييفات، سباكة، كهرباء ونظافة بأعلى جودة',
      ctaLabel: 'اطلب خدمة',
      imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
    ),
    HeroBannerData(
      id: 'hero-5',
      badgeText: 'مواد بناء وتشييد',
      title: 'حديد وأسمنت بأسعار اليوم',
      subtitle: 'توريد مباشر من المصنع لموقع مشروعك',
      ctaLabel: 'عرض الأسعار',
      imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186c5f7',
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
    HomeCategoryData(
      id: 'cat-cars',
      title: 'سيارات',
      icon: Icons.directions_car_rounded,
      iconColor: Color(0xFFDC2626),
    ),
    HomeCategoryData(
      id: 'cat-fashion',
      title: 'ملابس وأزياء',
      icon: Icons.checkroom_rounded,
      iconColor: Color(0xFF9333EA),
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
    HomeServiceData(
      id: 'service-3',
      badgeText: 'سباكة وصحي',
      title: 'تركيب وصيانة سباكة',
      subtitle: 'كشف تسريبات وصيانة شبكات المياه',
      priceText: 'يبدأ من 200 ج.م',
      rating: 4.8,
      avatarStackText: '+125',
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
    ),
    HomeServiceData(
      id: 'service-4',
      badgeText: 'كهرباء وإنارة',
      title: 'تأسيس وصيانة كهرباء',
      subtitle: 'تشطيب كهرباء وتركيب لوحات الإنارة',
      priceText: 'يبدأ من 300 ج.م',
      rating: 4.9,
      avatarStackText: '+95',
      imageUrl: 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4',
    ),
    HomeServiceData(
      id: 'service-5',
      badgeText: 'نجارة وديكور',
      title: 'أعمال نجارة وأبواب',
      subtitle: 'تفصيل وصيانة الأبواب والمطابخ الخشبية',
      priceText: 'السعر حسب المعاينة',
      rating: 4.7,
      avatarStackText: '+80',
      imageUrl: 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126',
    ),
  ];

  static const List<HomeNavItemData> navItems = [
    HomeNavItemData(
      id: 'home',
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    HomeNavItemData(
      id: 'explore',
      label: 'استكشف',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    HomeNavItemData(
      id: 'orders',
      label: 'طلباتي',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    HomeNavItemData(
      id: 'favorites',
      label: 'المفضلة',
      icon: Icons.favorite_border_rounded,
      activeIcon: Icons.favorite_rounded,
    ),
    HomeNavItemData(
      id: 'profile',
      label: 'حسابي',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    ),
  ];
}
