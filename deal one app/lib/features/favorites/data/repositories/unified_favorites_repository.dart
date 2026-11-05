import 'package:market_space/features/real_estate/favorites/data/repositories/real_estate_favorites_repository.dart';

import '../../../../core/routing/route_names.dart';

import '../models/unified_favorite_item_model.dart';

abstract class UnifiedFavoritesRepository {
  Future<List<UnifiedFavoriteItem>> getFavorites({
    FavoriteSectorFilter sector = FavoriteSectorFilter.all,
    String? searchQuery,
  });

  Future<bool> removeFavorite(String itemId);
  Future<bool> addFavorite(UnifiedFavoriteItem item);
}

class UnifiedFavoritesRepositoryImpl implements UnifiedFavoritesRepository {
  final RealEstateFavoritesRepository realEstateFavoritesRepo;
  final List<UnifiedFavoriteItem> _inMemoryFavorites = [];

  UnifiedFavoritesRepositoryImpl({
    RealEstateFavoritesRepository? realEstateRepo,
  }) : realEstateFavoritesRepo =
           realEstateRepo ?? MockRealEstateFavoritesRepository() {
    _initMockFavorites();
  }

  void _initMockFavorites() {
    _inMemoryFavorites.addAll([
      // Building Materials
      const UnifiedFavoriteItem(
        favoriteId: 'fav-bm-1',
        itemId: 'bm-steel-12',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        title: 'حديد عز تسليح 12 مم',
        subtitle: 'المورد: شركة الدلتا لتجارة المعادن',
        imageUrl:
            'https://images.unsplash.com/photo-1504307651254-35680f356dfd',
        price: 39500,
        priceUnit: 'ج.م/طن',
        rating: 4.9,
        deepLinkRoute: RouteNames.steelRebarListing,
        canAddToCart: true,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-bm-2',
        itemId: 'bm-cement-swd',
        sectorId: 'building_materials',
        sectorName: 'مواد البناء',
        title: 'أسمنت السويدي البورتلاندي 42.5N',
        subtitle: 'أعلى مقاومة للخرسانة المسلحة',
        imageUrl:
            'https://images.unsplash.com/photo-1541888946425-d0fbb186a5b3',
        price: 2750,
        priceUnit: 'ج.م/طن',
        rating: 4.8,
        deepLinkRoute: RouteNames.buildingMaterialsCategories,
        canAddToCart: true,
      ),

      // Home Services
      const UnifiedFavoriteItem(
        favoriteId: 'fav-hs-1',
        itemId: 'hs-ac-maintenance',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        title: 'صيانة دورية وغسيل تكييفات',
        subtitle: 'مهندسون معتمدون وقطع غيار أصلية',
        imageUrl:
            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        price: 350,
        rating: 4.9,
        deepLinkRoute: RouteNames.acServiceDetail,
        canBookService: true,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-hs-2',
        itemId: 'hs-plumbing-leak',
        sectorId: 'services',
        sectorName: 'الخدمات المنزلية',
        title: 'كشف تسريبات وصيانة شبكة مياه',
        subtitle: 'أحدث أجهزة الكشف الإلكتروني دون تكسير',
        imageUrl:
            'https://images.unsplash.com/photo-1581578731548-c64695cc6952',
        price: 250,
        rating: 4.8,
        deepLinkRoute: RouteNames.homeServices,
        canBookService: true,
      ),

      // Home Appliances
      const UnifiedFavoriteItem(
        favoriteId: 'fav-ha-1',
        itemId: 'ha-tv-samsung-55',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        title: 'شاشة سامسونج 55 بوصة 4K UHD',
        subtitle: 'ضمان سنتين من الوكيل المعتمد',
        imageUrl:
            'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1',
        price: 18999,
        rating: 4.7,
        deepLinkRoute: RouteNames.homeAppliances,
        canAddToCart: true,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-ha-2',
        itemId: 'ha-ac-sharp-15',
        sectorId: 'home_appliances',
        sectorName: 'الأجهزة المنزلية',
        title: 'تكييف شارب 1.5 حصان بارد/ساخن',
        subtitle: 'إنفرتر موفر للكهرباء وبلازما كلاستر',
        imageUrl:
            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e',
        price: 28500,
        rating: 4.9,
        deepLinkRoute: RouteNames.homeAppliances,
        canAddToCart: true,
      ),

      // Cars Favorites
      const UnifiedFavoriteItem(
        favoriteId: 'fav-car-1',
        itemId: 'car-01',
        sectorId: 'cars',
        sectorName: 'السيارات',
        title: 'تويوتا كورولا 2023 فئة ثانية',
        subtitle: 'فابريكا بالكامل - عداد 18,000 كم - طنطا',
        imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341',
        price: 1050000,
        rating: 4.9,
        deepLinkRoute: RouteNames.cars,
        canAddToCart: false,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-car-2',
        itemId: 'car-02',
        sectorId: 'cars',
        sectorName: 'السيارات',
        title: 'هيونداي توسان 2022 تيربو بانوراما',
        subtitle: 'المحلة الكبرى - صيانات توكيل منتظمة',
        imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70',
        price: 1480000,
        rating: 4.8,
        deepLinkRoute: RouteNames.cars,
        canAddToCart: false,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-car-3',
        itemId: 'car-03',
        sectorId: 'cars',
        sectorName: 'السيارات',
        title: 'كيا سبورتاج 2024 زيرو',
        subtitle: 'ضمان الوكيل - كفر الزيات',
        imageUrl: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d',
        price: 1750000,
        rating: 5.0,
        deepLinkRoute: RouteNames.cars,
        canAddToCart: false,
      ),

      // Fashion Favorites
      const UnifiedFavoriteItem(
        favoriteId: 'fav-fsh-1',
        itemId: 'f-m01',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        title: 'قميص أكسفورد كاجوال قطن 100%',
        subtitle: 'الماركة: ماسيمو دوتي',
        imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c',
        price: 520,
        rating: 4.8,
        deepLinkRoute: RouteNames.fashion,
        canAddToCart: true,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-fsh-2',
        itemId: 'f-w01',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        title: 'فستان ميدي شيفون بليسيه أنيق',
        subtitle: 'الماركة: زارا فاشن ستور',
        imageUrl: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1',
        price: 1150,
        rating: 4.9,
        deepLinkRoute: RouteNames.fashion,
        canAddToCart: true,
      ),
      const UnifiedFavoriteItem(
        favoriteId: 'fav-fsh-3',
        itemId: 'f-m06',
        sectorId: 'fashion',
        sectorName: 'الملابس والأزياء',
        title: 'سنيكرز رياضي خفيف الوزن',
        subtitle: 'الماركة: أديداس إيجيبت',
        imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772',
        price: 650,
        rating: 4.7,
        deepLinkRoute: RouteNames.fashion,
        canAddToCart: true,
      ),
    ]);
  }

  @override
  Future<List<UnifiedFavoriteItem>> getFavorites({
    FavoriteSectorFilter sector = FavoriteSectorFilter.all,
    String? searchQuery,
  }) async {
    final list = List<UnifiedFavoriteItem>.from(_inMemoryFavorites);

    // Also pull Real Estate favorites from realEstateFavoritesRepo
    try {
      final reFavs = await realEstateFavoritesRepo.getFavorites();
      for (final ref in reFavs) {
        if (!list.any((e) => e.itemId == ref.property.id)) {
          list.add(
            UnifiedFavoriteItem(
              favoriteId: ref.id,
              itemId: ref.property.id,
              sectorId: 'real_estate',
              sectorName: 'العقارات',
              title: ref.property.title,
              subtitle:
                  '${ref.property.location} • ${ref.property.areaM2} م²',
              imageUrl: ref.property.imageUrl,
              customPriceFormatted: ref.property.priceFormatted,
              rating: 4.9,
              deepLinkRoute: RouteNames.realEstateDetail,
              canAddToCart: false,
              canBookService: false,
            ),
          );
        }
      }
    } catch (_) {}

    var filtered = list;
    if (sector != FavoriteSectorFilter.all) {
      filtered = filtered.where((e) => e.sectorId == sector.id).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.subtitle.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<bool> removeFavorite(String itemId) async {
    _inMemoryFavorites.removeWhere((item) => item.itemId == itemId);
    return true;
  }

  @override
  Future<bool> addFavorite(UnifiedFavoriteItem item) async {
    if (!_inMemoryFavorites.any((e) => e.itemId == item.itemId)) {
      _inMemoryFavorites.insert(0, item);
    }
    return true;
  }
}
