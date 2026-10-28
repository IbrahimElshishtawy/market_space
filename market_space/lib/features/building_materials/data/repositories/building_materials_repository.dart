import '../mock/mock_all_categories_data.dart';
import '../mock/mock_building_materials_data.dart';
import '../mock/mock_steel_rebar_data.dart';
import '../models/building_material_category_model.dart';
import '../models/building_material_product_model.dart';
import '../models/category_detail_model.dart';
import '../models/contractor_project_banner_model.dart';
import '../models/daily_price_banner_model.dart';
import '../models/steel_daily_price_model.dart';
import '../models/steel_rebar_product_model.dart';

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
    final detail = MockAllCategoriesData.categoriesDetails[categoryId] ??
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
}
