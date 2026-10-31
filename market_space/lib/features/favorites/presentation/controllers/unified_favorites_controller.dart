import 'package:flutter/foundation.dart';

import '../../data/models/unified_favorite_item_model.dart';
import '../../data/repositories/unified_favorites_repository.dart';

class UnifiedFavoritesState {
  final bool isLoading;
  final FavoriteSectorFilter selectedSector;
  final String searchQuery;
  final List<UnifiedFavoriteItem> favorites;
  final Set<String> favoriteItemIds;
  final String? errorMessage;

  const UnifiedFavoritesState({
    this.isLoading = false,
    this.selectedSector = FavoriteSectorFilter.all,
    this.searchQuery = '',
    this.favorites = const [],
    this.favoriteItemIds = const {},
    this.errorMessage,
  });

  UnifiedFavoritesState copyWith({
    bool? isLoading,
    FavoriteSectorFilter? selectedSector,
    String? searchQuery,
    List<UnifiedFavoriteItem>? favorites,
    Set<String>? favoriteItemIds,
    String? errorMessage,
  }) {
    return UnifiedFavoritesState(
      isLoading: isLoading ?? this.isLoading,
      selectedSector: selectedSector ?? this.selectedSector,
      searchQuery: searchQuery ?? this.searchQuery,
      favorites: favorites ?? this.favorites,
      favoriteItemIds: favoriteItemIds ?? this.favoriteItemIds,
      errorMessage: errorMessage,
    );
  }
}

class UnifiedFavoritesController extends ValueNotifier<UnifiedFavoritesState> {
  final UnifiedFavoritesRepository repository;
  bool _isDisposed = false;

  UnifiedFavoritesController({UnifiedFavoritesRepository? repository})
      : repository = repository ?? UnifiedFavoritesRepositoryImpl(),
        super(const UnifiedFavoritesState(isLoading: true)) {
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
      final list = await repository.getFavorites(
        sector: value.selectedSector,
        searchQuery: value.searchQuery,
      );
      if (_isDisposed) return;
      final ids = list.map((e) => e.itemId).toSet();
      value = value.copyWith(
        isLoading: false,
        favorites: list,
        favoriteItemIds: ids,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل قائمة المفضلة: $e',
      );
    }
  }

  Future<void> setSectorFilter(FavoriteSectorFilter sector) async {
    if (_isDisposed || value.selectedSector == sector) return;
    value = value.copyWith(selectedSector: sector, isLoading: true);
    await loadFavorites();
  }

  Future<void> setSearchQuery(String query) async {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: query);
    await loadFavorites();
  }

  bool isFavorite(String itemId) {
    return value.favoriteItemIds.contains(itemId);
  }

  Future<void> removeFavorite(UnifiedFavoriteItem item) async {
    if (_isDisposed) return;

    // Optimistic Update
    final updatedList = List<UnifiedFavoriteItem>.from(value.favorites)
      ..removeWhere((e) => e.itemId == item.itemId);
    final updatedIds = Set<String>.from(value.favoriteItemIds)..remove(item.itemId);

    value = value.copyWith(
      favorites: updatedList,
      favoriteItemIds: updatedIds,
    );

    try {
      await repository.removeFavorite(item.itemId);
    } catch (e) {
      // Rollback on failure
      if (_isDisposed) return;
      await loadFavorites();
    }
  }

  Future<void> toggleFavorite(UnifiedFavoriteItem item) async {
    if (_isDisposed) return;
    if (isFavorite(item.itemId)) {
      await removeFavorite(item);
    } else {
      final updatedList = [item, ...value.favorites];
      final updatedIds = Set<String>.from(value.favoriteItemIds)..add(item.itemId);
      value = value.copyWith(favorites: updatedList, favoriteItemIds: updatedIds);
      try {
        await repository.addFavorite(item);
      } catch (e) {
        if (_isDisposed) return;
        await loadFavorites();
      }
    }
  }
}
