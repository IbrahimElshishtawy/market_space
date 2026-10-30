import 'package:flutter/foundation.dart';

import '../../../data/models/real_estate_listing_model.dart';
import '../../../data/repositories/real_estate_repository.dart';

class RealEstateMapState {
  final bool isLoading;
  final List<RealEstateListingModel> allListings;
  final List<RealEstateListingModel> filteredListings;
  final RealEstateListingModel? selectedProperty;
  final RealEstateType selectedType;
  final String searchQuery;
  final bool showSearchAreaButton;
  final String? errorMessage;

  const RealEstateMapState({
    this.isLoading = false,
    this.allListings = const [],
    this.filteredListings = const [],
    this.selectedProperty,
    this.selectedType = RealEstateType.all,
    this.searchQuery = '',
    this.showSearchAreaButton = false,
    this.errorMessage,
  });

  RealEstateMapState copyWith({
    bool? isLoading,
    List<RealEstateListingModel>? allListings,
    List<RealEstateListingModel>? filteredListings,
    RealEstateListingModel? selectedProperty,
    bool clearSelectedProperty = false,
    RealEstateType? selectedType,
    String? searchQuery,
    bool? showSearchAreaButton,
    String? errorMessage,
  }) {
    return RealEstateMapState(
      isLoading: isLoading ?? this.isLoading,
      allListings: allListings ?? this.allListings,
      filteredListings: filteredListings ?? this.filteredListings,
      selectedProperty: clearSelectedProperty
          ? null
          : (selectedProperty ?? this.selectedProperty),
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      showSearchAreaButton: showSearchAreaButton ?? this.showSearchAreaButton,
      errorMessage: errorMessage,
    );
  }
}

class RealEstateMapController extends ValueNotifier<RealEstateMapState> {
  final RealEstateRepository repository;
  bool _isDisposed = false;

  RealEstateMapController({RealEstateRepository? repository})
    : repository = repository ?? MockRealEstateRepository(),
      super(const RealEstateMapState(isLoading: true)) {
    loadMapProperties();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadMapProperties() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await repository.getListings();
      if (_isDisposed) return;
      final validItems = items
          .where((i) => i.latitude != null && i.longitude != null)
          .toList();
      value = value.copyWith(
        isLoading: false,
        allListings: validItems,
        filteredListings: _applyFilters(
          validItems,
          value.selectedType,
          value.searchQuery,
        ),
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل عقارات الخريطة: $e',
      );
    }
  }

  void selectProperty(RealEstateListingModel? property) {
    if (_isDisposed) return;
    if (property == null) {
      value = value.copyWith(clearSelectedProperty: true);
    } else {
      value = value.copyWith(selectedProperty: property);
    }
  }

  void setFilterType(RealEstateType type) {
    if (_isDisposed) return;
    final filtered = _applyFilters(value.allListings, type, value.searchQuery);
    value = value.copyWith(
      selectedType: type,
      filteredListings: filtered,
      clearSelectedProperty: true,
    );
  }

  void setSearchQuery(String query) {
    if (_isDisposed) return;
    final filtered = _applyFilters(
      value.allListings,
      value.selectedType,
      query,
    );
    value = value.copyWith(
      searchQuery: query,
      filteredListings: filtered,
      clearSelectedProperty: true,
    );
  }

  void onCameraMoved() {
    if (_isDisposed) return;
    if (!value.showSearchAreaButton) {
      value = value.copyWith(showSearchAreaButton: true);
    }
  }

  void searchCurrentArea() {
    if (_isDisposed) return;
    value = value.copyWith(showSearchAreaButton: false, isLoading: true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false);
    });
  }

  List<RealEstateListingModel> _applyFilters(
    List<RealEstateListingModel> items,
    RealEstateType type,
    String query,
  ) {
    var result = items;
    if (type != RealEstateType.all) {
      result = result.where((item) => item.type == type).toList();
    }
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((item) {
        return item.title.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }
}
