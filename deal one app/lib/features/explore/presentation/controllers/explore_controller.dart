import 'package:flutter/foundation.dart';

import '../../data/models/explore_search_models.dart';
import '../../data/repositories/explore_repository.dart';

class ExploreState {
  final bool isLoading;
  final String searchQuery;
  final SectorType selectedSector;
  final List<ExploreSearchResultItem> searchResults;
  final List<String> recentSearches;
  final List<String> popularSearches;
  final List<ExploreSectorCategoryItem> categories;
  final List<DiscoveryCardItem> mostRequested;
  final List<DiscoveryCardItem> latestAdditions;
  final List<DiscoveryCardItem> currentOffers;
  final String? errorMessage;

  const ExploreState({
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedSector = SectorType.all,
    this.searchResults = const [],
    this.recentSearches = const [],
    this.popularSearches = const [],
    this.categories = const [],
    this.mostRequested = const [],
    this.latestAdditions = const [],
    this.currentOffers = const [],
    this.errorMessage,
  });

  bool get isSearching => searchQuery.trim().isNotEmpty;

  ExploreState copyWith({
    bool? isLoading,
    String? searchQuery,
    SectorType? selectedSector,
    List<ExploreSearchResultItem>? searchResults,
    List<String>? recentSearches,
    List<String>? popularSearches,
    List<ExploreSectorCategoryItem>? categories,
    List<DiscoveryCardItem>? mostRequested,
    List<DiscoveryCardItem>? latestAdditions,
    List<DiscoveryCardItem>? currentOffers,
    String? errorMessage,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSector: selectedSector ?? this.selectedSector,
      searchResults: searchResults ?? this.searchResults,
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
      categories: categories ?? this.categories,
      mostRequested: mostRequested ?? this.mostRequested,
      latestAdditions: latestAdditions ?? this.latestAdditions,
      currentOffers: currentOffers ?? this.currentOffers,
      errorMessage: errorMessage,
    );
  }
}

class ExploreController extends ValueNotifier<ExploreState> {
  final ExploreRepository repository;
  bool _isDisposed = false;

  ExploreController({ExploreRepository? repository})
      : repository = repository ?? ExploreRepositoryImpl(),
        super(const ExploreState(isLoading: true)) {
    loadInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> loadInitialData() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final recent = await repository.getRecentSearches();
      final popular = repository.getPopularSearches();
      final cats = repository.getMainCategories();
      final mostReq = repository.getMostRequested();
      final latest = repository.getLatestAdditions();
      final offers = repository.getCurrentOffers();
      final initialResults = await repository.search('', sector: value.selectedSector);

      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        recentSearches: recent,
        popularSearches: popular,
        categories: cats,
        mostRequested: mostReq,
        latestAdditions: latest,
        currentOffers: offers,
        searchResults: initialResults,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'فشل تحميل بيانات الاستكشاف: $e',
      );
    }
  }

  Future<void> setSectorFilter(SectorType sector) async {
    if (_isDisposed || value.selectedSector == sector) return;
    value = value.copyWith(selectedSector: sector, isLoading: true);
    await _executeSearch();
  }

  Future<void> onSearchQueryChanged(String query) async {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: query);
    await _executeSearch();
  }

  Future<void> submitSearch(String query) async {
    if (_isDisposed) return;
    final clean = query.trim();
    if (clean.isNotEmpty) {
      await repository.addRecentSearch(clean);
      final updatedRecent = await repository.getRecentSearches();
      if (_isDisposed) return;
      value = value.copyWith(searchQuery: clean, recentSearches: updatedRecent);
      await _executeSearch();
    }
  }

  Future<void> clearSearch() async {
    if (_isDisposed) return;
    value = value.copyWith(searchQuery: '');
    await _executeSearch();
  }

  Future<void> removeRecentSearch(String query) async {
    if (_isDisposed) return;
    await repository.removeRecentSearch(query);
    final updated = await repository.getRecentSearches();
    if (_isDisposed) return;
    value = value.copyWith(recentSearches: updated);
  }

  Future<void> clearAllRecentSearches() async {
    if (_isDisposed) return;
    await repository.clearRecentSearches();
    value = value.copyWith(recentSearches: []);
  }

  Future<void> _executeSearch() async {
    if (_isDisposed) return;
    try {
      final results = await repository.search(
        value.searchQuery,
        sector: value.selectedSector,
      );
      if (_isDisposed) return;
      value = value.copyWith(isLoading: false, searchResults: results);
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'حدث خطأ أثناء البحث: $e',
      );
    }
  }
}
