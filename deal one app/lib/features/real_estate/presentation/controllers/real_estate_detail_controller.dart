import 'package:flutter/foundation.dart';

import '../../data/models/real_estate_detail_model.dart';
import '../../data/repositories/real_estate_repository.dart';

class RealEstateDetailState {
  final bool isLoading;
  final String? errorMessage;
  final RealEstateDetailModel? detail;
  final int currentPhotoIndex;
  final bool isExpanded;

  const RealEstateDetailState({
    this.isLoading = true,
    this.errorMessage,
    this.detail,
    this.currentPhotoIndex = 1,
    this.isExpanded = true,
  });

  RealEstateDetailState copyWith({
    bool? isLoading,
    String? errorMessage,
    RealEstateDetailModel? detail,
    int? currentPhotoIndex,
    bool? isExpanded,
  }) {
    return RealEstateDetailState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      detail: detail ?? this.detail,
      currentPhotoIndex: currentPhotoIndex ?? this.currentPhotoIndex,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class RealEstateDetailController extends ValueNotifier<RealEstateDetailState> {
  final RealEstateRepository repository;

  RealEstateDetailController({RealEstateRepository? repository})
    : repository = repository ?? MockRealEstateRepository(),
      super(const RealEstateDetailState());

  Future<void> loadDetail(String listingId) async {
    value = value.copyWith(isLoading: true, errorMessage: null);
    try {
      final item = await repository.getListingDetails(listingId);
      value = value.copyWith(
        isLoading: false,
        detail: item,
        currentPhotoIndex: 1,
      );
    } catch (e) {
      value = value.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setPhotoIndex(int index) {
    value = value.copyWith(currentPhotoIndex: index);
  }

  void toggleExpand() {
    value = value.copyWith(isExpanded: !value.isExpanded);
  }

  Future<void> toggleFavorite() async {
    final detail = value.detail;
    if (detail == null) return;

    final newFav = await repository.toggleFavorite(detail.id);
    value = value.copyWith(detail: detail.copyWith(isFavorite: newFav));
  }
}
