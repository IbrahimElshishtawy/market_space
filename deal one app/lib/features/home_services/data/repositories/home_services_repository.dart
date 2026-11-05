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
