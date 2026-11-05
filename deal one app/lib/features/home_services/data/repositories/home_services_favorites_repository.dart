abstract class HomeServicesFavoritesRepository {
  Future<List<String>> getFavoriteServiceIds();
  Future<List<String>> getFavoriteProviderIds();
  Future<bool> toggleFavoriteService(String serviceId);
  Future<bool> toggleFavoriteProvider(String providerId);
  bool isServiceFavorite(String serviceId);
  bool isProviderFavorite(String providerId);
}

class HomeServicesFavoritesRepositoryImpl implements HomeServicesFavoritesRepository {
  final Set<String> _favoriteServiceIds = {'srv-ac-wash', 'srv-plumb-leak'};
  final Set<String> _favoriteProviderIds = {'prov-fixit'};

  @override
  Future<List<String>> getFavoriteServiceIds() async {
    return _favoriteServiceIds.toList();
  }

  @override
  Future<List<String>> getFavoriteProviderIds() async {
    return _favoriteProviderIds.toList();
  }

  @override
  Future<bool> toggleFavoriteService(String serviceId) async {
    if (_favoriteServiceIds.contains(serviceId)) {
      _favoriteServiceIds.remove(serviceId);
      return false;
    } else {
      _favoriteServiceIds.add(serviceId);
      return true;
    }
  }

  @override
  Future<bool> toggleFavoriteProvider(String providerId) async {
    if (_favoriteProviderIds.contains(providerId)) {
      _favoriteProviderIds.remove(providerId);
      return false;
    } else {
      _favoriteProviderIds.add(providerId);
      return true;
    }
  }

  @override
  bool isServiceFavorite(String serviceId) => _favoriteServiceIds.contains(serviceId);

  @override
  bool isProviderFavorite(String providerId) => _favoriteProviderIds.contains(providerId);
}
