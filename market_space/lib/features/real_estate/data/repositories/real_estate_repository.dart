import '../mock/mock_real_estate_data.dart';
import '../models/real_estate_detail_model.dart';
import '../models/real_estate_filter_model.dart';
import '../models/real_estate_listing_model.dart';

abstract class RealEstateRepository {
  Future<List<RealEstateListingModel>> getListings({
    RealEstateFilterModel? filter,
  });
  Future<RealEstateDetailModel> getListingDetails(String listingId);
  Future<bool> toggleFavorite(String listingId);
}

class MockRealEstateRepository implements RealEstateRepository {
  final List<RealEstateListingModel> _cache = List.from(
    MockRealEstateData.listings,
  );

  @override
  Future<List<RealEstateListingModel>> getListings({
    RealEstateFilterModel? filter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var results = List<RealEstateListingModel>.from(_cache);

    if (filter != null) {
      if (filter.selectedType == RealEstateType.forSale) {
        results = results
            .where((item) => item.type == RealEstateType.forSale)
            .toList();
      } else if (filter.selectedType == RealEstateType.forRent) {
        results = results
            .where((item) => item.type == RealEstateType.forRent)
            .toList();
      }

      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.trim().toLowerCase();
        results = results.where((item) {
          return item.title.toLowerCase().contains(query) ||
              item.location.toLowerCase().contains(query);
        }).toList();
      }
    }

    return results;
  }

  @override
  Future<RealEstateDetailModel> getListingDetails(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final detail = MockRealEstateData.getDetailById(listingId);
    final cachedItem = _cache.firstWhere(
      (element) => element.id == listingId,
      orElse: () => _cache.first,
    );
    return detail.copyWith(isFavorite: cachedItem.isFavorite);
  }

  @override
  Future<bool> toggleFavorite(String listingId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _cache.indexWhere((element) => element.id == listingId);
    if (index != -1) {
      final current = _cache[index];
      _cache[index] = current.copyWith(isFavorite: !current.isFavorite);
      return _cache[index].isFavorite;
    }
    return false;
  }
}
