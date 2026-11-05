import 'real_estate_listing_model.dart';

class RealEstateFilterModel {
  final RealEstateType selectedType;
  final String searchQuery;
  final bool isSortAscending;

  // Granular Filter Options matching UI Screenshot
  final Set<String> selectedPropertyTypes;
  final Set<String> selectedRoomCounts;
  final Set<String> selectedFinishTypes;
  final Set<String> selectedFeatures;
  final Set<String> selectedAreaRanges;
  final double? minPrice;
  final double? maxPrice;

  const RealEstateFilterModel({
    this.selectedType = RealEstateType.all,
    this.searchQuery = '',
    this.isSortAscending = true,
    this.selectedPropertyTypes = const {},
    this.selectedRoomCounts = const {},
    this.selectedFinishTypes = const {},
    this.selectedFeatures = const {},
    this.selectedAreaRanges = const {},
    this.minPrice,
    this.maxPrice,
  });

  bool get hasActiveFilters =>
      selectedType != RealEstateType.all ||
      searchQuery.trim().isNotEmpty ||
      selectedPropertyTypes.isNotEmpty ||
      selectedRoomCounts.isNotEmpty ||
      selectedFinishTypes.isNotEmpty ||
      selectedFeatures.isNotEmpty ||
      selectedAreaRanges.isNotEmpty ||
      minPrice != null ||
      maxPrice != null;

  RealEstateFilterModel copyWith({
    RealEstateType? selectedType,
    String? searchQuery,
    bool? isSortAscending,
    Set<String>? selectedPropertyTypes,
    Set<String>? selectedRoomCounts,
    Set<String>? selectedFinishTypes,
    Set<String>? selectedFeatures,
    Set<String>? selectedAreaRanges,
    double? minPrice,
    double? maxPrice,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return RealEstateFilterModel(
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      isSortAscending: isSortAscending ?? this.isSortAscending,
      selectedPropertyTypes:
          selectedPropertyTypes ?? this.selectedPropertyTypes,
      selectedRoomCounts: selectedRoomCounts ?? this.selectedRoomCounts,
      selectedFinishTypes: selectedFinishTypes ?? this.selectedFinishTypes,
      selectedFeatures: selectedFeatures ?? this.selectedFeatures,
      selectedAreaRanges: selectedAreaRanges ?? this.selectedAreaRanges,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  RealEstateFilterModel reset() {
    return const RealEstateFilterModel();
  }
}
