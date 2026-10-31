import '../mock/mock_cars_data.dart';
import '../models/car_brand_model.dart';
import '../models/car_filter_model.dart';
import '../models/car_listing_model.dart';

abstract class CarsRepository {
  Future<List<CarListingModel>> getCars({
    CarFilterModel? filter,
    int page = 1,
    int pageSize = 20,
  });

  Future<CarListingModel> getCarById(String id);
  Future<List<CarListingModel>> getFeaturedCars();
  Future<List<CarBrandModel>> getBrands();
  Future<List<CarListingModel>> getSimilarCars(String carId);
  Future<bool> toggleFavorite(String carId);
}

class MockCarsRepository implements CarsRepository {
  final List<CarListingModel> _cars;
  final List<CarBrandModel> _brands;
  final Duration simulatedDelay;

  MockCarsRepository({
    List<CarListingModel>? cars,
    List<CarBrandModel>? brands,
    this.simulatedDelay = Duration.zero,
  })  : _cars = List.from(cars ?? MockCarsData.listings),
        _brands = List.from(brands ?? MockCarsData.brands);

  @override
  Future<List<CarListingModel>> getCars({
    CarFilterModel? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    var results = List<CarListingModel>.from(_cars);

    if (filter != null) {
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        final q = filter.searchQuery!.trim().toLowerCase();
        results = results.where((c) {
          return c.brand.toLowerCase().contains(q) ||
              c.model.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.governorate.toLowerCase().contains(q) ||
              c.city.toLowerCase().contains(q);
        }).toList();
      }

      if (filter.brand != null && filter.brand!.isNotEmpty) {
        results = results
            .where((c) => c.brand.toLowerCase() == filter.brand!.toLowerCase())
            .toList();
      }

      if (filter.condition != null) {
        results = results.where((c) => c.condition == filter.condition).toList();
      }

      if (filter.bodyType != null) {
        results = results.where((c) => c.bodyType == filter.bodyType).toList();
      }

      if (filter.fuelType != null) {
        results = results.where((c) => c.fuelType == filter.fuelType).toList();
      }

      if (filter.transmission != null) {
        results = results
            .where((c) => c.transmission == filter.transmission)
            .toList();
      }

      if (filter.governorate != null && filter.governorate!.isNotEmpty) {
        results = results
            .where((c) => c.governorate == filter.governorate)
            .toList();
      }

      if (filter.minPrice != null) {
        results = results.where((c) => c.price >= filter.minPrice!).toList();
      }

      if (filter.maxPrice != null) {
        results = results.where((c) => c.price <= filter.maxPrice!).toList();
      }

      if (filter.minYear != null) {
        results = results.where((c) => c.year >= filter.minYear!).toList();
      }

      if (filter.maxYear != null) {
        results = results.where((c) => c.year <= filter.maxYear!).toList();
      }

      if (filter.maxMileage != null) {
        results = results.where((c) => c.mileageKm <= filter.maxMileage!).toList();
      }

      switch (filter.sortBy) {
        case CarSortBy.newest:
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case CarSortBy.priceLowToHigh:
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case CarSortBy.priceHighToLow:
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case CarSortBy.mileageLowest:
          results.sort((a, b) => a.mileageKm.compareTo(b.mileageKm));
          break;
        case CarSortBy.yearNewest:
          results.sort((a, b) => b.year.compareTo(a.year));
          break;
      }
    } else {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= results.length) {
      return [];
    }
    final endIndex = (startIndex + pageSize > results.length)
        ? results.length
        : startIndex + pageSize;

    return results.sublist(startIndex, endIndex);
  }

  @override
  Future<CarListingModel> getCarById(String id) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _cars.firstWhere(
      (c) => c.id == id,
      orElse: () => _cars.first,
    );
  }

  @override
  Future<List<CarListingModel>> getFeaturedCars() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _cars.where((c) => c.isFeatured).toList();
  }

  @override
  Future<List<CarBrandModel>> getBrands() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return List.unmodifiable(_brands);
  }

  @override
  Future<List<CarListingModel>> getSimilarCars(String carId) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    final car = await getCarById(carId);
    return MockCarsData.getSimilarCars(car);
  }

  @override
  Future<bool> toggleFavorite(String carId) async {
    final index = _cars.indexWhere((c) => c.id == carId);
    if (index != -1) {
      final current = _cars[index];
      _cars[index] = current.copyWith(isFavorite: !current.isFavorite);
      return _cars[index].isFavorite;
    }
    return false;
  }
}
