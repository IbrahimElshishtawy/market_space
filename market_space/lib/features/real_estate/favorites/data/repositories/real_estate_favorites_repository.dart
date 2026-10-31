import 'package:flutter/widgets.dart';

import '../../../data/mock/mock_real_estate_data.dart';
import '../../../data/models/real_estate_listing_model.dart';
import '../models/favorite_property_model.dart';

abstract class RealEstateFavoritesRepository {
  Future<List<FavoritePropertyModel>> getFavorites({String? userId});
  Future<bool> isFavorite(String propertyId, {String? userId});
  Future<FavoritePropertyModel> addFavorite(
    RealEstateListingModel property, {
    String? userId,
  });
  Future<bool> removeFavorite(String propertyId, {String? userId});
  Future<bool> toggleFavorite(
    RealEstateListingModel property, {
    String? userId,
  });
}

class MockRealEstateFavoritesRepository
    implements RealEstateFavoritesRepository {
  final Duration simulatedDelay;

  MockRealEstateFavoritesRepository({
    Duration? simulatedDelay,
  }) : simulatedDelay = simulatedDelay ??
            ((WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test') ||
                    WidgetsBinding.instance is! WidgetsFlutterBinding)
                ? Duration.zero
                : const Duration(milliseconds: 150));

  static final List<FavoritePropertyModel> _favoritesStore = [
    FavoritePropertyModel(
      id: 'fav-3',
      userId: 'user-1',
      property: MockRealEstateData.listings.firstWhere((i) => i.id == 'aqar-3'),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<FavoritePropertyModel>> getFavorites({String? userId}) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    final currentUserId = userId ?? 'user-1';
    return _favoritesStore
        .where((item) => item.userId == currentUserId)
        .toList();
  }

  @override
  Future<bool> isFavorite(String propertyId, {String? userId}) async {
    final currentUserId = userId ?? 'user-1';
    return _favoritesStore.any(
      (item) => item.property.id == propertyId && item.userId == currentUserId,
    );
  }

  @override
  Future<FavoritePropertyModel> addFavorite(
    RealEstateListingModel property, {
    String? userId,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    final currentUserId = userId ?? 'user-1';

    final existingIndex = _favoritesStore.indexWhere(
      (item) => item.property.id == property.id && item.userId == currentUserId,
    );

    if (existingIndex != -1) {
      return _favoritesStore[existingIndex];
    }

    final newFav = FavoritePropertyModel(
      id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      property: property.copyWith(isFavorite: true),
      createdAt: DateTime.now(),
    );

    _favoritesStore.insert(0, newFav);
    return newFav;
  }

  @override
  Future<bool> removeFavorite(String propertyId, {String? userId}) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
    final currentUserId = userId ?? 'user-1';

    _favoritesStore.removeWhere(
      (item) => item.property.id == propertyId && item.userId == currentUserId,
    );
    return true;
  }

  @override
  Future<bool> toggleFavorite(
    RealEstateListingModel property, {
    String? userId,
  }) async {
    final currentlyFav = await isFavorite(property.id, userId: userId);
    if (currentlyFav) {
      await removeFavorite(property.id, userId: userId);
      return false;
    } else {
      await addFavorite(property, userId: userId);
      return true;
    }
  }
}
