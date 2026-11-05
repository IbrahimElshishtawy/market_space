import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
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

class ApiCarsRepository implements CarsRepository {
  final ApiClient apiClient;
  final MockCarsRepository _fallback = MockCarsRepository();

  ApiCarsRepository({required this.apiClient});

  @override
  Future<List<CarListingModel>> getCars({
    CarFilterModel? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': 'cars',
        'limit': pageSize > 50 ? 50 : pageSize,
      };

      if (filter != null) {
        if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
          queryParams['q'] = filter.searchQuery!.trim();
        }
        if (filter.minPrice != null) {
          queryParams['minPrice'] = filter.minPrice;
        }
        if (filter.maxPrice != null) {
          queryParams['maxPrice'] = filter.maxPrice;
        }
      }

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
        return _fallback.getCars(filter: filter, page: page, pageSize: pageSize);
      }

      final formatter = NumberFormat.decimalPattern();
      return items.map<CarListingModel>((item) {
        final Map<String, dynamic> data =
            item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);

        final num priceNum = data['price'] is num
            ? data['price']
            : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
        final priceFormatted = '${formatter.format(priceNum)} ج.م';

        final attrs = data['attributes'] is Map
            ? Map<String, dynamic>.from(data['attributes'])
            : <String, dynamic>{};

        final brand = attrs['make']?.toString() ?? 'تويوتا';
        final model = attrs['model']?.toString() ?? 'كورولا';
        final year = attrs['year'] is int
            ? attrs['year'] as int
            : (int.tryParse(attrs['year']?.toString() ?? '2022') ?? 2022);
        final mileage = attrs['mileage_km'] is int
            ? attrs['mileage_km'] as int
            : (int.tryParse(attrs['mileage_km']?.toString() ?? '45000') ?? 45000);

        final mediaList = data['media'] as List?;
        final images = mediaList != null && mediaList.isNotEmpty
            ? mediaList
                .map((m) => m['publicUrl']?.toString() ?? '')
                .where((u) => u.isNotEmpty)
                .toList()
            : <String>[
                data['primaryImageUrl']?.toString() ??
                    'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80'
              ];

        final account = data['account'] is Map ? data['account'] as Map : {};
        final owner = account['owner'] is Map ? account['owner'] as Map : {};

        return CarListingModel(
          id: data['id']?.toString() ?? '',
          brand: brand,
          model: model,
          year: year,
          price: priceNum.toDouble(),
          formattedPrice: priceFormatted,
          condition: mileage > 5000 ? CarCondition.used : CarCondition.newCar,
          mileageKm: mileage,
          transmission: (attrs['transmission']?.toString() == 'مانيوال')
              ? CarTransmission.manual
              : CarTransmission.automatic,
          fuelType: CarFuelType.petrol,
          bodyType: CarBodyType.sedan,
          color: 'أبيض لؤلؤي',
          governorate: data['governorateName']?.toString() ?? 'القاهرة',
          city: data['cityName']?.toString() ?? data['areaName']?.toString() ?? 'مدينة نصر',
          description: data['description']?.toString() ?? 'سيارة بحالة الفابريكا بدون أي دهانات.',
          sellerName: account['displayName']?.toString() ?? data['sellerName']?.toString() ?? 'معرض سيارات معتمد',
          sellerPhone: owner['phone']?.toString() ?? data['sellerPhone']?.toString() ?? '+201001122334',
          sellerType: 'معرض معتمد',
          sellerRating: 4.9,
          images: images,
          engineCapacityCc: 1600,
          isFeatured: true,
          isFavorite: false,
          createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return _fallback.getCars(filter: filter, page: page, pageSize: pageSize);
    }
  }

  @override
  Future<CarListingModel> getCarById(String id) async {
    try {
      final response = await apiClient.get('/listings/$id');
      final dynamic resData = response.data;
      final Map<String, dynamic> data = (resData is Map && resData['data'] is Map)
          ? Map<String, dynamic>.from(resData['data'])
          : (resData is Map ? Map<String, dynamic>.from(resData) : {});

      if (data.isEmpty) {
        return _fallback.getCarById(id);
      }

      final formatter = NumberFormat.decimalPattern();
      final num priceNum = data['price'] is num
          ? data['price']
          : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
      final priceFormatted = '${formatter.format(priceNum)} ج.م';

      final attrs = data['attributes'] is Map
          ? Map<String, dynamic>.from(data['attributes'])
          : <String, dynamic>{};

      final brand = attrs['make']?.toString() ?? 'تويوتا';
      final model = attrs['model']?.toString() ?? 'كورولا';
      final year = attrs['year'] is int
          ? attrs['year'] as int
          : (int.tryParse(attrs['year']?.toString() ?? '2022') ?? 2022);
      final mileage = attrs['mileage_km'] is int
          ? attrs['mileage_km'] as int
          : (int.tryParse(attrs['mileage_km']?.toString() ?? '45000') ?? 45000);

      final mediaList = data['media'] as List?;
      final images = mediaList != null && mediaList.isNotEmpty
          ? mediaList
              .map((m) => m['publicUrl']?.toString() ?? '')
              .where((u) => u.isNotEmpty)
              .toList()
          : <String>[
              'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80'
            ];

      final account = data['account'] is Map ? data['account'] as Map : {};
      final owner = account['owner'] is Map ? account['owner'] as Map : {};

      return CarListingModel(
        id: data['id']?.toString() ?? id,
        brand: brand,
        model: model,
        year: year,
        price: priceNum.toDouble(),
        formattedPrice: priceFormatted,
        condition: mileage > 5000 ? CarCondition.used : CarCondition.newCar,
        mileageKm: mileage,
        transmission: (attrs['transmission']?.toString() == 'مانيوال')
            ? CarTransmission.manual
            : CarTransmission.automatic,
        fuelType: CarFuelType.petrol,
        bodyType: CarBodyType.sedan,
        color: 'أبيض لؤلؤي',
        governorate: data['governorateName']?.toString() ?? 'القاهرة',
        city: data['cityName']?.toString() ?? data['areaName']?.toString() ?? 'مدينة نصر',
        description: data['description']?.toString() ?? 'سيارة بحالة الفابريكا بدون أي دهانات.',
        sellerName: account['displayName']?.toString() ?? data['sellerName']?.toString() ?? 'معرض سيارات معتمد',
        sellerPhone: owner['phone']?.toString() ?? data['sellerPhone']?.toString() ?? '+201001122334',
        sellerType: 'معرض معتمد',
        sellerRating: 4.9,
        images: images,
        engineCapacityCc: 1600,
        isFeatured: true,
        isFavorite: false,
        createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return _fallback.getCarById(id);
    }
  }

  @override
  Future<List<CarListingModel>> getFeaturedCars() async {
    return getCars(pageSize: 6);
  }

  @override
  Future<List<CarBrandModel>> getBrands() async {
    return _fallback.getBrands();
  }

  @override
  Future<List<CarListingModel>> getSimilarCars(String carId) async {
    return _fallback.getSimilarCars(carId);
  }

  @override
  Future<bool> toggleFavorite(String carId) async {
    try {
      final res = await apiClient.post('/favorites/$carId');
      final data = res.data;
      if (data is Map && data['data'] != null && data['data']['favorited'] != null) {
        return data['data']['favorited'] as bool;
      }
      return true;
    } catch (_) {
      return _fallback.toggleFavorite(carId);
    }
  }
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
