import 'material_product_model.dart';
import 'supplier_model.dart';
import 'unit_of_measurement.dart';

class BuildingMaterialCartItemModel {
  final String id;
  final MaterialProductModel product;
  final SupplierModel supplier;
  final MaterialUnit selectedUnit;
  final double quantity;
  final double unitPrice;
  final bool isAvailable;
  final bool hasPriceChanged;
  final double? previousPrice;

  const BuildingMaterialCartItemModel({
    required this.id,
    required this.product,
    required this.supplier,
    required this.selectedUnit,
    required this.quantity,
    required this.unitPrice,
    this.isAvailable = true,
    this.hasPriceChanged = false,
    this.previousPrice,
  });

  BuildingMaterialCartItemModel copyWith({
    String? id,
    MaterialProductModel? product,
    SupplierModel? supplier,
    MaterialUnit? selectedUnit,
    double? quantity,
    double? unitPrice,
    bool? isAvailable,
    bool? hasPriceChanged,
    double? previousPrice,
  }) {
    return BuildingMaterialCartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      supplier: supplier ?? this.supplier,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      hasPriceChanged: hasPriceChanged ?? this.hasPriceChanged,
      previousPrice: previousPrice ?? this.previousPrice,
    );
  }

  double get totalPrice =>
      UnitConverter.roundCurrency(quantity * unitPrice);

  /// تحويل الكمية إلى وحدة الأساس للمنتج للمقارنة مع الحد الأدنى والمخزون
  double get quantityInBaseUnit => UnitConverter.convertQuantity(
    quantity: quantity,
    from: selectedUnit,
    to: product.baseUnit,
  );

  bool get isBelowMinOrder => quantityInBaseUnit < product.minOrderQuantity;

  bool get isAboveStock => quantityInBaseUnit > product.stockQuantity;

  /// حساب الوزن التقريبي بالأطنان لأغراض احتساب النقل والشحن
  double get estimatedWeightInTons {
    switch (product.baseUnit.type) {
      case MaterialUnitType.weight:
        return UnitConverter.convertQuantity(
          quantity: quantity,
          from: selectedUnit,
          to: MaterialUnit.ton,
        );
      case MaterialUnitType.volume:
        // متوسط كثافة الرمل والزلط 1.6 طن / م³
        final m3 = UnitConverter.convertQuantity(
          quantity: quantity,
          from: selectedUnit,
          to: MaterialUnit.cubicMeter,
        );
        return m3 * 1.6;
      case MaterialUnitType.count:
        // متوسط وزن 1000 طوبة طفلية أو أسمنتية = 2.0 طن
        final thousands = UnitConverter.convertQuantity(
          quantity: quantity,
          from: selectedUnit,
          to: MaterialUnit.thousandPieces,
        );
        return thousands * 2.0;
      case MaterialUnitType.area:
      case MaterialUnitType.liquid:
      case MaterialUnitType.length:
        return 0.5; // وزن تقديري للشحنات الخفيفة
    }
  }
}

class BuildingMaterialCartModel {
  final String id;
  final String userId;
  final List<BuildingMaterialCartItemModel> items;
  final double calculatedFreight;
  final bool isFreightConfirmed;
  final double discountAmount;
  final String? couponCode;
  final String targetGovernorate;

  const BuildingMaterialCartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    this.calculatedFreight = 0.0,
    this.isFreightConfirmed = true,
    this.discountAmount = 0.0,
    this.couponCode,
    this.targetGovernorate = 'القاهرة',
  });

  BuildingMaterialCartModel copyWith({
    String? id,
    String? userId,
    List<BuildingMaterialCartItemModel>? items,
    double? calculatedFreight,
    bool? isFreightConfirmed,
    double? discountAmount,
    String? couponCode,
    String? targetGovernorate,
  }) {
    return BuildingMaterialCartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      calculatedFreight: calculatedFreight ?? this.calculatedFreight,
      isFreightConfirmed: isFreightConfirmed ?? this.isFreightConfirmed,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      targetGovernorate: targetGovernorate ?? this.targetGovernorate,
    );
  }

  double get subtotal =>
      UnitConverter.roundCurrency(items.fold(0.0, (sum, i) => sum + i.totalPrice));

  double get totalWeightTons =>
      items.fold(0.0, (sum, i) => sum + i.estimatedWeightInTons);

  double get grandTotal {
    final total = subtotal + calculatedFreight - discountAmount;
    return total > 0 ? UnitConverter.roundCurrency(total) : 0.0;
  }

  double get totalPrice => grandTotal;

  int get totalItemCount => items.length;

  bool get hasInvalidItems =>
      items.any((i) => !i.isAvailable || i.isBelowMinOrder || i.isAboveStock);

  /// تقسيم العناصر حسب المورد لدعم Marketplace متعدد الموردين
  Map<String, List<BuildingMaterialCartItemModel>> get itemsBySupplier {
    final Map<String, List<BuildingMaterialCartItemModel>> map = {};
    for (final item in items) {
      map.putIfAbsent(item.supplier.id, () => []).add(item);
    }
    return map;
  }
}
