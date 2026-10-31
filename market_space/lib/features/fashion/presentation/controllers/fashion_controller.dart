import 'package:flutter/foundation.dart';

import '../../data/models/fashion_category_model.dart';
import '../../data/models/fashion_product_model.dart';
import '../../data/repositories/fashion_repository.dart';

class FashionState {
  final bool isLoading;
  final FashionDepartment? selectedDepartment;
  final String? selectedCategory;
  final String searchQuery;
  final String sortBy;
  final List<FashionProductModel> featuredProducts;
  final List<FashionProductModel> bestSellers;
  final List<FashionProductModel> newArrivals;
  final List<FashionProductModel> products;
  final List<FashionCategoryModel> categories;
  final String? errorMessage;

  const FashionState({
    this.isLoading = false,
    this.selectedDepartment,
    this.selectedCategory,
    this.searchQuery = '',
    this.sortBy = 'newest',
    this.featuredProducts = const [],
    this.bestSellers = const [],
    this.newArrivals = const [],
    this.products = const [],
    this.categories = const [],
    this.errorMessage,
  });

  FashionState copyWith({
    bool? isLoading,
    FashionDepartment? selectedDepartment,
    bool clearDepartment = false,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? sortBy,
    List<FashionProductModel>? featuredProducts,
    List<FashionProductModel>? bestSellers,
    List<FashionProductModel>? newArrivals,
    List<FashionProductModel>? products,
    List<FashionCategoryModel>? categories,
    String? errorMessage,
  }) {
    return FashionState(
      isLoading: isLoading ?? this.isLoading,
      selectedDepartment: clearDepartment ? null : (selectedDepartment ?? this.selectedDepartment),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      bestSellers: bestSellers ?? this.bestSellers,
      newArrivals: newArrivals ?? this.newArrivals,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

class FashionController extends ValueNotifier<FashionState> {
  final FashionRepository repository;
  bool _isDisposed = false;

  FashionController({FashionRepository? repository})
      : repository = repository ?? MockFashionRepository(),
        super(const FashionState(isLoading: true)) {
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
      final featured = await repository.getFeaturedProducts();
      final best = await repository.getBestSellers();
      final news = await repository.getNewArrivals();
      final cats = await repository.getCategories();
      final all = await repository.getProducts(
        department: value.selectedDepartment,
        category: value.selectedCategory,
        searchQuery: value.searchQuery,
        sortBy: value.sortBy,
      );

      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        featuredProducts: featured,
        bestSellers: best,
        newArrivals: news,
        categories: cats,
        products: all,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setDepartment(FashionDepartment? dept) async {
    if (dept == value.selectedDepartment && dept != null) {
      value = value.copyWith(clearDepartment: true, clearCategory: true);
    } else {
      value = value.copyWith(selectedDepartment: dept, clearCategory: true);
    }
    await _refreshFilteredProducts();
  }

  Future<void> setCategory(String? cat) async {
    if (cat == value.selectedCategory) {
      value = value.copyWith(clearCategory: true);
    } else {
      value = value.copyWith(selectedCategory: cat);
    }
    await _refreshFilteredProducts();
  }

  Future<void> setSearchQuery(String query) async {
    value = value.copyWith(searchQuery: query);
    await _refreshFilteredProducts();
  }

  Future<void> setSortBy(String sort) async {
    value = value.copyWith(sortBy: sort);
    await _refreshFilteredProducts();
  }

  Future<void> _refreshFilteredProducts() async {
    if (_isDisposed) return;
    value = value.copyWith(isLoading: true);

    try {
      final products = await repository.getProducts(
        department: value.selectedDepartment,
        category: value.selectedCategory,
        searchQuery: value.searchQuery,
        sortBy: value.sortBy,
      );

      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        products: products,
      );
    } catch (e) {
      if (_isDisposed) return;
      value = value.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(String productId) async {
    final newFav = await repository.toggleFavorite(productId);

    List<FashionProductModel> updateList(List<FashionProductModel> list) {
      return list.map((p) => p.id == productId ? p.copyWith(isFavorite: newFav) : p).toList();
    }

    value = value.copyWith(
      featuredProducts: updateList(value.featuredProducts),
      bestSellers: updateList(value.bestSellers),
      newArrivals: updateList(value.newArrivals),
      products: updateList(value.products),
    );
  }
}
