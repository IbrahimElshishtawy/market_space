import 'fashion_product_model.dart';

class FashionCategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final FashionDepartment department;
  final String imageUrl;
  final int itemsCount;

  const FashionCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.department,
    required this.imageUrl,
    required this.itemsCount,
  });
}

class FashionCartItemModel {
  final String id;
  final FashionProductModel product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final double unitPrice;

  const FashionCartItemModel({
    required this.id,
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  FashionCartItemModel copyWith({
    int? quantity,
  }) {
    return FashionCartItemModel(
      id: id,
      product: product,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
    );
  }
}
