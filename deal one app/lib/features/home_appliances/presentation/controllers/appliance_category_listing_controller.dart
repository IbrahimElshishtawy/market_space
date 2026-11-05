import 'package:flutter/foundation.dart';

import '../../data/models/appliance_category_detail_model.dart';
import '../../data/models/appliance_product_model.dart';
import '../../data/repositories/home_appliances_repository.dart';

class ApplianceCategoryListingState {
  final bool isLoading;
  final String? errorMessage;
  final ApplianceCategoryDetailModel? categoryDetail;
  final List<ApplianceProductModel> products;
  final String selectedChip;

  const ApplianceCategoryListingState({
    this.isLoading = true,
    this.errorMessage,
    this.categoryDetail,
    this.products = const [],
    this.selectedChip = 'الكل',
  });

  ApplianceCategoryListingState copyWith({
    bool? isLoading,
    String? errorMessage,
    ApplianceCategoryDetailModel? categoryDetail,
    List<ApplianceProductModel>? products,
    String? selectedChip,
  }) {
    return ApplianceCategoryListingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categoryDetail: categoryDetail ?? this.categoryDetail,
      products: products ?? this.products,
      selectedChip: selectedChip ?? this.selectedChip,
    );
  }
}

class ApplianceCategoryListingController
    extends ValueNotifier<ApplianceCategoryListingState> {
  final HomeAppliancesRepository repository;

  ApplianceCategoryListingController({HomeAppliancesRepository? repository})
    : repository = repository ?? MockHomeAppliancesRepository(),
      super(const ApplianceCategoryListingState());

  Future<void> loadCategory(String categoryId) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final detail = await repository.getCategoryDetails(categoryId);
      final products = await repository.getCategoryListingProducts(
        categoryId,
        filterChip: value.selectedChip,
      );

      value = value.copyWith(
        isLoading: false,
        categoryDetail: detail,
        products: products,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectFilterChip(String chip) {
    if (value.selectedChip == chip && chip != 'الكل') return;
    value = value.copyWith(selectedChip: chip);

    final catId = value.categoryDetail?.id ?? 'cat-tv';
    _reloadProducts(catId);
  }

  Future<void> _reloadProducts(String categoryId) async {
    try {
      final items = await repository.getCategoryListingProducts(
        categoryId,
        filterChip: value.selectedChip,
      );
      value = value.copyWith(products: items);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> toggleCart(String productId) async {
    final newCart = await repository.toggleCart(productId);
    final updatedList = value.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(inCart: newCart);
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
