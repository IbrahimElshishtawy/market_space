import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
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

class ApiHomeAppliancesRepository implements HomeAppliancesRepository {
  final ApiClient apiClient;
  final MockHomeAppliancesRepository _fallback = MockHomeAppliancesRepository();

  ApiHomeAppliancesRepository({required this.apiClient});

  @override
  Future<List<ApplianceCategoryModel>> getCategories() async {
    return _fallback.getCategories();
  }

  @override
  Future<ApplianceHeroBannerModel> getHeroBanner() async {
    return _fallback.getHeroBanner();
  }

  @override
  Future<List<ApplianceProductModel>> getProducts({
    ApplianceFilterModel? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': 'home-appliances',
        'limit': 50,
      };

      if (filter != null && filter.searchQuery.trim().isNotEmpty) {
        queryParams['q'] = filter.searchQuery.trim();
      }

      final response = await apiClient.get('/listings', queryParameters: queryParams);
      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isEmpty) {
        return _fallback.getProducts(filter: filter);
      }

      final fmt = NumberFormat.decimalPattern();
      return items.map<ApplianceProductModel>((item) {
        final data = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        final num priceNum = data['price'] is num ? data['price'] : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
        final priceFormatted = '${fmt.format(priceNum)} ج.م';
        final attrs = data['attributes'] is Map ? Map<String, dynamic>.from(data['attributes']) : {};

        final mediaList = data['media'] as List?;
        final imageUrl = data['primaryImageUrl']?.toString() ??
            data['imageUrl']?.toString() ??
            (mediaList != null && mediaList.isNotEmpty ? mediaList[0]['publicUrl']?.toString() : null) ??
            'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80';

        return ApplianceProductModel(
          id: data['id']?.toString() ?? '',
          title: data['title']?.toString() ?? 'جهاز منزلي',
          subtitle: data['description']?.toString() ?? 'أجهزة كهربائية ومنزلية بضمان معتمد',
          brandName: attrs['brand']?.toString() ?? 'العربي جروب',
          priceFormatted: priceFormatted,
          oldPriceFormatted: '${fmt.format(priceNum * 1.15)} ج.م',
          monthlyInstallmentFormatted: 'قسط ${fmt.format((priceNum / 12).round())} ج.م / شهر',
          imageUrl: imageUrl,
          isFavorite: false,
          inCart: false,
          categoryKey: data['category']?['slug']?.toString() ?? 'cat-appliances',
        );
      }).toList();
    } catch (_) {
      return _fallback.getProducts(filter: filter);
    }
  }

  @override
  Future<ApplianceCategoryDetailModel> getCategoryDetails(String categoryId) async {
    return _fallback.getCategoryDetails(categoryId);
  }

  @override
  Future<List<ApplianceProductModel>> getCategoryListingProducts(
    String categoryId, {
    String? filterChip,
  }) async {
    return _fallback.getCategoryListingProducts(categoryId, filterChip: filterChip);
  }

  @override
  Future<bool> toggleCart(String productId) async {
    return _fallback.toggleCart(productId);
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    try {
      final res = await apiClient.post('/favorites/$productId');
      final data = res.data;
      if (data is Map && data['data'] != null && data['data']['favorited'] != null) {
        return data['data']['favorited'] as bool;
      }
      return true;
    } catch (_) {
      return _fallback.toggleFavorite(productId);
    }
  }
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
