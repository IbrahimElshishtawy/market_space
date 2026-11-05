import 'package:flutter/foundation.dart';

import '../../data/models/building_material_category_model.dart';
import '../../data/models/building_material_product_model.dart';
import '../../data/models/contractor_project_banner_model.dart';
import '../../data/models/daily_price_banner_model.dart';
import '../../data/repositories/building_materials_repository.dart';

class BuildingMaterialsState {
  final bool isLoading;
  final String? errorMessage;
  final DailyPriceBannerModel? dailyPriceBanner;
  final List<BuildingMaterialCategoryModel> categories;
  final List<BuildingMaterialProductModel> mostRequestedProducts;
  final ContractorProjectBannerModel? contractorBanner;
  final String? selectedCategoryId;
  final String searchQuery;

  const BuildingMaterialsState({
    this.isLoading = true,
    this.errorMessage,
    this.dailyPriceBanner,
    this.categories = const [],
    this.mostRequestedProducts = const [],
    this.contractorBanner,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  BuildingMaterialsState copyWith({
    bool? isLoading,
    String? errorMessage,
    DailyPriceBannerModel? dailyPriceBanner,
    List<BuildingMaterialCategoryModel>? categories,
    List<BuildingMaterialProductModel>? mostRequestedProducts,
    ContractorProjectBannerModel? contractorBanner,
    bool clearSelectedCategory = false,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return BuildingMaterialsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dailyPriceBanner: dailyPriceBanner ?? this.dailyPriceBanner,
      categories: categories ?? this.categories,
      mostRequestedProducts:
          mostRequestedProducts ?? this.mostRequestedProducts,
      contractorBanner: contractorBanner ?? this.contractorBanner,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class BuildingMaterialsController
    extends ValueNotifier<BuildingMaterialsState> {
  final BuildingMaterialsRepository repository;

  BuildingMaterialsController({BuildingMaterialsRepository? repository})
    : repository = repository ?? const BuildingMaterialsRepositoryImpl(),
      super(const BuildingMaterialsState());

  Future<void> loadData() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final dailyPriceBanner = await repository.getDailyPriceBanner();
      final categories = await repository.getCategories();
      final products = await repository.getMostRequestedProducts();
      final contractorBanner = await repository.getContractorProjectBanner();

      value = value.copyWith(
        isLoading: false,
        dailyPriceBanner: dailyPriceBanner,
        categories: categories,
        mostRequestedProducts: products,
        contractorBanner: contractorBanner,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectCategory(String? categoryId) {
    if (value.selectedCategoryId == categoryId || categoryId == null) {
      value = value.copyWith(clearSelectedCategory: true);
    } else {
      value = value.copyWith(selectedCategoryId: categoryId);
    }
  }

  void setSearchQuery(String query) {
    value = value.copyWith(searchQuery: query);
  }
}
