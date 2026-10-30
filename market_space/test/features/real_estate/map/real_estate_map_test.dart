import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/real_estate/data/models/real_estate_listing_model.dart';
import 'package:market_space/features/real_estate/map/presentation/controllers/real_estate_map_controller.dart';
import 'package:market_space/features/real_estate/map/presentation/pages/real_estate_map_page.dart';
import 'package:market_space/features/real_estate/map/presentation/widgets/property_map_preview_card.dart';
import 'package:market_space/features/real_estate/map/presentation/widgets/property_price_marker.dart';

void main() {
  group('Real Estate Map Controller & Model Tests', () {
    late RealEstateMapController controller;

    setUp(() {
      controller = RealEstateMapController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('RealEstateMapController loads valid GIS properties', () async {
      await controller.loadMapProperties();

      expect(controller.value.isLoading, isFalse);
      expect(controller.value.allListings.length, greaterThan(0));
      expect(
        controller.value.allListings.every(
          (item) => item.latitude != null && item.longitude != null,
        ),
        isTrue,
      );
    });

    test('Filtering map properties by RealEstateType.forRent works', () async {
      await controller.loadMapProperties();

      controller.setFilterType(RealEstateType.forRent);

      final filtered = controller.value.filteredListings;
      expect(
        filtered.every((item) => item.type == RealEstateType.forRent),
        isTrue,
      );
      expect(filtered.length, equals(2));
    });

    test('Selecting property updates selectedProperty state', () async {
      await controller.loadMapProperties();

      final firstProp = controller.value.allListings.first;
      controller.selectProperty(firstProp);

      expect(controller.value.selectedProperty?.id, equals(firstProp.id));

      controller.selectProperty(null);
      expect(controller.value.selectedProperty, isNull);
    });
  });

  group('RealEstateMapPage Widget Tests', () {
    testWidgets('renders FlutterMap viewport, search bar, and price markers', (
      WidgetTester tester,
    ) async {
      final controller = RealEstateMapController();

      await tester.pumpWidget(
        MaterialApp(home: RealEstateMapPage(controller: controller)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RealEstateMapPage), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(PropertyPriceMarker), findsNWidgets(4));

      expect(find.text('أبحث عن عقار للبيع أو الإيجار...'), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('شقق للبيع'), findsOneWidget);
      expect(find.text('شقق للإيجار'), findsOneWidget);
    });

    testWidgets(
      'tapping a price marker selects property and shows preview card',
      (WidgetTester tester) async {
        final controller = RealEstateMapController();

        await tester.pumpWidget(
          MaterialApp(home: RealEstateMapPage(controller: controller)),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final firstMarker = find.byType(PropertyPriceMarker).first;
        await tester.tap(firstMarker);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(PropertyMapPreviewCard), findsOneWidget);
        expect(find.text('التفاصيل >'), findsOneWidget);
      },
    );
  });
}
