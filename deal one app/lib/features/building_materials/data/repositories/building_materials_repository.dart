import '../../../../core/network/api_client.dart';
import '../mock/mock_all_categories_data.dart';
import '../mock/mock_building_materials_comprehensive_data.dart';
import '../mock/mock_building_materials_data.dart';
import '../mock/mock_steel_rebar_data.dart';
import '../models/building_material_category_model.dart';
import '../models/building_material_product_model.dart';
import '../models/category_detail_model.dart';
import '../models/contractor_project_banner_model.dart';
import '../models/daily_price_banner_model.dart';
import '../models/material_product_model.dart';
import '../models/steel_daily_price_model.dart';
import '../models/steel_rebar_product_model.dart';
import '../models/supplier_model.dart';
import '../models/unit_of_measurement.dart';

abstract class BuildingMaterialsRepository {
  Future<DailyPriceBannerModel> getDailyPriceBanner();
  Future<List<BuildingMaterialCategoryModel>> getCategories();
  Future<List<BuildingMaterialProductModel>> getMostRequestedProducts();
  Future<ContractorProjectBannerModel> getContractorProjectBanner();
  Future<SteelDailyPriceModel> getSteelDailyPrice();
  Future<List<String>> getSteelSizes();
  Future<List<SteelRebarProductModel>> getSteelProducts({String? selectedSize});
  Future<CategoryDetailModel> getCategoryDetail(
    String categoryId, {
    String? selectedFilter,
  });

  // Comprehensive Marketplace APIs
  Future<List<BuildingMaterialCategoryModel>> getAllTenCategories();
  Future<List<MaterialProductModel>> getMaterialProducts({
    String? categoryId,
    String? subcategoryId,
    String? brand,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? supplierId,
  });
  Future<MaterialProductModel?> getMaterialProductById(String productId);
  Future<List<SupplierModel>> getSuppliers();
  Future<SupplierModel?> getSupplierById(String supplierId);
  Future<double> estimateCost(Map<String, double> materialQuantities);
}

class BuildingMaterialsRepositoryImpl implements BuildingMaterialsRepository {
  final Duration networkDelay;

  const BuildingMaterialsRepositoryImpl({
    this.networkDelay = const Duration(milliseconds: 200),
  });

  @override
  Future<DailyPriceBannerModel> getDailyPriceBanner() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsData.dailyPriceBanner;
  }

  @override
  Future<List<BuildingMaterialCategoryModel>> getCategories() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsData.categories;
  }

  @override
  Future<List<BuildingMaterialProductModel>> getMostRequestedProducts() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsData.mostRequestedProducts;
  }

  @override
  Future<ContractorProjectBannerModel> getContractorProjectBanner() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsData.contractorBanner;
  }

  @override
  Future<SteelDailyPriceModel> getSteelDailyPrice() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockSteelRebarData.dailyPrice;
  }

  @override
  Future<List<String>> getSteelSizes() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockSteelRebarData.availableSizes;
  }

  @override
  Future<List<SteelRebarProductModel>> getSteelProducts({
    String? selectedSize,
  }) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    if (selectedSize == null || selectedSize == 'الكل') {
      return MockSteelRebarData.products;
    }
    return MockSteelRebarData.products
        .where((p) => p.sizeMm == selectedSize)
        .toList();
  }

  @override
  Future<CategoryDetailModel> getCategoryDetail(
    String categoryId, {
    String? selectedFilter,
  }) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    final detail =
        MockAllCategoriesData.categoriesDetails[categoryId] ??
        MockAllCategoriesData.categoriesDetails['cat-steel']!;

    if (selectedFilter == null || selectedFilter == 'الكل') {
      return detail;
    }

    final filteredProducts = detail.products
        .where((p) => p.filterTag == selectedFilter)
        .toList();

    return CategoryDetailModel(
      id: detail.id,
      title: detail.title,
      subtitle: detail.subtitle,
      bannerTitle: detail.bannerTitle,
      bannerPriceText: detail.bannerPriceText,
      bannerTrendText: detail.bannerTrendText,
      isTrendUp: detail.isTrendUp,
      bannerSubtitle: detail.bannerSubtitle,
      orderCtaText: detail.orderCtaText,
      priceLogCtaText: detail.priceLogCtaText,
      filterChips: detail.filterChips,
      products: filteredProducts,
    );
  }

  @override
  Future<List<BuildingMaterialCategoryModel>> getAllTenCategories() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsComprehensiveData.categories;
  }

  @override
  Future<List<MaterialProductModel>> getMaterialProducts({
    String? categoryId,
    String? subcategoryId,
    String? brand,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? supplierId,
  }) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    var list = MockBuildingMaterialsComprehensiveData.products;

    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'الكل') {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    if (subcategoryId != null && subcategoryId.isNotEmpty && subcategoryId != 'الكل') {
      list = list.where((p) => p.subcategoryId == subcategoryId).toList();
    }
    if (brand != null && brand.isNotEmpty && brand != 'الكل') {
      list = list.where((p) => p.brand.contains(brand) || p.manufacturer.contains(brand)).toList();
    }
    if (supplierId != null && supplierId.isNotEmpty) {
      list = list.where((p) => p.supplier.id == supplierId).toList();
    }
    if (minPrice != null) {
      list = list.where((p) => p.unitPrice >= minPrice).toList();
    }
    if (maxPrice != null) {
      list = list.where((p) => p.unitPrice <= maxPrice).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  @override
  Future<MaterialProductModel?> getMaterialProductById(String productId) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    try {
      return MockBuildingMaterialsComprehensiveData.products.firstWhere(
        (p) => p.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    return MockBuildingMaterialsComprehensiveData.suppliers;
  }

  @override
  Future<SupplierModel?> getSupplierById(String supplierId) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    try {
      return MockBuildingMaterialsComprehensiveData.suppliers.firstWhere(
        (s) => s.id == supplierId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<double> estimateCost(Map<String, double> materialQuantities) async {
    if (networkDelay > Duration.zero) {
      await Future.delayed(networkDelay);
    }
    double total = 0.0;
    materialQuantities.forEach((prodId, qty) {
      try {
        final prod = MockBuildingMaterialsComprehensiveData.products.firstWhere(
          (p) => p.id == prodId,
        );
        total += prod.unitPrice * qty;
      } catch (_) {}
    });
    return UnitConverter.roundCurrency(total);
  }
}

class ApiBuildingMaterialsRepository implements BuildingMaterialsRepository {
  final ApiClient apiClient;
  final BuildingMaterialsRepositoryImpl _fallback =
      const BuildingMaterialsRepositoryImpl();

  ApiBuildingMaterialsRepository({required this.apiClient});

  @override
  Future<DailyPriceBannerModel> getDailyPriceBanner() =>
      _fallback.getDailyPriceBanner();

  @override
  Future<List<BuildingMaterialCategoryModel>> getCategories() =>
      _fallback.getCategories();

  @override
  Future<List<BuildingMaterialProductModel>> getMostRequestedProducts() async {
    try {
      final response = await apiClient.get(
        '/listings',
        queryParameters: {
          'categorySlug': 'building-materials',
          'limit': 10,
        },
      );

      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isEmpty) {
        return await _fallback.getMostRequestedProducts();
      }

      return items.map<BuildingMaterialProductModel>((item) {
        final Map<String, dynamic> data =
            item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        final price = data['price']?.toString() ?? '0';
        final cat = data['category'] is Map ? data['category'] as Map : {};
        return BuildingMaterialProductModel(
          id: data['id']?.toString() ?? '',
          title: data['title']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
          priceText: '$price ج.م',
          rating: 4.8,
          categoryTag: cat['nameAr']?.toString() ?? 'مواد بناء',
          imageUrl: data['primaryImageUrl']?.toString() ??
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        );
      }).toList();
    } catch (_) {
      return await _fallback.getMostRequestedProducts();
    }
  }

  @override
  Future<ContractorProjectBannerModel> getContractorProjectBanner() =>
      _fallback.getContractorProjectBanner();

  @override
  Future<SteelDailyPriceModel> getSteelDailyPrice() =>
      _fallback.getSteelDailyPrice();

  @override
  Future<List<String>> getSteelSizes() => _fallback.getSteelSizes();

  @override
  Future<List<SteelRebarProductModel>> getSteelProducts({String? selectedSize}) =>
      _fallback.getSteelProducts(selectedSize: selectedSize);

  @override
  Future<CategoryDetailModel> getCategoryDetail(
    String categoryId, {
    String? selectedFilter,
  }) =>
      _fallback.getCategoryDetail(categoryId, selectedFilter: selectedFilter);

  @override
  Future<List<BuildingMaterialCategoryModel>> getAllTenCategories() =>
      _fallback.getAllTenCategories();

  @override
  Future<List<MaterialProductModel>> getMaterialProducts({
    String? categoryId,
    String? subcategoryId,
    String? brand,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? supplierId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': 'building-materials',
        'limit': 20,
      };
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['q'] = searchQuery.trim();
      }
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

      final response = await apiClient.get(
        '/listings',
        queryParameters: queryParams,
      );

      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isEmpty) {
        return await _fallback.getMaterialProducts(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
          brand: brand,
          searchQuery: searchQuery,
          minPrice: minPrice,
          maxPrice: maxPrice,
          supplierId: supplierId,
        );
      }

      return items.map<MaterialProductModel>((item) {
        final Map<String, dynamic> data =
            item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
        final priceNum = data['price'] is num
            ? (data['price'] as num).toDouble()
            : (double.tryParse(data['price']?.toString() ?? '0') ?? 0.0);
        final cat = data['category'] is Map ? data['category'] as Map : {};
        final account = data['account'] is Map ? data['account'] as Map : {};

        return MaterialProductModel(
          id: data['id']?.toString() ?? '',
          name: data['title']?.toString() ?? '',
          categoryId: cat['id']?.toString() ?? 'building-materials',
          subcategoryId: cat['slug']?.toString() ?? 'building-materials',
          categoryName: cat['nameAr']?.toString() ?? 'مواد البناء والتوريدات',
          brand: brand ?? 'عام',
          manufacturer: account['displayName']?.toString() ?? 'مورد معتمد',
          description: data['description']?.toString() ?? '',
          technicalSpecs: const {'الجودة': 'مطابق للمواصفات القياسية المصرية'},
          baseUnit: MaterialUnit.ton,
          supportedUnits: const [MaterialUnit.ton],
          unitPrice: priceNum,
          minOrderQuantity: 1,
          stockQuantity: 100,
          supplyOrigin: 'مستودع المورد الرئيسي',
          supplier: SupplierModel(
            id: account['id']?.toString() ?? 'sup-default',
            name: account['displayName']?.toString() ?? 'مورد مواد بناء',
            companyType: 'موزع معتمد',
            rating: 4.8,
            reviewsCount: 25,
            city: 'القاهرة',
            governorate: 'القاهرة',
            latitude: 30.0444,
            longitude: 31.2357,
            coverageGovernorates: const ['القاهرة', 'الجيزة', 'كافة المحافظات'],
            minOrderValue: 5000.0,
            fleetCapacityTons: 50.0,
            contactPhone: data['sellerPhone']?.toString() ?? '+201001122334',
          ),
          imageUrls: [
            data['primaryImageUrl']?.toString() ??
                'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
          ],
        );
      }).toList();
    } catch (_) {
      return await _fallback.getMaterialProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        brand: brand,
        searchQuery: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        supplierId: supplierId,
      );
    }
  }

  @override
  Future<MaterialProductModel?> getMaterialProductById(String productId) async {
    try {
      final response = await apiClient.get('/listings/$productId');
      final dynamic resData = response.data;
      final Map<String, dynamic> data =
          resData is Map && resData['data'] is Map
              ? Map<String, dynamic>.from(resData['data'])
              : (resData is Map ? Map<String, dynamic>.from(resData) : {});

      if (data.isEmpty || data['id'] == null) {
        return await _fallback.getMaterialProductById(productId);
      }

      final priceNum = data['price'] is num
          ? (data['price'] as num).toDouble()
          : (double.tryParse(data['price']?.toString() ?? '0') ?? 0.0);
      final cat = data['category'] is Map ? data['category'] as Map : {};
      final account = data['account'] is Map ? data['account'] as Map : {};

      return MaterialProductModel(
        id: data['id']?.toString() ?? productId,
        name: data['title']?.toString() ?? '',
        categoryId: cat['id']?.toString() ?? 'building-materials',
        subcategoryId: cat['slug']?.toString() ?? 'building-materials',
        categoryName: cat['nameAr']?.toString() ?? 'مواد البناء والتوريدات',
        brand: 'عام',
        manufacturer: account['displayName']?.toString() ?? 'مورد معتمد',
        description: data['description']?.toString() ?? '',
        technicalSpecs: const {'الجودة': 'مطابق للمواصفات القياسية المصرية'},
        baseUnit: MaterialUnit.ton,
        supportedUnits: const [MaterialUnit.ton],
        unitPrice: priceNum,
        minOrderQuantity: 1,
        stockQuantity: 100,
        supplyOrigin: 'مستودع المورد الرئيسي',
        supplier: SupplierModel(
          id: account['id']?.toString() ?? 'sup-default',
          name: account['displayName']?.toString() ?? 'مورد مواد بناء',
          companyType: 'موزع معتمد',
          rating: 4.8,
          reviewsCount: 25,
          city: 'القاهرة',
          governorate: 'القاهرة',
          latitude: 30.0444,
          longitude: 31.2357,
          coverageGovernorates: const ['القاهرة', 'الجيزة', 'كافة المحافظات'],
          minOrderValue: 5000.0,
          fleetCapacityTons: 50.0,
          contactPhone: data['sellerPhone']?.toString() ?? '+201001122334',
        ),
        imageUrls: [
          data['primaryImageUrl']?.toString() ??
              'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122',
        ],
      );
    } catch (_) {
      return await _fallback.getMaterialProductById(productId);
    }
  }

  @override
  Future<List<SupplierModel>> getSuppliers() => _fallback.getSuppliers();

  @override
  Future<SupplierModel?> getSupplierById(String supplierId) =>
      _fallback.getSupplierById(supplierId);

  @override
  Future<double> estimateCost(Map<String, double> materialQuantities) =>
      _fallback.estimateCost(materialQuantities);
}
