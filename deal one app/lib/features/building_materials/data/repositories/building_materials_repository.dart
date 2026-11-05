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
