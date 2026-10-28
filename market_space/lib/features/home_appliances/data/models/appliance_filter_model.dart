class ApplianceFilterModel {
  final String searchQuery;
  final String? selectedCategoryId;

  const ApplianceFilterModel({this.searchQuery = '', this.selectedCategoryId});

  ApplianceFilterModel copyWith({
    String? searchQuery,
    String? selectedCategoryId,
  }) {
    return ApplianceFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}
