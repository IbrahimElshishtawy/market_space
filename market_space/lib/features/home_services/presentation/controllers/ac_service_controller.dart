import 'package:flutter/foundation.dart';

import '../../data/models/ac_part_item_model.dart';
import '../../data/models/ac_promo_banner_model.dart';
import '../../data/models/ac_service_item_model.dart';
import '../../data/repositories/ac_service_repository.dart';

class AcServiceState {
  final bool isLoading;
  final String? errorMessage;
  final String selectedFilter;
  final AcPromoBannerModel? promoBanner;
  final List<String> filterChips;
  final List<AcServiceItemModel> services;
  final List<AcPartItemModel> parts;

  const AcServiceState({
    this.isLoading = true,
    this.errorMessage,
    this.selectedFilter = 'الكل',
    this.promoBanner,
    this.filterChips = const [],
    this.services = const [],
    this.parts = const [],
  });

  AcServiceState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? selectedFilter,
    AcPromoBannerModel? promoBanner,
    List<String>? filterChips,
    List<AcServiceItemModel>? services,
    List<AcPartItemModel>? parts,
  }) {
    return AcServiceState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedFilter: selectedFilter ?? this.selectedFilter,
      promoBanner: promoBanner ?? this.promoBanner,
      filterChips: filterChips ?? this.filterChips,
      services: services ?? this.services,
      parts: parts ?? this.parts,
    );
  }
}

class AcServiceController extends ValueNotifier<AcServiceState> {
  final AcServiceRepository _repository;

  AcServiceController({AcServiceRepository? repository})
      : _repository = repository ?? const AcServiceRepositoryImpl(),
        super(const AcServiceState());

  Future<void> loadData() async {
    value = value.copyWith(isLoading: true, clearError: true);
    try {
      final banner = await _repository.getPromoBanner();
      final chips = await _repository.getFilterChips();
      final services = await _repository.getServices(
        category: value.selectedFilter,
      );
      final parts = await _repository.getParts();

      value = value.copyWith(
        isLoading: false,
        promoBanner: banner,
        filterChips: chips,
        services: services,
        parts: parts,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تحميل بيانات الصيانة: ${e.toString()}',
      );
    }
  }

  Future<void> selectFilter(String filter) async {
    if (value.selectedFilter == filter) return;
    value = value.copyWith(selectedFilter: filter, isLoading: true);
    try {
      final services = await _repository.getServices(category: filter);
      value = value.copyWith(services: services, isLoading: false);
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل في تصفية الخدمات',
      );
    }
  }
}
