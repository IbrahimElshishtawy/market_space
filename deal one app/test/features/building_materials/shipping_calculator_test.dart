import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/mock/mock_building_materials_comprehensive_data.dart';
import 'package:market_space/features/building_materials/data/models/building_material_cart_model.dart';
import 'package:market_space/features/building_materials/data/models/supplier_model.dart';
import 'package:market_space/features/building_materials/data/models/unit_of_measurement.dart';
import 'package:market_space/features/building_materials/data/services/shipping_calculator.dart';

void main() {
  group('ShippingCalculator Freight & Distance Tests', () {
    late SupplierModel testSupplier;

    setUp(() {
      testSupplier = const SupplierModel(
        id: 'supp-test',
        name: 'مورد تجريبي لاختبار الشحن',
        companyType: 'موزع معتمد',
        rating: 4.8,
        reviewsCount: 50,
        city: 'القاهرة',
        governorate: 'القاهرة',
        latitude: 30.0444,
        longitude: 31.2357,
        coverageGovernorates: ['القاهرة', 'الجيزة', 'القليوبية'],
        minOrderValue: 2000.0,
        fleetCapacityTons: 25.0,
        contactPhone: '01000000000',
      );
    });

    test('calculateDistanceKm computes realistic distance between coordinates', () {
      final dist = ShippingCalculator.calculateDistanceKm(
        startLat: 30.0444,
        startLng: 31.2357,
        endLat: 30.0131,
        endLng: 31.2089,
      );

      expect(dist, greaterThan(3.0));
      expect(dist, lessThan(10.0));
    });

    test('calculateFreight rejects delivery outside coverage governorates', () {
      final product = MockBuildingMaterialsComprehensiveData.products.first;
      final cartItem = BuildingMaterialCartItemModel(
        id: 'item-1',
        product: product,
        supplier: testSupplier,
        quantity: 5.0,
        selectedUnit: MaterialUnit.ton,
        unitPrice: 42000.0,
      );

      final result = ShippingCalculator.calculateFreight(
        supplier: testSupplier,
        items: [cartItem],
        targetGovernorate: 'أسوان', // Outside coverage
      );

      expect(result.isDeliverable, isFalse);
      expect(result.rejectionReason, contains('لا يغطي محافظة أسوان'));
      expect(result.totalFreightCost, 0.0);
    });

    test('calculateFreight calculates required trips based on truck capacity', () {
      final product = MockBuildingMaterialsComprehensiveData.products.first;

      // 60 tons with truck capacity of 25 tons requires 3 trips
      final cartItem = BuildingMaterialCartItemModel(
        id: 'item-2',
        product: product,
        supplier: testSupplier,
        quantity: 60.0,
        selectedUnit: MaterialUnit.ton,
        unitPrice: 42000.0,
      );

      final result = ShippingCalculator.calculateFreight(
        supplier: testSupplier,
        items: [cartItem],
        targetGovernorate: 'الجيزة',
        projectLat: 30.0131,
        projectLng: 31.2089,
      );

      expect(result.isDeliverable, isTrue);
      expect(result.requiredTrips, 3);
      expect(result.totalWeightTons, 60.0);
      expect(result.totalFreightCost, greaterThan(0.0));
    });

    test('calculateFreight enforces minimum base fee when calculated trip fee is small', () {
      final product = MockBuildingMaterialsComprehensiveData.products.first;

      // Small 1 ton order with short distance
      final cartItem = BuildingMaterialCartItemModel(
        id: 'item-3',
        product: product,
        supplier: testSupplier,
        quantity: 1.0,
        selectedUnit: MaterialUnit.ton,
        unitPrice: 42000.0,
      );

      final result = ShippingCalculator.calculateFreight(
        supplier: testSupplier,
        items: [cartItem],
        targetGovernorate: 'القاهرة',
        projectLat: 30.0450,
        projectLng: 31.2360,
      );

      expect(result.isDeliverable, isTrue);
      expect(result.requiredTrips, 1);
      expect(result.totalFreightCost, greaterThanOrEqualTo(250.0));
    });
  });
}
