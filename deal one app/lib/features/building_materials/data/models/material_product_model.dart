import 'supplier_model.dart';
import 'unit_of_measurement.dart';

class MaterialProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String subcategoryId;
  final String categoryName;
  final String brand;
  final String manufacturer;
  final String description;
  final Map<String, String> technicalSpecs;
  final MaterialUnit baseUnit;
  final List<MaterialUnit> supportedUnits;
  final double unitPrice; // السعر بالوحدة الأساسية
  final double minOrderQuantity; // الحد الأدنى للطلب بالوحدة الأساسية
  final double stockQuantity;
  final String supplyOrigin; // مصنع، مستودع السويس، محجر...
  final SupplierModel supplier;
  final List<String> imageUrls;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;
  final int estimatedDeliveryDays;

  const MaterialProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subcategoryId,
    required this.categoryName,
    required this.brand,
    required this.manufacturer,
    required this.description,
    required this.technicalSpecs,
    required this.baseUnit,
    required this.supportedUnits,
    required this.unitPrice,
    required this.minOrderQuantity,
    required this.stockQuantity,
    required this.supplyOrigin,
    required this.supplier,
    required this.imageUrls,
    this.rating = 4.8,
    this.reviewsCount = 14,
    this.isAvailable = true,
    this.estimatedDeliveryDays = 2,
  });

  String get primaryImageUrl =>
      imageUrls.isNotEmpty
          ? imageUrls.first
          : 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122';

  String get formattedPrice =>
      '${unitPrice.toStringAsFixed(0)} ج.م / ${baseUnit.label}';

  String get formattedMinOrder =>
      '${minOrderQuantity.toStringAsFixed(0)} ${baseUnit.label}';

  /// حساب سعر كمية معينة بوحدة معينة
  double calculateTotalForQuantity(double quantity, MaterialUnit unit) {
    final qtyInBase = UnitConverter.convertQuantity(
      quantity: quantity,
      from: unit,
      to: baseUnit,
    );
    final total = qtyInBase * unitPrice;
    return UnitConverter.roundCurrency(total);
  }

  /// التحقق من أن الكمية تلبي الحد الأدنى للطلب
  bool isValidOrderQuantity(double quantity, MaterialUnit unit) {
    final qtyInBase = UnitConverter.convertQuantity(
      quantity: quantity,
      from: unit,
      to: baseUnit,
    );
    return qtyInBase >= minOrderQuantity && qtyInBase <= stockQuantity;
  }
}
