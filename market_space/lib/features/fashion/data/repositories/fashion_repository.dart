import '../mock/mock_fashion_data.dart';
import '../models/fashion_category_model.dart';
import '../models/fashion_product_model.dart';

abstract class FashionRepository {
  Future<List<FashionProductModel>> getProducts({
    FashionDepartment? department,
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  });

  Future<FashionProductModel> getProductById(String id);
  Future<List<FashionCategoryModel>> getCategories({FashionDepartment? department});
  Future<List<FashionProductModel>> getFeaturedProducts();
  Future<List<FashionProductModel>> getBestSellers();
  Future<List<FashionProductModel>> getNewArrivals();
  Future<List<FashionProductModel>> getSimilarProducts(String productId);
  Future<bool> toggleFavorite(String productId);
}

class MockFashionRepository implements FashionRepository {
  final List<FashionProductModel> _products;
  final List<FashionCategoryModel> _categories;

  MockFashionRepository({
    List<FashionProductModel>? products,
    List<FashionCategoryModel>? categories,
  })  : _products = List.from(products ?? MockFashionData.products),
        _categories = List.from(categories ?? MockFashionData.categories);

  @override
  Future<List<FashionProductModel>> getProducts({
    FashionDepartment? department,
    String? category,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
    var results = List<FashionProductModel>.from(_products);

    if (department != null && department != FashionDepartment.unisex) {
      results = results
          .where((p) => p.department == department || p.department == FashionDepartment.unisex)
          .toList();
    }

    if (category != null && category.isNotEmpty) {
      results = results
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (brand != null && brand.isNotEmpty) {
      results = results
          .where((p) => p.brand.toLowerCase() == brand.toLowerCase())
          .toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      results = results.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.nameEn.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }

    if (minPrice != null) {
      results = results.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      results = results.where((p) => p.price <= maxPrice).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          results.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'discount':
          results.sort((a, b) => (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0));
          break;
      }
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= results.length) return [];
    final endIndex = (startIndex + pageSize < results.length) ? startIndex + pageSize : results.length;
    return results.sublist(startIndex, endIndex);
  }

  @override
  Future<FashionProductModel> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 40));
    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => _products.first,
    );
  }

  @override
  Future<List<FashionCategoryModel>> getCategories({FashionDepartment? department}) async {
    await Future.delayed(const Duration(milliseconds: 40));
    if (department == null) return _categories;
    return _categories.where((c) => c.department == department).toList();
  }

  @override
  Future<List<FashionProductModel>> getFeaturedProducts() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _products.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<FashionProductModel>> getBestSellers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _products.where((p) => p.isBestSeller).toList();
  }

  @override
  Future<List<FashionProductModel>> getNewArrivals() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _products.where((p) => p.isNewArrival).toList();
  }

  @override
  Future<List<FashionProductModel>> getSimilarProducts(String productId) async {
    await Future.delayed(const Duration(milliseconds: 40));
    final product = await getProductById(productId);
    return _products
        .where((p) => p.id != productId && (p.category == product.category || p.department == product.department))
        .take(6)
        .toList();
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final current = _products[index];
      final newFav = !current.isFavorite;
      _products[index] = current.copyWith(isFavorite: newFav);
      return newFav;
    }
    return false;
  }
}
