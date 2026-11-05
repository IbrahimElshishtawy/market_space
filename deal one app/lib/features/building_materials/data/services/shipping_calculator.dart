import 'dart:math';

import '../models/building_material_cart_model.dart';
import '../models/supplier_model.dart';

class ShippingCalculationResult {
  final double totalFreightCost;
  final bool isDeliverable;
  final String? rejectionReason;
  final int requiredTrips;
  final double distanceKm;
  final double totalWeightTons;
  final bool requiresConfirmation;

  const ShippingCalculationResult({
    required this.totalFreightCost,
    required this.isDeliverable,
    this.rejectionReason,
    required this.requiredTrips,
    required this.distanceKm,
    required this.totalWeightTons,
    this.requiresConfirmation = false,
  });
}

class ShippingCalculator {
  /// متوسط المسافة التقديرية بين نقطتين جغرافيتين بصيغة Haversine
  static double calculateDistanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// حساب تكلفة النقل الواقعية لشحنة مواد بناء لمورد معين
  static ShippingCalculationResult calculateFreight({
    required SupplierModel supplier,
    required List<BuildingMaterialCartItemModel> items,
    required String targetGovernorate,
    double? projectLat,
    double? projectLng,
  }) {
    // 1. التحقق من التغطية الجغرافية للمورد
    if (!supplier.canDeliverTo(targetGovernorate)) {
      return ShippingCalculationResult(
        totalFreightCost: 0.0,
        isDeliverable: false,
        rejectionReason: 'المورد ${supplier.name} لا يغطي محافظة $targetGovernorate حالياً.',
        requiredTrips: 0,
        distanceKm: 0.0,
        totalWeightTons: 0.0,
      );
    }

    // 2. حساب إجمالي الوزن بالأطنان
    final totalWeightTons = items.fold(
      0.0,
      (sum, item) => sum + item.estimatedWeightInTons,
    );

    // 3. حساب المسافة التقديرية
    double distanceKm = 35.0; // مسافة افتراضية متوسطة داخل نفس المحافظة
    if (projectLat != null && projectLng != null) {
      distanceKm = calculateDistanceKm(
        startLat: supplier.latitude,
        startLng: supplier.longitude,
        endLat: projectLat,
        endLng: projectLng,
      );
      if (distanceKm < 10.0) distanceKm = 10.0; // حد أدنى للمسافة
    }

    // 4. تحديد سعة الشاحنة الواحدة وعدد الرحلات المطلوبة
    final double truckCapacityTons = supplier.fleetCapacityTons > 0 ? min(supplier.fleetCapacityTons, 30.0) : 25.0;
    final int requiredTrips = (totalWeightTons <= 0)
        ? 1
        : (totalWeightTons / truckCapacityTons).ceil();

    // 5. حساب تكلفة الرحلة الواحدة:
    // تكلفة ثابتة للتحميل والتفريغ (300 ج) + (المسافة بالكم × 18 ج/كم للشاحنات الثقيلة) + (وزن الشحنة بالطن × 40 ج للعتالة والتعتيق)
    final double baseLoadFee = 300.0 * requiredTrips;
    final double distanceFee = (distanceKm * 18.0) * requiredTrips;
    final double handlingFee = totalWeightTons * 45.0;

    final double calculatedCost = baseLoadFee + distanceFee + handlingFee;
    final roundedCost = (calculatedCost / 50.0).round() * 50.0; // تقريب لأقرب 50 ج

    return ShippingCalculationResult(
      totalFreightCost: roundedCost,
      isDeliverable: true,
      requiredTrips: requiredTrips,
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      totalWeightTons: double.parse(totalWeightTons.toStringAsFixed(2)),
      requiresConfirmation: distanceKm > 100.0 || totalWeightTons > 100.0,
    );
  }
}
