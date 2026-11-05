import 'package:flutter/foundation.dart';

import '../../data/models/steel_daily_price_model.dart';
import '../../data/models/steel_rebar_product_model.dart';
import '../../data/repositories/building_materials_repository.dart';

class SteelRebarState {
  final bool isLoading;
  final String? errorMessage;
  final SteelDailyPriceModel? dailyPrice;
  final List<String> availableSizes;
  final String selectedSize;
  final List<SteelRebarProductModel> products;

  const SteelRebarState({
    this.isLoading = true,
    this.errorMessage,
    this.dailyPrice,
    this.availableSizes = const [],
    this.selectedSize = 'الكل',
    this.products = const [],
  });

  SteelRebarState copyWith({
    bool? isLoading,
    String? errorMessage,
    SteelDailyPriceModel? dailyPrice,
    List<String>? availableSizes,
    String? selectedSize,
    List<SteelRebarProductModel>? products,
  }) {
    return SteelRebarState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dailyPrice: dailyPrice ?? this.dailyPrice,
      availableSizes: availableSizes ?? this.availableSizes,
      selectedSize: selectedSize ?? this.selectedSize,
      products: products ?? this.products,
    );
  }
}

class SteelRebarController extends ValueNotifier<SteelRebarState> {
  final BuildingMaterialsRepository repository;

  SteelRebarController({BuildingMaterialsRepository? repository})
    : repository = repository ?? const BuildingMaterialsRepositoryImpl(),
      super(const SteelRebarState());

  Future<void> loadData() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final dailyPrice = await repository.getSteelDailyPrice();
      final sizes = await repository.getSteelSizes();
      final products = await repository.getSteelProducts(
        selectedSize: value.selectedSize,
      );

      value = value.copyWith(
        isLoading: false,
        dailyPrice: dailyPrice,
        availableSizes: sizes,
        products: products,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectSize(String size) async {
    value = value.copyWith(selectedSize: size);
    try {
      final filteredProducts = await repository.getSteelProducts(
        selectedSize: size,
      );
      value = value.copyWith(products: filteredProducts);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }
}
