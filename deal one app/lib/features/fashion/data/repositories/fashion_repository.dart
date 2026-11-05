import '../../../../core/network/api_client.dart';
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

class ApiFashionRepository implements FashionRepository {
  final ApiClient apiClient;
  final MockFashionRepository _fallback = MockFashionRepository();

  ApiFashionRepository({required this.apiClient});

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
    try {
      final queryParams = <String, dynamic>{
        'categorySlug': 'fashion',
        'limit': pageSize > 50 ? 50 : pageSize,
      };

      if (department == FashionDepartment.men) {
        queryParams['categorySlug'] = 'mens-clothing';
      } else if (department == FashionDepartment.women) {
        queryParams['categorySlug'] = 'womens-clothing';
      } else if (department == FashionDepartment.kids) {
        queryParams['categorySlug'] = 'kids-clothing';
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        queryParams['q'] = searchQuery.trim();
      }
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

      final response = await apiClient.get('/listings', queryParameters: queryParams);
      final dynamic resData = response.data;
      List<dynamic> items = [];
      if (resData is Map && resData['data'] is List) {
        items = resData['data'] as List;
      } else if (resData is List) {
        items = resData;
      }

      if (items.isEmpty) {
        return _fallback.getProducts(
          department: department,
          category: category,
          searchQuery: searchQuery,
          minPrice: minPrice,
          maxPrice: maxPrice,
          brand: brand,
          sortBy: sortBy,
          page: page,
          pageSize: pageSize,
        );
      }

      return items.map<FashionProductModel>((item) {
        final Map<String, dynamic> data =
            item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item);

        final num priceNum = data['price'] is num
            ? data['price']
            : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);

        final attrs = data['attributes'] is Map
            ? Map<String, dynamic>.from(data['attributes'])
            : <String, dynamic>{};

        final mediaList = data['media'] as List?;
        final images = mediaList != null && mediaList.isNotEmpty
            ? mediaList
                .map((m) => m['publicUrl']?.toString() ?? '')
                .where((u) => u.isNotEmpty)
                .toList()
            : <String>[
                data['primaryImageUrl']?.toString() ??
                    'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80'
              ];

        final dept = department ?? FashionDepartment.men;

        return FashionProductModel(
          id: data['id']?.toString() ?? '',
          name: data['title']?.toString() ?? 'قطعة أزياء أنيقة',
          nameEn: 'Fashion Item',
          brand: attrs['brand']?.toString() ?? 'ماركة مصرية',
          price: priceNum.toDouble(),
          oldPrice: priceNum.toDouble() * 1.25,
          discountPercentage: 20,
          department: dept,
          category: data['category']?['nameAr']?.toString() ?? 'ملابس',
          description: data['description']?.toString() ?? 'خامات عالية الجودة وتصميم عصري مريح.',
          material: attrs['material']?.toString() ?? 'قطن مصري 100%',
          season: 'جميع الفصول',
          washingInstructions: 'غسيل يدوي أو آلي بماء فاتر',
          images: images,
          rating: 4.8,
          reviewsCount: 38,
          variants: const [
            FashionVariantModel(id: 'v1', size: 'M', colorName: 'أسود', colorValue: 0xFF000000, stockQuantity: 10),
            FashionVariantModel(id: 'v2', size: 'L', colorName: 'كحلي', colorValue: 0xFF000080, stockQuantity: 15),
            FashionVariantModel(id: 'v3', size: 'XL', colorName: 'رمادي', colorValue: 0xFF808080, stockQuantity: 8),
          ],
          isFeatured: true,
          isBestSeller: true,
          isNewArrival: true,
          isFavorite: false,
          createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return _fallback.getProducts(
        department: department,
        category: category,
        searchQuery: searchQuery,
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        sortBy: sortBy,
        page: page,
        pageSize: pageSize,
      );
    }
  }

  @override
  Future<FashionProductModel> getProductById(String id) async {
    try {
      final response = await apiClient.get('/listings/$id');
      final dynamic resData = response.data;
      final Map<String, dynamic> data = (resData is Map && resData['data'] is Map)
          ? Map<String, dynamic>.from(resData['data'])
          : (resData is Map ? Map<String, dynamic>.from(resData) : {});

      if (data.isEmpty) return _fallback.getProductById(id);

      final num priceNum = data['price'] is num
          ? data['price']
          : (num.tryParse(data['price']?.toString() ?? '0') ?? 0);
      final attrs = data['attributes'] is Map
          ? Map<String, dynamic>.from(data['attributes'])
          : <String, dynamic>{};

      final mediaList = data['media'] as List?;
      final images = mediaList != null && mediaList.isNotEmpty
          ? mediaList
              .map((m) => m['publicUrl']?.toString() ?? '')
              .where((u) => u.isNotEmpty)
              .toList()
          : <String>[
              'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80'
            ];

      return FashionProductModel(
        id: data['id']?.toString() ?? id,
        name: data['title']?.toString() ?? 'قطعة أزياء راقية',
        nameEn: 'Fashion Item',
        brand: attrs['brand']?.toString() ?? 'ماركة معتمدة',
        price: priceNum.toDouble(),
        oldPrice: priceNum.toDouble() * 1.25,
        discountPercentage: 20,
        department: FashionDepartment.men,
        category: data['category']?['nameAr']?.toString() ?? 'ملابس',
        description: data['description']?.toString() ?? 'خامات عالية الجودة وتصميم عصري.',
        material: attrs['material']?.toString() ?? 'قطن مصري 100%',
        season: 'جميع الفصول',
        washingInstructions: 'غسيل يدوي أو آلي بماء فاتر',
        images: images,
        rating: 4.8,
        reviewsCount: 38,
        variants: const [
          FashionVariantModel(id: 'v1', size: 'M', colorName: 'أسود', colorValue: 0xFF000000, stockQuantity: 10),
          FashionVariantModel(id: 'v2', size: 'L', colorName: 'كحلي', colorValue: 0xFF000080, stockQuantity: 15),
          FashionVariantModel(id: 'v3', size: 'XL', colorName: 'رمادي', colorValue: 0xFF808080, stockQuantity: 8),
        ],
        isFeatured: true,
        isBestSeller: true,
        isNewArrival: true,
        isFavorite: false,
        createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return _fallback.getProductById(id);
    }
  }

  @override
  Future<List<FashionCategoryModel>> getCategories({FashionDepartment? department}) async {
    return _fallback.getCategories(department: department);
  }

  @override
  Future<List<FashionProductModel>> getFeaturedProducts() async {
    return getProducts(pageSize: 6);
  }

  @override
  Future<List<FashionProductModel>> getBestSellers() async {
    return getProducts(pageSize: 6);
  }

  @override
  Future<List<FashionProductModel>> getNewArrivals() async {
    return getProducts(pageSize: 6);
  }

  @override
  Future<List<FashionProductModel>> getSimilarProducts(String productId) async {
    return _fallback.getSimilarProducts(productId);
  }

  @override
  Future<bool> toggleFavorite(String productId) async {
    try {
      final res = await apiClient.post('/favorites/$productId');
      final data = res.data;
      if (data is Map && data['data'] != null && data['data']['favorited'] != null) {
        return data['data']['favorited'] as bool;
      }
      return true;
    } catch (_) {
      return _fallback.toggleFavorite(productId);
    }
  }
}

class MockFashionRepository implements FashionRepository {
  final List<FashionProductModel> _products;
  final List<FashionCategoryModel> _categories;
  final Duration simulatedDelay;

  MockFashionRepository({
    List<FashionProductModel>? products,
    List<FashionCategoryModel>? categories,
    this.simulatedDelay = Duration.zero,
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
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
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
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => _products.first,
    );
  }

  @override
  Future<List<FashionCategoryModel>> getCategories({FashionDepartment? department}) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    if (department == null) return _categories;
    return _categories.where((c) => c.department == department).toList();
  }

  @override
  Future<List<FashionProductModel>> getFeaturedProducts() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _products.where((p) => p.isFeatured).toList();
  }

  @override
  Future<List<FashionProductModel>> getBestSellers() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _products.where((p) => p.isBestSeller).toList();
  }

  @override
  Future<List<FashionProductModel>> getNewArrivals() async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
    return _products.where((p) => p.isNewArrival).toList();
  }

  @override
  Future<List<FashionProductModel>> getSimilarProducts(String productId) async {
    if (simulatedDelay > Duration.zero) await Future.delayed(simulatedDelay);
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
