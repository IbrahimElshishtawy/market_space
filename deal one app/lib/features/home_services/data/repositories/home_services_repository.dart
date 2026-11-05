import '../../../../core/network/api_client.dart';
import '../mock/mock_home_services_data.dart';
import '../models/home_service_model.dart';
import '../models/service_provider_model.dart';

abstract class HomeServicesRepository {
  Future<List<HomeServiceCategoryModel>> getCategories();
  Future<List<HomeServiceModel>> getServices({
    String? categoryId,
    String? searchQuery,
    PricingType? pricingType,
    String? providerId,
    String? area,
    double? minRating,
  });
  Future<HomeServiceModel?> getServiceById(String serviceId);
  Future<List<ServiceProviderModel>> getProviders({
    String? specialty,
    String? area,
  });
  Future<ServiceProviderModel?> getProviderById(String providerId);
  Future<List<TechnicianModel>> getTechnicians({
    String? providerId,
    String? specialty,
  });
  Future<TechnicianModel?> getTechnicianById(String technicianId);
  Future<List<HomeServiceModel>> getPopularServices();
  Future<List<HomeServiceModel>> getFeaturedServices();
  Future<List<HomeServiceModel>> getNewServices();
  Future<List<HomeServiceModel>> getRecommendedServices({
    String? location,
    List<String>? recentServiceIds,
  });
}

class HomeServicesRepositoryImpl implements HomeServicesRepository {
  final List<HomeServiceCategoryModel> _categories = MockHomeServicesData.categories;
  final List<HomeServiceModel> _services = MockHomeServicesData.services;
  final List<ServiceProviderModel> _providers = MockHomeServicesData.providers;
  final List<TechnicianModel> _technicians = MockHomeServicesData.technicians;

  @override
  Future<List<HomeServiceCategoryModel>> getCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<HomeServiceModel>> getServices({
    String? categoryId,
    String? searchQuery,
    PricingType? pricingType,
    String? providerId,
    String? area,
    double? minRating,
  }) async {
    return _services.where((s) {
      if (categoryId != null && s.categoryId != categoryId) {
        return false;
      }
      if (pricingType != null && s.pricingType != pricingType) {
        return false;
      }
      if (providerId != null && !s.availableProviderIds.contains(providerId)) {
        return false;
      }
      if (minRating != null && s.rating < minRating) {
        return false;
      }
      if (area != null && s.coverageAreas.isNotEmpty) {
        final matchesArea = s.coverageAreas.any(
          (a) => a.contains(area) || a == 'كافة المناطق' || a.contains('القاهرة الكبرى'),
        );
        if (!matchesArea) return false;
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchTitle = s.title.toLowerCase().contains(query);
        final matchDesc = s.shortDescription.toLowerCase().contains(query);
        final matchDetails = s.detailedDescription.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchDetails) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<HomeServiceModel?> getServiceById(String serviceId) async {
    try {
      return _services.firstWhere((s) => s.id == serviceId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceProviderModel>> getProviders({
    String? specialty,
    String? area,
  }) async {
    return _providers.where((p) {
      if (specialty != null && !p.specialties.contains(specialty)) {
        return false;
      }
      if (area != null) {
        final matchesArea = p.coverageAreas.any(
          (a) => a.contains(area) || a.contains('كافة مناطق') || a.contains('المحافظات'),
        );
        if (!matchesArea) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<ServiceProviderModel?> getProviderById(String providerId) async {
    try {
      return _providers.firstWhere((p) => p.id == providerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TechnicianModel>> getTechnicians({
    String? providerId,
    String? specialty,
  }) async {
    return _technicians.where((t) {
      if (providerId != null && t.providerId != providerId) {
        return false;
      }
      if (specialty != null && !t.specialty.contains(specialty)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<TechnicianModel?> getTechnicianById(String technicianId) async {
    try {
      return _technicians.firstWhere((t) => t.id == technicianId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<HomeServiceModel>> getPopularServices() async {
    return _services.where((s) => s.isPopular).toList();
  }

  @override
  Future<List<HomeServiceModel>> getFeaturedServices() async {
    return _services.where((s) => s.isFeatured).toList();
  }

  @override
  Future<List<HomeServiceModel>> getNewServices() async {
    return _services.where((s) => s.isNew).toList();
  }

  @override
  Future<List<HomeServiceModel>> getRecommendedServices({
    String? location,
    List<String>? recentServiceIds,
  }) async {
    // Basic heuristics: prioritize popular services or services matching category of recent items
    return _services.take(4).toList();
  }
}

class ApiHomeServicesRepository implements HomeServicesRepository {
  final ApiClient apiClient;
  final HomeServicesRepositoryImpl _fallback = HomeServicesRepositoryImpl();

  ApiHomeServicesRepository({required this.apiClient});

  @override
  Future<List<HomeServiceCategoryModel>> getCategories() => _fallback.getCategories();

  @override
  Future<List<HomeServiceModel>> getServices({
    String? categoryId,
    String? searchQuery,
    PricingType? pricingType,
    String? providerId,
    String? area,
    double? minRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': categoryId != null && categoryId.isNotEmpty ? categoryId : 'services',
        'limit': 50,
      };
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['q'] = searchQuery.trim();
      }

      final res = await apiClient.get('/listings', queryParameters: queryParams);
      final dynamic resData = res.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isNotEmpty) {
        return items.map<HomeServiceModel>((item) {
          final data = item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);
          final num priceNum = data['price'] is num ? data['price'] : (num.tryParse(data['price']?.toString() ?? '250') ?? 250);
          final mediaList = data['media'] as List?;
          final images = <String>[];
          if (mediaList != null) {
            for (final m in mediaList) {
              if (m is Map && m['publicUrl'] != null) {
                images.add(m['publicUrl'].toString());
              }
            }
          }
          if (images.isEmpty) {
            images.add('https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80');
          }

          return HomeServiceModel(
            id: data['id']?.toString() ?? '',
            categoryId: data['categoryId']?.toString() ?? 'services',
            title: data['title']?.toString() ?? 'خدمة منزلية وهندسية',
            shortDescription: data['description']?.toString() ?? 'خدمات منزلية وهندسية متكاملة بأعلى جودة واحترافية',
            detailedDescription: data['description']?.toString() ?? 'خدمات منزلية وهندسية متكاملة بأعلى جودة واحترافية وضمان معتمد',
            pricingType: PricingType.fixed,
            basePrice: priceNum.toDouble(),
            estimatedDuration: 'ساعتان تقريباً',
            rating: 4.9,
            reviewsCount: 38,
            coverageAreas: const ['القاهرة', 'الجيزة', 'الإسكندرية', 'كافة المحافظات'],
            images: images,
            isPopular: true,
            isNew: true,
            isFeatured: true,
            warrantyText: 'ضمان معتمد 30 يوماً على كافة أعمال الصيانة والتركيب',
          );
        }).toList();
      }
    } catch (_) {
      // Fallback on error
    }
    return _fallback.getServices(
      categoryId: categoryId,
      searchQuery: searchQuery,
      pricingType: pricingType,
      providerId: providerId,
      area: area,
      minRating: minRating,
    );
  }

  @override
  Future<HomeServiceModel?> getServiceById(String serviceId) => _fallback.getServiceById(serviceId);

  @override
  Future<List<ServiceProviderModel>> getProviders({String? specialty, String? area}) =>
      _fallback.getProviders(specialty: specialty, area: area);

  @override
  Future<ServiceProviderModel?> getProviderById(String providerId) => _fallback.getProviderById(providerId);

  @override
  Future<List<TechnicianModel>> getTechnicians({String? providerId, String? specialty}) =>
      _fallback.getTechnicians(providerId: providerId, specialty: specialty);

  @override
  Future<TechnicianModel?> getTechnicianById(String technicianId) => _fallback.getTechnicianById(technicianId);

  @override
  Future<List<HomeServiceModel>> getPopularServices() => getServices();

  @override
  Future<List<HomeServiceModel>> getFeaturedServices() => getServices();

  @override
  Future<List<HomeServiceModel>> getNewServices() => getServices();

  @override
  Future<List<HomeServiceModel>> getRecommendedServices({String? location, List<String>? recentServiceIds}) =>
      getServices();
}
