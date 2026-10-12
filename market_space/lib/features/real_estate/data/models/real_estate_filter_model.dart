import 'real_estate_listing_model.dart';

class RealEstateFilterModel {
  final RealEstateType selectedType;
  final String searchQuery;
  final bool isSortAscending;

  const RealEstateFilterModel({
    this.selectedType = RealEstateType.all,
    this.searchQuery = '',
    this.isSortAscending = true,
  });

  RealEstateFilterModel copyWith({
    RealEstateType? selectedType,
    String? searchQuery,
    bool? isSortAscending,
  }) {
    return RealEstateFilterModel(
      selectedType: selectedType ?? this.selectedType,
      searchQuery: searchQuery ?? this.searchQuery,
      isSortAscending: isSortAscending ?? this.isSortAscending,
    );
  }
}
