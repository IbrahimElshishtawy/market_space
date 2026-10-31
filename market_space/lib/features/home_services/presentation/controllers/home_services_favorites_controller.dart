import 'package:flutter/foundation.dart';

import '../../data/models/home_service_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/repositories/home_services_favorites_repository.dart';
import '../../data/repositories/home_services_repository.dart';

class HomeServicesFavoritesController extends ChangeNotifier {
  final HomeServicesFavoritesRepository _favoritesRepository;
  final HomeServicesRepository _servicesRepository;

  HomeServicesFavoritesController({
    required HomeServicesFavoritesRepository favoritesRepository,
    required HomeServicesRepository servicesRepository,
  })  : _favoritesRepository = favoritesRepository,
        _servicesRepository = servicesRepository {
    loadFavorites();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HomeServiceModel> _favoriteServices = [];
  List<HomeServiceModel> get favoriteServices => _favoriteServices;

  List<ServiceProviderModel> _favoriteProviders = [];
  List<ServiceProviderModel> get favoriteProviders => _favoriteProviders;

  final Set<String> _serviceIds = {};
  final Set<String> _providerIds = {};

  bool isServiceFavorite(String serviceId) => _serviceIds.contains(serviceId);
  bool isProviderFavorite(String providerId) => _providerIds.contains(providerId);

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final sIds = await _favoritesRepository.getFavoriteServiceIds();
      final pIds = await _favoritesRepository.getFavoriteProviderIds();

      _serviceIds.clear();
      _serviceIds.addAll(sIds);

      _providerIds.clear();
      _providerIds.addAll(pIds);

      final allServices = await _servicesRepository.getServices();
      final allProviders = await _servicesRepository.getProviders();

      _favoriteServices = allServices.where((s) => _serviceIds.contains(s.id)).toList();
      _favoriteProviders = allProviders.where((p) => _providerIds.contains(p.id)).toList();
      _isLoading = false;
    } catch (_) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> toggleService(HomeServiceModel service) async {
    final serviceId = service.id;
    final isFav = _serviceIds.contains(serviceId);

    // Optimistic update
    if (isFav) {
      _serviceIds.remove(serviceId);
      _favoriteServices.removeWhere((s) => s.id == serviceId);
    } else {
      _serviceIds.add(serviceId);
      if (!_favoriteServices.any((s) => s.id == serviceId)) {
        _favoriteServices.add(service);
      }
    }
    notifyListeners();

    try {
      await _favoritesRepository.toggleFavoriteService(serviceId);
    } catch (_) {
      // Rollback on failure
      if (isFav) {
        _serviceIds.add(serviceId);
        _favoriteServices.add(service);
      } else {
        _serviceIds.remove(serviceId);
        _favoriteServices.removeWhere((s) => s.id == serviceId);
      }
      notifyListeners();
    }
  }

  Future<void> toggleProvider(ServiceProviderModel provider) async {
    final providerId = provider.id;
    final isFav = _providerIds.contains(providerId);

    // Optimistic update
    if (isFav) {
      _providerIds.remove(providerId);
      _favoriteProviders.removeWhere((p) => p.id == providerId);
    } else {
      _providerIds.add(providerId);
      if (!_favoriteProviders.any((p) => p.id == providerId)) {
        _favoriteProviders.add(provider);
      }
    }
    notifyListeners();

    try {
      await _favoritesRepository.toggleFavoriteProvider(providerId);
    } catch (_) {
      // Rollback on failure
      if (isFav) {
        _providerIds.add(providerId);
        _favoriteProviders.add(provider);
      } else {
        _providerIds.remove(providerId);
        _favoriteProviders.removeWhere((p) => p.id == providerId);
      }
      notifyListeners();
    }
  }
}
