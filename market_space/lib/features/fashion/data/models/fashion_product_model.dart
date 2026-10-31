enum FashionDepartment {
  men('رجال', 'Men'),
  women('نساء', 'Women'),
  kids('أطفال', 'Kids'),
  unisex('للجنسين', 'Unisex');

  final String titleAr;
  final String titleEn;
  const FashionDepartment(this.titleAr, this.titleEn);
}

class FashionVariantModel {
  final String id;
  final String size;
  final String colorName;
  final int colorValue; // Color hex integer
  final int stockQuantity;

  const FashionVariantModel({
    required this.id,
    required this.size,
    required this.colorName,
    required this.colorValue,
    required this.stockQuantity,
  });

  bool get inStock => stockQuantity > 0;
}

class FashionProductModel {
  final String id;
  final String name;
  final String nameEn;
  final String brand;
  final double price;
  final double? oldPrice;
  final int? discountPercentage;
  final FashionDepartment department;
  final String category;
  final String description;
  final String material;
  final String season;
  final String washingInstructions;
  final List<String> images;
  final double rating;
  final int reviewsCount;
  final List<FashionVariantModel> variants;
  final bool isFeatured;
  final bool isBestSeller;
  final bool isNewArrival;
  final bool isFavorite;
  final DateTime createdAt;

  const FashionProductModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.brand,
    required this.price,
    this.oldPrice,
    this.discountPercentage,
    required this.department,
    required this.category,
    required this.description,
    required this.material,
    required this.season,
    required this.washingInstructions,
    required this.images,
    this.rating = 4.8,
    this.reviewsCount = 45,
    required this.variants,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isNewArrival = false,
    this.isFavorite = false,
    required this.createdAt,
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  List<String> get availableSizes =>
      variants.map((v) => v.size).toSet().toList();

  List<String> get availableColors =>
      variants.map((v) => v.colorName).toSet().toList();

  bool get isInStock => variants.any((v) => v.inStock);

  int get totalStock =>
      variants.fold(0, (acc, item) => acc + item.stockQuantity);

  FashionProductModel copyWith({
    bool? isFavorite,
  }) {
    return FashionProductModel(
      id: id,
      name: name,
      nameEn: nameEn,
      brand: brand,
      price: price,
      oldPrice: oldPrice,
      discountPercentage: discountPercentage,
      department: department,
      category: category,
      description: description,
      material: material,
      season: season,
      washingInstructions: washingInstructions,
      images: images,
      rating: rating,
      reviewsCount: reviewsCount,
      variants: variants,
      isFeatured: isFeatured,
      isBestSeller: isBestSeller,
      isNewArrival: isNewArrival,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}
