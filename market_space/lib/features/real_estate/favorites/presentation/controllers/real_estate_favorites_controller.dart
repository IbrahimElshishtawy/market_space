import 'package:flutter/foundation.dart';

import '../../../data/models/real_estate_listing_model.dart';
import '../../data/models/favorite_property_model.dart';
import '../../data/repositories/real_estate_favorites_repository.dart';

class RealEstateFavoritesState {
  final bool isLoading;
  final List<FavoritePropertyModel> favorites;
  final Set<String> favoriteIds;
  final String searchQuery;
  final String? errorMessage;

  const RealEstateFavoritesState({
    this.isLoading = false,
    this.favorites = const [],
    this.favoriteIds = const {},
    this.searchQuery = '',
    this.errorMessage,
  });

  RealEstateFavoritesState copyWith({
    bool? isLoading,
    List<FavoritePropertyModel>? favorites,
    Set<String>? favoriteIds,
    String? searchQuery,
    String? errorMessage,
  }) {
    return RealEstateFavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  List<FavoritePropertyModel> get filteredFavorites {
    if (searchQuery.trim().isEmpty) return favorites;
    final q = searchQuery.trim().toLowerCase();
    return favorites.where((item) {
      return item.property.title.toLowerCase().contains(q) ||
          item.property.location.toLowerCase().contains(q);
    }).toList();
  }
}

class RealEstateFavoritesController
    extends ValueNotifier<RealEstateFavoritesState> {
  final RealEstateFavoritesRepository repository;
  bool _isDisposed = false;

  RealEstateFavoritesController({RealEstateFavoritesRepository? repository})
    : repository = repository ?? MockRealEstateFavoritesRepository(),
      super(const RealEstateFavoritesState(isLoading: true)) {
    loadFavorites();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadFavorites() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await repository.getFavorites();
      if (_isDisposed) return;
      final ids = list.map((item) => item.property.id).toSet();
      value = value.copyWith(
        isLoading: false,
        favorites: list,
        favoriteIds: ids,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل قائمة المفضلة: $e',
      );
    }
  }

  bool isFavorite(String propertyId) {
    return value.favoriteIds.contains(propertyId);
  }

  Future<bool> toggleFavorite(RealEstateListingModel property) async {
    if (_isDisposed) return false;

    final propertyId = property.id;
    final isCurrentlyFav = value.favoriteIds.contains(propertyId);

    // Optimistic Update
    final updatedIds = Set<String>.from(value.favoriteIds);
    final updatedFavorites = List<FavoritePropertyModel>.from(value.favorites);

    if (isCurrentlyFav) {
      updatedIds.remove(propertyId);
      updatedFavorites.removeWhere((item) => item.property.id == propertyId);
    } else {
      updatedIds.add(propertyId);
      updatedFavorites.insert(
        0,
        FavoritePropertyModel(
          id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
          userId: 'user-1',
          property: property.copyWith(isFavorite: true),
          createdAt: DateTime.now(),
        ),
      );
    }

    value = value.copyWith(
      favoriteIds: updatedIds,
      favorites: updatedFavorites,
    );

    try {
      final newStatus = await repository.toggleFavorite(property);
      return newStatus;
    } catch (e) {
      // Rollback on failure
      if (_isDisposed) return isCurrentlyFav;
      loadFavorites();
      return isCurrentlyFav;
    }
  }

  void setSearchQuery(String query) {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: query);
  }
}
