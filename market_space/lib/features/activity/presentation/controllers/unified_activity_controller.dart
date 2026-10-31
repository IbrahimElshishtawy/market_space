import 'package:flutter/foundation.dart';

import '../../data/models/unified_activity_model.dart';
import '../../data/repositories/unified_activity_repository.dart';

class UnifiedActivityState {
  final bool isLoading;
  final ActivitySectorFilter selectedSector;
  final ActivityStatusGroup selectedStatus;
  final String searchQuery;
  final List<UnifiedActivityItem> activities;
  final String? errorMessage;

  const UnifiedActivityState({
    this.isLoading = false,
    this.selectedSector = ActivitySectorFilter.all,
    this.selectedStatus = ActivityStatusGroup.all,
    this.searchQuery = '',
    this.activities = const [],
    this.errorMessage,
  });

  UnifiedActivityState copyWith({
    bool? isLoading,
    ActivitySectorFilter? selectedSector,
    ActivityStatusGroup? selectedStatus,
    String? searchQuery,
    List<UnifiedActivityItem>? activities,
    String? errorMessage,
  }) {
    return UnifiedActivityState(
      isLoading: isLoading ?? this.isLoading,
      selectedSector: selectedSector ?? this.selectedSector,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      activities: activities ?? this.activities,
      errorMessage: errorMessage,
    );
  }
}

class UnifiedActivityController extends ValueNotifier<UnifiedActivityState> {
  final UnifiedActivityRepository repository;
  bool _isDisposed = false;

  UnifiedActivityController({UnifiedActivityRepository? repository})
      : repository = repository ?? UnifiedActivityRepositoryImpl(),
        super(const UnifiedActivityState(isLoading: true)) {
    loadActivities();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadActivities() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final items = await repository.getActivities(
        sector: value.selectedSector,
        status: value.selectedStatus,
        searchQuery: value.searchQuery,
      );
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, activities: items);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل الأنشطة: $e',
      );
    }
  }

  Future<void> setSectorFilter(ActivitySectorFilter sector) async {
    if (_isDisposed || value.selectedSector == sector) return;
    value = value.copyWith(selectedSector: sector, isLoading: true);
    await loadActivities();
  }

  Future<void> setStatusFilter(ActivityStatusGroup status) async {
    if (_isDisposed || value.selectedStatus == status) return;
    value = value.copyWith(selectedStatus: status, isLoading: true);
    await loadActivities();
  }

  Future<void> setSearchQuery(String query) async {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: query);
    await loadActivities();
  }

  Future<void> clearSearch() async {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: '');
    await loadActivities();
  }
}
