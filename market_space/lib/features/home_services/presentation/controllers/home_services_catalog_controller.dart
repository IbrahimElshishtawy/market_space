import 'package:flutter/foundation.dart';

import '../../data/models/home_service_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/repositories/home_services_repository.dart';

class HomeServicesCatalogController extends ChangeNotifier {
  final HomeServicesRepository _repository;

  HomeServicesCatalogController({required HomeServicesRepository repository})
      : _repository = repository {
    loadCatalog();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<HomeServiceCategoryModel> _categories = [];
  List<HomeServiceCategoryModel> get categories => _categories;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  List<HomeServiceModel> _services = [];
  List<HomeServiceModel> get services => _services;

  List<HomeServiceModel> _popularServices = [];
  List<HomeServiceModel> get popularServices => _popularServices;

  List<HomeServiceModel> _featuredServices = [];
  List<HomeServiceModel> get featuredServices => _featuredServices;

  List<HomeServiceModel> _newServices = [];
  List<HomeServiceModel> get newServices => _newServices;

  List<ServiceProviderModel> _featuredProviders = [];
  List<ServiceProviderModel> get featuredProviders => _featuredProviders;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  PricingType? _selectedPricingType;
  PricingType? get selectedPricingType => _selectedPricingType;

  String? _selectedArea;
  String? get selectedArea => _selectedArea;

  double? _minRating;
  double? get minRating => _minRating;

  Future<void> loadCatalog() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getServices(),
        _repository.getPopularServices(),
        _repository.getFeaturedServices(),
        _repository.getNewServices(),
        _repository.getProviders(),
      ]);

      _categories = results[0] as List<HomeServiceCategoryModel>;
      _services = results[1] as List<HomeServiceModel>;
      _popularServices = results[2] as List<HomeServiceModel>;
      _featuredServices = results[3] as List<HomeServiceModel>;
      _newServices = results[4] as List<HomeServiceModel>;
      _featuredProviders = results[5] as List<ServiceProviderModel>;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'فشل تحميل بيانات الخدمات. يرجى المحاولة مرة أخرى.';
    }
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setPricingTypeFilter(PricingType? pricingType) {
    _selectedPricingType = pricingType;
    _applyFilters();
  }

  void setAreaFilter(String? area) {
    _selectedArea = area;
    _applyFilters();
  }

  void setMinRatingFilter(double? rating) {
    _minRating = rating;
    _applyFilters();
  }

  void resetFilters() {
    _selectedCategoryId = null;
    _selectedPricingType = null;
    _selectedArea = null;
    _minRating = null;
    _searchQuery = '';
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _repository.getServices(
        categoryId: _selectedCategoryId,
        searchQuery: _searchQuery,
        pricingType: _selectedPricingType,
        area: _selectedArea,
        minRating: _minRating,
      );
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ أثناء تطبيق الفلترة';
    }
    notifyListeners();
  }
}
