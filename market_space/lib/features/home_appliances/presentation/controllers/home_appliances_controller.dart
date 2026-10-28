import 'package:flutter/foundation.dart';

import '../../data/models/appliance_category_model.dart';
import '../../data/models/appliance_filter_model.dart';
import '../../data/models/appliance_hero_banner_model.dart';
import '../../data/models/appliance_product_model.dart';
import '../../data/repositories/home_appliances_repository.dart';

class HomeAppliancesState {
  final bool isLoading;
  final String? errorMessage;
  final List<ApplianceCategoryModel> categories;
  final ApplianceHeroBannerModel? heroBanner;
  final List<ApplianceProductModel> products;
  final ApplianceFilterModel filter;

  const HomeAppliancesState({
    this.isLoading = true,
    this.errorMessage,
    this.categories = const [],
    this.heroBanner,
    this.products = const [],
    this.filter = const ApplianceFilterModel(),
  });

  HomeAppliancesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ApplianceCategoryModel>? categories,
    ApplianceHeroBannerModel? heroBanner,
    List<ApplianceProductModel>? products,
    ApplianceFilterModel? filter,
  }) {
    return HomeAppliancesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
      heroBanner: heroBanner ?? this.heroBanner,
      products: products ?? this.products,
      filter: filter ?? this.filter,
    );
  }
}

class HomeAppliancesController extends ValueNotifier<HomeAppliancesState> {
  final HomeAppliancesRepository repository;

  HomeAppliancesController({HomeAppliancesRepository? repository})
    : repository = repository ?? MockHomeAppliancesRepository(),
      super(const HomeAppliancesState());

  Future<void> loadData() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final categories = await repository.getCategories();
      final heroBanner = await repository.getHeroBanner();
      final products = await repository.getProducts(filter: value.filter);

      value = value.copyWith(
        isLoading: false,
        categories: categories,
        heroBanner: heroBanner,
        products: products,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategoryFilter(String? categoryId) {
    if (value.filter.selectedCategoryId == categoryId) {
      // Toggle off if same category is tapped
      final updatedFilter = value.filter.copyWith(selectedCategoryId: null);
      value = value.copyWith(filter: updatedFilter);
    } else {
      final updatedFilter = value.filter.copyWith(
        selectedCategoryId: categoryId,
      );
      value = value.copyWith(filter: updatedFilter);
    }
    _loadProductsOnly();
  }

  void setSearchQuery(String query) {
    final updatedFilter = value.filter.copyWith(searchQuery: query);
    value = value.copyWith(filter: updatedFilter);
    _loadProductsOnly();
  }

  Future<void> _loadProductsOnly() async {
    try {
      final items = await repository.getProducts(filter: value.filter);
      value = value.copyWith(products: items);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> toggleCart(String productId) async {
    final newInCart = await repository.toggleCart(productId);
    final updatedList = value.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(inCart: newInCart);
      }
      return p;
    }).toList();

    value = value.copyWith(products: updatedList);
  }

  Future<void> toggleFavorite(String productId) async {
    final newFav = await repository.toggleFavorite(productId);
    final updatedList = value.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: newFav);
      }
      return p;
    }).toList();

    value = value.copyWith(products: updatedList);
  }
}
