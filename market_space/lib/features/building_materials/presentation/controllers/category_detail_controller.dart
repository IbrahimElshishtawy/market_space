import 'package:flutter/foundation.dart';

import '../../data/models/category_detail_model.dart';
import '../../data/repositories/building_materials_repository.dart';

class CategoryDetailState {
  final bool isLoading;
  final String? errorMessage;
  final CategoryDetailModel? categoryDetail;
  final String selectedFilter;

  const CategoryDetailState({
    this.isLoading = true,
    this.errorMessage,
    this.categoryDetail,
    this.selectedFilter = 'الكل',
  });

  CategoryDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    CategoryDetailModel? categoryDetail,
    String? selectedFilter,
  }) {
    return CategoryDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categoryDetail: categoryDetail ?? this.categoryDetail,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class CategoryDetailController extends ValueNotifier<CategoryDetailState> {
  final String categoryId;
  final BuildingMaterialsRepository repository;

  CategoryDetailController({
    required this.categoryId,
    BuildingMaterialsRepository? repository,
  })  : repository = repository ?? const BuildingMaterialsRepositoryImpl(),
        super(const CategoryDetailState());

  Future<void> loadData() async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final detail = await repository.getCategoryDetail(
        categoryId,
        selectedFilter: value.selectedFilter,
      );

      value = value.copyWith(
        isLoading: false,
        categoryDetail: detail,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> selectFilter(String filter) async {
    value = value.copyWith(selectedFilter: filter);
    try {
      final updatedDetail = await repository.getCategoryDetail(
        categoryId,
        selectedFilter: filter,
      );
      value = value.copyWith(categoryDetail: updatedDetail);
    } catch (e) {
      value = value.copyWith(errorMessage: e.toString());
    }
  }
}
