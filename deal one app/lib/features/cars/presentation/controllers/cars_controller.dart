import 'package:flutter/foundation.dart';

import '../../data/models/car_brand_model.dart';
import '../../data/models/car_filter_model.dart';
import '../../data/models/car_listing_model.dart';
import '../../data/repositories/cars_repository.dart';

class CarsState {
  final bool isLoading;
  final List<CarListingModel> featuredCars;
  final List<CarListingModel> cars;
  final List<CarBrandModel> brands;
  final CarFilterModel filter;
  final String? errorMessage;

  const CarsState({
    this.isLoading = false,
    this.featuredCars = const [],
    this.cars = const [],
    this.brands = const [],
    this.filter = const CarFilterModel(),
    this.errorMessage,
  });

  CarsState copyWith({
    bool? isLoading,
    List<CarListingModel>? featuredCars,
    List<CarListingModel>? cars,
    List<CarBrandModel>? brands,
    CarFilterModel? filter,
    String? errorMessage,
  }) {
    return CarsState(
      isLoading: isLoading ?? this.isLoading,
      featuredCars: featuredCars ?? this.featuredCars,
      cars: cars ?? this.cars,
      brands: brands ?? this.brands,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }
}

class CarsController extends ValueNotifier<CarsState> {
  final CarsRepository repository;
  bool _isDisposed = false;

  CarsController({CarsRepository? repository})
      : repository = repository ?? MockCarsRepository(),
        super(const CarsState(isLoading: true)) {
    loadInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final featured = await repository.getFeaturedCars();
      final brands = await repository.getBrands();
      final all = await repository.getCars(filter: value.filter);

      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        featuredCars: featured,
        brands: brands,
        cars: all,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل بيانات السيارات: $e',
      );
    }
  }

  Future<void> applyFilter(CarFilterModel filter) async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, filter: filter, errorMessage: null);

    try {
      final filteredCars = await repository.getCars(filter: filter);
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, cars: filteredCars);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تطبيق الفلاتر: $e',
      );
    }
  }

  Future<void> setSearchQuery(String query) async {
    final updated = value.filter.copyWith(
      searchQuery: query,
      clearSearch: query.trim().isEmpty,
    );
    await applyFilter(updated);
  }

  Future<void> setBrand(String? brand) async {
    final updated = value.filter.copyWith(
      brand: brand,
      clearBrand: brand == null,
    );
    await applyFilter(updated);
  }

  Future<void> setBodyType(CarBodyType? bodyType) async {
    final updated = value.filter.copyWith(
      bodyType: bodyType,
      clearBodyType: bodyType == null,
    );
    await applyFilter(updated);
  }

  Future<void> setCondition(CarCondition? condition) async {
    final updated = value.filter.copyWith(
      condition: condition,
      clearCondition: condition == null,
    );
    await applyFilter(updated);
  }

  Future<void> toggleFavorite(String carId) async {
    if (_isDisposed) return;
    final isFav = await repository.toggleFavorite(carId);

    final updatedCars = value.cars.map((c) {
      if (c.id == carId) {
        return c.copyWith(isFavorite: isFav);
      }
      return c;
    }).toList();

    final updatedFeatured = value.featuredCars.map((c) {
      if (c.id == carId) {
        return c.copyWith(isFavorite: isFav);
      }
      return c;
    }).toList();

    value = value.copyWith(
      cars: updatedCars,
      featuredCars: updatedFeatured,
    );
  }
}
