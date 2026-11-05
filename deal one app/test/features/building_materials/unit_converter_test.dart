import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/models/unit_of_measurement.dart';

void main() {
  group('UnitConverter Tests', () {
    test('canConvert accurately validates intra-category measurement units', () {
      // Weight conversions
      expect(UnitConverter.canConvert(MaterialUnit.ton, MaterialUnit.kg), isTrue);
      expect(UnitConverter.canConvert(MaterialUnit.kg, MaterialUnit.ton), isTrue);
      expect(UnitConverter.canConvert(MaterialUnit.bag, MaterialUnit.ton), isTrue);
      expect(UnitConverter.canConvert(MaterialUnit.ton, MaterialUnit.bag), isTrue);

      // Liquid conversions
      expect(UnitConverter.canConvert(MaterialUnit.gallon, MaterialUnit.liter), isTrue);
      expect(UnitConverter.canConvert(MaterialUnit.liter, MaterialUnit.gallon), isTrue);

      // Area conversions
      expect(UnitConverter.canConvert(MaterialUnit.squareMeter, MaterialUnit.squareMeter), isTrue);

      // Quantity/Count conversions
      expect(UnitConverter.canConvert(MaterialUnit.thousandPieces, MaterialUnit.piece), isTrue);
      expect(UnitConverter.canConvert(MaterialUnit.piece, MaterialUnit.thousandPieces), isTrue);

      // Length conversions
      expect(UnitConverter.canConvert(MaterialUnit.linearMeter, MaterialUnit.linearMeter), isTrue);
    });

    test('canConvert rejects cross-category dimensions to prevent arithmetic errors', () {
      // Weight to Volume is forbidden without density
      expect(UnitConverter.canConvert(MaterialUnit.ton, MaterialUnit.cubicMeter), isFalse);
      // Volume to Count is forbidden
      expect(UnitConverter.canConvert(MaterialUnit.cubicMeter, MaterialUnit.thousandPieces), isFalse);
      // Area to Weight is forbidden
      expect(UnitConverter.canConvert(MaterialUnit.squareMeter, MaterialUnit.ton), isFalse);
    });

    test('convertQuantity accurately converts quantities with correct scale factors', () {
      // 1 ton = 1000 kg
      expect(
        UnitConverter.convertQuantity(quantity: 1.0, from: MaterialUnit.ton, to: MaterialUnit.kg),
        1000.0,
      );
      // 2.5 tons = 50 bags (50kg each)
      expect(
        UnitConverter.convertQuantity(quantity: 2.5, from: MaterialUnit.ton, to: MaterialUnit.bag),
        50.0,
      );
      // 20 bags = 1 ton
      expect(
        UnitConverter.convertQuantity(quantity: 20.0, from: MaterialUnit.bag, to: MaterialUnit.ton),
        1.0,
      );
      // 1.5 thousand pieces = 1500 pieces
      expect(
        UnitConverter.convertQuantity(quantity: 1.5, from: MaterialUnit.thousandPieces, to: MaterialUnit.piece),
        1500.0,
      );
      // 500 pieces = 0.5 thousand pieces
      expect(
        UnitConverter.convertQuantity(quantity: 500.0, from: MaterialUnit.piece, to: MaterialUnit.thousandPieces),
        0.5,
      );
    });

    test('convertUnitPrice recalculates price per target unit preserving total value', () {
      // If 1 ton of steel costs 42,000 EGP, 1 kg costs 42 EGP
      final pricePerKg = UnitConverter.convertUnitPrice(
        priceInFromUnit: 42000.0,
        from: MaterialUnit.ton,
        to: MaterialUnit.kg,
      );
      expect(pricePerKg, 42.0);

      // If 1 ton of cement costs 2,800 EGP, 1 50kg bag costs 140 EGP (20 bags per ton)
      final pricePerBag = UnitConverter.convertUnitPrice(
        priceInFromUnit: 2800.0,
        from: MaterialUnit.ton,
        to: MaterialUnit.bag,
      );
      expect(pricePerBag, 140.0);

      // If 1000 bricks cost 1,800 EGP, 1 brick costs 1.8 EGP
      final pricePerBrick = UnitConverter.convertUnitPrice(
        priceInFromUnit: 1800.0,
        from: MaterialUnit.thousandPieces,
        to: MaterialUnit.piece,
      );
      expect(pricePerBrick, 1.8);
    });

    test('convertQuantity throws ArgumentError when converting incompatible units', () {
      expect(
        () => UnitConverter.convertQuantity(quantity: 10.0, from: MaterialUnit.ton, to: MaterialUnit.squareMeter),
        throwsArgumentError,
      );
    });

    test('roundCurrency rounds to 2 decimal places to avoid IEEE 754 precision drift', () {
      expect(UnitConverter.roundCurrency(123.456), 123.46);
      expect(UnitConverter.roundCurrency(123.454), 123.45);
      expect(UnitConverter.roundCurrency(100.00000000000001), 100.0);
    });
  });
}
