import '../mock/mock_home_appliances_data.dart';
import '../models/appliance_category_detail_model.dart';
import '../models/appliance_category_model.dart';
import '../models/appliance_filter_model.dart';
import '../models/appliance_hero_banner_model.dart';
import '../models/appliance_product_model.dart';

abstract class HomeAppliancesRepository {
  Future<List<ApplianceCategoryModel>> getCategories();
  Future<ApplianceHeroBannerModel> getHeroBanner();
  Future<List<ApplianceProductModel>> getProducts({
    ApplianceFilterModel? filter,
  });
  Future<ApplianceCategoryDetailModel> getCategoryDetails(String categoryId);
  Future<List<ApplianceProductModel>> getCategoryListingProducts(
    String categoryId, {
    String? filterChip,
  });
  Future<bool> toggleCart(String productId);
  Future<bool> toggleFavorite(String productId);
}

class MockHomeAppliancesRepository implements HomeAppliancesRepository {
  final List<ApplianceProductModel> _productsCache = List.from(
    MockHomeAppliancesData.products,
  );
  final List<ApplianceProductModel> _tvProductsCache = List.from(
    MockHomeAppliancesData.tvCategoryProducts,
  );

  @override
  Future<List<ApplianceCategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockHomeAppliancesData.categories;
  }

  @override
  Future<ApplianceHeroBannerModel> getHeroBanner() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockHomeAppliancesData.heroBanner;
  }

  @override
  Future<List<ApplianceProductModel>> getProducts({
    ApplianceFilterModel? filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var results = List<ApplianceProductModel>.from(_productsCache);

    if (filter != null) {
      if (filter.selectedCategoryId != null &&
          filter.selectedCategoryId != 'all') {
        results = results
            .where((item) => item.categoryKey == filter.selectedCategoryId)
            .toList();
      }

      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.trim().toLowerCase();
        results = results.where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.subtitle.toLowerCase().contains(query) ||
              item.brandName.toLowerCase().contains(query);
        }).toList();
      }
    }

    return results;
  }

  @override
  Future<ApplianceCategoryDetailModel> getCategoryDetails(
    String categoryId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return MockHomeAppliancesData.getCategoryDetail(categoryId);
  }

  @override
  Future<List<ApplianceProductModel>> getCategoryListingProducts(
    String categoryId, {
    String? filterChip,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (categoryId == 'cat-tv') {
      var tvs = List<ApplianceProductModel>.from(_tvProductsCache);
      if (filterChip != null && filterChip != 'الكل') {
        // Simple mock filtering based on chip
        if (filterChip.contains('الماركة')) {
          tvs.sort((a, b) => a.brandName.compareTo(b.brandName));
        } else if (filterChip.contains('السعر')) {
          tvs.sort((a, b) => a.priceFormatted.compareTo(b.priceFormatted));
        }
      }
      return tvs;
    }

    // Fallback for other categories
    return _productsCache
        .where((item) => item.categoryKey == categoryId)
        .toList();
  }

  @override
  Future<bool> toggleCart(String productId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    var index = _tvProductsCache.indexWhere((item) => item.id == productId);
    if (index != -1) {
      final current = _tvProductsCache[index];
      _tvProductsCache[index] = current.copyWith(inCart: !current.inCart);
      return _tvProductsCache[index].inCart;
    }

    index = _productsCache.indexWhere((item) => item.id == productId);
    if (index != -1) {
      final current = _productsCache[index];
      _productsCache[index] = current.copyWith(inCart: !current.inCart);
      return _productsCache[index].inCart;
    }

    return false;
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    var index = _tvProductsCache.indexWhere((item) => item.id == productId);
    if (index != -1) {
      final current = _tvProductsCache[index];
      _tvProductsCache[index] = current.copyWith(
        isFavorite: !current.isFavorite,
      );
      return _tvProductsCache[index].isFavorite;
    }

    index = _productsCache.indexWhere((item) => item.id == productId);
    if (index != -1) {
      final current = _productsCache[index];
      _productsCache[index] = current.copyWith(isFavorite: !current.isFavorite);
      return _productsCache[index].isFavorite;
    }

    return false;
  }
}
