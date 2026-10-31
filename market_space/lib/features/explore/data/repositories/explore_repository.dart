import 'package:flutter/material.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/storage/preferences_service.dart';
import '../models/explore_search_models.dart';

abstract class ExploreRepository {
  Future<List<ExploreSearchResultItem>> search(String query, {SectorType sector = SectorType.all});
  Future<List<String>> getRecentSearches();
  Future<void> addRecentSearch(String query);
  Future<void> removeRecentSearch(String query);
  Future<void> clearRecentSearches();
  List<String> getPopularSearches();
  List<ExploreSectorCategoryItem> getMainCategories();
  List<DiscoveryCardItem> getMostRequested();
  List<DiscoveryCardItem> getLatestAdditions();
  List<DiscoveryCardItem> getCurrentOffers();
}

class ExploreRepositoryImpl implements ExploreRepository {
  final PreferencesService? preferencesService;
  static const String _recentSearchesKey = 'explore_recent_searches_list';

  ExploreRepositoryImpl({this.preferencesService});

  @override
  Future<List<String>> getRecentSearches() async {
    if (preferencesService == null) {
      return ['تكييف', 'حديد عز', 'شقة للبيع بطنطا', 'صيانة غسالات'];
    }
    final raw = preferencesService!.getStringList(_recentSearchesKey);
    if (raw == null || raw.isEmpty) {
      return ['تكييف', 'حديد عز', 'شقة للبيع بطنطا', 'صيانة غسالات'];
    }
    return raw;
  }

  @override
  Future<void> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final current = await getRecentSearches();
    final updated = [clean, ...current.where((e) => e != clean)].take(8).toList();
    await preferencesService?.setStringList(_recentSearchesKey, updated);
  }

  @override
  Future<void> removeRecentSearch(String query) async {
    final current = await getRecentSearches();
    final updated = current.where((e) => e != query).toList();
    await preferencesService?.setStringList(_recentSearchesKey, updated);
  }

  @override
  Future<void> clearRecentSearches() async {
    await preferencesService?.remove(_recentSearchesKey);
  }

  @override
  List<String> getPopularSearches() {
    return [
      'تكييف كاريير 1.5 حصان',
      'حديد تسليح 12 مم',
      'فيلات للبيع في طنطا',
      'سباك منزلي',
      'أسمنت السويدي بورتلاندي',
      'ثلاجة شارب ديجيتال',
      'صيانة أجهزة منزلية',
      'طوب طفلي 25 سم',
    ];
  }

  @override
  List<ExploreSectorCategoryItem> getMainCategories() {
    return const [
      ExploreSectorCategoryItem(
        sectorId: 'real_estate',
        sectorTitle: 'العقارات',
        icon: Icons.business_rounded,
        themeColor: Color(0xFF1E293B),
        targetRoute: RouteNames.realEstate,
        subcategories: [
          ExploreSubcategoryItem(id: 're-sale', title: 'عقارات للبيع', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
          ExploreSubcategoryItem(id: 're-rent', title: 'عقارات للإيجار', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
          ExploreSubcategoryItem(id: 're-apt', title: 'شقق سكنية', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
          ExploreSubcategoryItem(id: 're-villa', title: 'فيلات ودوبلكس', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
          ExploreSubcategoryItem(id: 're-land', title: 'أراضٍ معتمدة', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
          ExploreSubcategoryItem(id: 're-comm', title: 'وحدات تجارية', sectorId: 'real_estate', targetRoute: RouteNames.realEstate),
        ],
      ),
      ExploreSectorCategoryItem(
        sectorId: 'building_materials',
        sectorTitle: 'مواد البناء',
        icon: Icons.foundation_rounded,
        themeColor: Color(0xFFD97706),
        targetRoute: RouteNames.buildingMaterials,
        subcategories: [
          ExploreSubcategoryItem(id: 'bm-steel', title: 'حديد التسليح', sectorId: 'building_materials', targetRoute: RouteNames.steelRebarListing),
          ExploreSubcategoryItem(id: 'bm-cement', title: 'الأسمنت البورتلاندي', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-brick', title: 'الطوب الأحمر والطفلي', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-sand', title: 'الرمل والسن والزلط', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-plumbing', title: 'تأسيس السباكة', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-electric', title: 'الكابلات والكهرباء', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-insulation', title: 'العزل المائي والحراري', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
          ExploreSubcategoryItem(id: 'bm-paint', title: 'الدهانات والخامات', sectorId: 'building_materials', targetRoute: RouteNames.buildingMaterialsCategories),
        ],
      ),
      ExploreSectorCategoryItem(
        sectorId: 'services',
        sectorTitle: 'الخدمات المنزلية',
        icon: Icons.build_rounded,
        themeColor: Color(0xFFEA580C),
        targetRoute: RouteNames.homeServices,
        subcategories: [
          ExploreSubcategoryItem(id: 'hs-ac', title: 'صيانة التكييفات', sectorId: 'services', targetRoute: RouteNames.acServiceDetail),
          ExploreSubcategoryItem(id: 'hs-plumb', title: 'السباكة والصحي', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-elec', title: 'الكهرباء والإنارة', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-paint', title: 'النقاشة والدهانات', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-clean', title: 'النظافة والتعقيم', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-appliance', title: 'صيانة الأجهزة', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-carpenter', title: 'النجارة والأبواب', sectorId: 'services', targetRoute: RouteNames.homeServices),
          ExploreSubcategoryItem(id: 'hs-pest', title: 'مكافحة الحشرات', sectorId: 'services', targetRoute: RouteNames.homeServices),
        ],
      ),
      ExploreSectorCategoryItem(
        sectorId: 'home_appliances',
        sectorTitle: 'الأجهزة المنزلية',
        icon: Icons.kitchen_rounded,
        themeColor: Color(0xFF0284C7),
        targetRoute: RouteNames.homeAppliances,
        subcategories: [
          ExploreSubcategoryItem(id: 'ha-fridge', title: 'الثلاجات والديب فريزر', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
          ExploreSubcategoryItem(id: 'ha-washer', title: 'الغسالات الأوتوماتيك', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
          ExploreSubcategoryItem(id: 'ha-ac', title: 'التكييفات والمبردات', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
          ExploreSubcategoryItem(id: 'ha-tv', title: 'الشاشات والتلفزيونات', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
          ExploreSubcategoryItem(id: 'ha-cooker', title: 'البوتاجازات والأفران', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
          ExploreSubcategoryItem(id: 'ha-small', title: 'أجهزة المطبخ الصغيرة', sectorId: 'home_appliances', targetRoute: RouteNames.homeAppliances),
        ],
      ),
    ];
  }

  @override
  Future<List<ExploreSearchResultItem>> search(
    String query, {
    SectorType sector = SectorType.all,
  }) async {
    final clean = query.trim().toLowerCase();
    final allItems = _getAllCatalogItems();

    if (clean.isEmpty) {
      if (sector == SectorType.all) return allItems;
      return allItems.where((e) => e.sectorId == sector.id).toList();
    }

    return allItems.where((item) {
      final matchesSector = sector == SectorType.all || item.sectorId == sector.id;
      final matchesQuery = item.title.toLowerCase().contains(clean) ||
          item.subtitle.toLowerCase().contains(clean) ||
          item.resultType.toLowerCase().contains(clean) ||
          item.sectorName.toLowerCase().contains(clean);
      return matchesSector && matchesQuery;
    }).toList();
  }

  @override
  List<DiscoveryCardItem> getMostRequested() {
    return const [
      DiscoveryCardItem(
        id: 'disc-mr-1',
        title: 'شقة فاخرة تطل على شارع الجيش',
        subtitle: '185م² - تشطيب ألترا سوبر لوكس',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        badgeText: 'أكثر طلباً',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        price: 2450000,
        rating: 4.9,
        targetRoute: RouteNames.realEstateDetail,
      ),
      DiscoveryCardItem(
        id: 'disc-mr-2',
        title: 'حديد عز تسليح مشرشر 12 مم',
        subtitle: 'توريد مباشر من أرض المصنع',
        imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
        badgeText: 'مبيعات يومية عالية',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 39500,
        rating: 4.8,
        targetRoute: RouteNames.steelRebarListing,
      ),
      DiscoveryCardItem(
        id: 'disc-mr-3',
        title: 'صيانة وغسيل تكييف سبليت',
        subtitle: 'شحن فريون وتنظيف الفلاتر بالبخار',
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        badgeText: 'خدمة معتمدة',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        price: 350,
        rating: 4.9,
        targetRoute: RouteNames.acServiceDetail,
      ),
      DiscoveryCardItem(
        id: 'disc-mr-4',
        title: 'شاشة سامسونج 55 بوصة 4K Smart',
        subtitle: 'توفير فائق للطاقة وضمان عامين',
        imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1',
        badgeText: 'الأعلى تقييماً',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 18999,
        rating: 4.7,
        targetRoute: RouteNames.homeAppliances,
      ),
    ];
  }

  @override
  List<DiscoveryCardItem> getLatestAdditions() {
    return const [
      DiscoveryCardItem(
        id: 'disc-la-1',
        title: 'فيلا مستقلة بكمبوند الياسمين',
        subtitle: 'مساحة 400م² مع حديقة خاصة ومسبح',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        badgeText: 'جديد هذا الأسبوع',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        price: 6800000,
        rating: 5.0,
        targetRoute: RouteNames.realEstateDetail,
      ),
      DiscoveryCardItem(
        id: 'disc-la-2',
        title: 'أسمنت لافارج قاهر البحار عالي المقاومة',
        subtitle: 'شكارة 50 كجم مطابق للمواصفات القياسية',
        imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3',
        badgeText: 'وصل حديثاً',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 2650,
        rating: 4.7,
        targetRoute: RouteNames.buildingMaterialsCategories,
      ),
      DiscoveryCardItem(
        id: 'disc-la-3',
        title: 'غسالة إل جي 10 كجم بخار Direct Drive',
        subtitle: 'إلغاء الاهتزاز والضوضاء مع تجفيف 100%',
        imageUrl: 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1',
        badgeText: 'إصدار حديث',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 27500,
        rating: 4.8,
        targetRoute: RouteNames.homeAppliances,
      ),
    ];
  }

  @override
  List<DiscoveryCardItem> getCurrentOffers() {
    return const [
      DiscoveryCardItem(
        id: 'disc-off-1',
        title: 'خصم 15% على باكج صيانة التكييف السنوي',
        subtitle: 'يشمل 3 زيارات دورية مع قطع الغيار الأصلية',
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
        badgeText: 'خصم 15%',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        price: 850,
        rating: 4.9,
        targetRoute: RouteNames.acServiceDetail,
      ),
      DiscoveryCardItem(
        id: 'disc-off-2',
        title: 'تخفيض كاش على ثلاجة بيكو 450 لتر نو فروست',
        subtitle: 'تقنية Active Fresh Blue Light للحفاظ على الخضروات',
        imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5',
        badgeText: 'وفر 3,000 ج.م',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 24900,
        rating: 4.6,
        targetRoute: RouteNames.homeAppliances,
      ),
      DiscoveryCardItem(
        id: 'disc-off-3',
        title: 'خصم النقل المجاني عند طلب 50 طن حديد تسليح',
        subtitle: 'توصيل مجاني لكافة مدن الدلتا ومواقع العمل',
        imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
        badgeText: 'شحن مجاني',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 39500,
        rating: 4.9,
        targetRoute: RouteNames.steelRebarListing,
      ),
    ];
  }

  List<ExploreSearchResultItem> _getAllCatalogItems() {
    return const [
      // 1. Real Estate
      ExploreSearchResultItem(
        id: 'res-re-1',
        title: 'شقة فاخرة للبيع بشارع النادي',
        subtitle: 'طنطا - 165م² - 3 غرف ورسيبشن واسع',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        price: 2200000,
        resultType: 'عقار للبيع',
        isAvailable: true,
        rating: 4.9,
        targetRoute: RouteNames.realEstateDetail,
      ),
      ExploreSearchResultItem(
        id: 'res-re-2',
        title: 'دوبلكس راقي بحديقة خاصة للبيع',
        subtitle: 'المحلة الكبرى - 260م² - تشطيب كامل',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        price: 3850000,
        resultType: 'عقار للبيع',
        isAvailable: true,
        rating: 4.8,
        targetRoute: RouteNames.realEstateDetail,
      ),
      ExploreSearchResultItem(
        id: 'res-re-3',
        title: 'مكتب إداري للإيجار ببرج تجاري حديث',
        subtitle: 'طنطا - شارع البحر - 90م²',
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c',
        sectorId: 'real_estate',
        sectorName: 'العقارات',
        price: 15000,
        priceUnit: 'ج.م/شهر',
        resultType: 'عقار للإيجار',
        isAvailable: true,
        rating: 4.7,
        targetRoute: RouteNames.realEstateDetail,
      ),

      // 2. Building Materials
      ExploreSearchResultItem(
        id: 'res-bm-1',
        title: 'حديد عز تسليح عالي المقاومة 10 مم و 12 مم',
        subtitle: 'أطوال قياسية 12 متر - توريد جملة وتجزئة',
        imageUrl: 'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 39500,
        priceUnit: 'ج.م/طن',
        resultType: 'مادة بناء',
        isAvailable: true,
        rating: 4.9,
        targetRoute: RouteNames.steelRebarListing,
      ),
      ExploreSearchResultItem(
        id: 'res-bm-2',
        title: 'أسمنت السويدي البورتلاندي رتبة 42.5N',
        subtitle: 'شكاير 50 كجم - مناسب للخرسانات المسلحة',
        imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 2750,
        priceUnit: 'ج.م/طن',
        resultType: 'مادة بناء',
        isAvailable: true,
        rating: 4.8,
        targetRoute: RouteNames.buildingMaterialsCategories,
      ),
      ExploreSearchResultItem(
        id: 'res-bm-3',
        title: 'طوب طفلي أحمر مفرغ 25×12×6 سم',
        subtitle: 'ألف طوبة معتمدة عالية الصلابة للمباني',
        imageUrl: 'https://images.unsplash.com/photo-1590069261209-f8e9b8642343',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        price: 1800,
        priceUnit: 'ج.م/ألف',
        resultType: 'مادة بناء',
        isAvailable: true,
        rating: 4.7,
        targetRoute: RouteNames.buildingMaterialsCategories,
      ),

      // 3. Home Services
      ExploreSearchResultItem(
        id: 'res-hs-1',
        title: 'خدمات فك وتركيب وصيانة التكييف',
        subtitle: 'تنظيف شامل للوحدات الداخلية والخارجية وفحص الفريون',
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        price: 350,
        resultType: 'خدمة منزلية',
        isAvailable: true,
        rating: 4.9,
        targetRoute: RouteNames.acServiceDetail,
      ),
      ExploreSearchResultItem(
        id: 'res-hs-2',
        title: 'خدمة تأسيس وصيانة شبكات السباكة',
        subtitle: 'كشف التسريبات بالأجهزة الإلكترونية وصيانة خلاطات ومحابس',
        imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        price: 250,
        resultType: 'خدمة منزلية',
        isAvailable: true,
        rating: 4.8,
        targetRoute: RouteNames.homeServices,
      ),
      ExploreSearchResultItem(
        id: 'res-hs-3',
        title: 'أعمال نقاشة وتشطيب دهانات حديثة',
        subtitle: 'تأسيس معجون وتشطيب بأجود أنواع الدهانات البلاستيكية والقطيفة',
        imageUrl: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        price: 45,
        priceUnit: 'ج.م/متر²',
        resultType: 'خدمة منزلية',
        isAvailable: true,
        rating: 4.9,
        targetRoute: RouteNames.homeServices,
      ),

      // 4. Home Appliances
      ExploreSearchResultItem(
        id: 'res-ha-1',
        title: 'تكييف شارب 1.5 حصان بارد/ساخن إنفرتر',
        subtitle: 'خاصية البلازما كلاستر لتنقية الهواء - ضمان 5 سنوات العربي',
        imageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 28500,
        resultType: 'جهاز منزلي',
        isAvailable: true,
        rating: 4.9,
        targetRoute: RouteNames.homeAppliances,
      ),
      ExploreSearchResultItem(
        id: 'res-ha-2',
        title: 'ثلاجة إل جي 18 قدم نوفروست إنفرتر ذكية',
        subtitle: 'أبواب ستانلس ستيل مع نظام تبريد Door Cooling',
        imageUrl: 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 33500,
        resultType: 'جهاز منزلي',
        isAvailable: true,
        rating: 4.8,
        targetRoute: RouteNames.homeAppliances,
      ),
      ExploreSearchResultItem(
        id: 'res-ha-3',
        title: 'شاشة تورنيدو 50 بوصة 4K Smart TV',
        subtitle: 'نظام تشغيل أندرويد مع ريسيفر داخلي وريموت ماجيك',
        imageUrl: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        price: 14800,
        resultType: 'جهاز منزلي',
        isAvailable: true,
        rating: 4.7,
        targetRoute: RouteNames.homeAppliances,
      ),
    ];
  }
}
