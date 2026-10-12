import 'package:flutter/foundation.dart';

import '../../data/models/real_estate_filter_model.dart';
import '../../data/models/real_estate_listing_model.dart';
import '../../data/repositories/real_estate_repository.dart';

class RealEstateState {
  final bool isLoading;
  final String? errorMessage;
  final List<RealEstateListingModel> listings;
  final RealEstateFilterModel filter;

  const RealEstateState({
    this.isLoading = true,
    this.errorMessage,
    this.listings = const [],
    this.filter = const RealEstateFilterModel(),
  });

  RealEstateState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<RealEstateListingModel>? listings,
    RealEstateFilterModel? filter,
  }) {
    return RealEstateState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      listings: listings ?? this.listings,
      filter: filter ?? this.filter,
    );
  }
}

class RealEstateController extends ValueNotifier<RealEstateState> {
  final RealEstateRepository repository;

  RealEstateController({RealEstateRepository? repository})
    : repository = repository ?? MockRealEstateRepository(),
      super(const RealEstateState());

  Future<void> loadListings() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getListings(filter: value.filter);
      value = value.copyWith(isLoading: false, listings: items);
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilterType(RealEstateType type) {
    if (value.filter.selectedType == type) return;
    final updatedFilter = value.filter.copyWith(selectedType: type);
    value = value.copyWith(filter: updatedFilter);
    loadListings();
  }

  void setSearchQuery(String query) {
    final updatedFilter = value.filter.copyWith(searchQuery: query);
    value = value.copyWith(filter: updatedFilter);
    loadListings();
  }

  Future<void> toggleFavorite(String listingId) async {
    final isFav = await repository.toggleFavorite(listingId);
    final updatedListings = value.listings.map((item) {
      if (item.id == listingId) {
        return item.copyWith(isFavorite: isFav);
      }
      return item;
    }).toList();

    value = value.copyWith(listings: updatedListings);
  }
}
