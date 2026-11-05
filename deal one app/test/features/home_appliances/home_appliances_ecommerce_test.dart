import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/home_appliances/cart/presentation/controllers/home_appliances_cart_controller.dart';
import 'package:market_space/features/home_appliances/cart/presentation/pages/home_appliances_cart_page.dart';
import 'package:market_space/features/home_appliances/categories/presentation/pages/home_appliances_categories_page.dart';
import 'package:market_space/features/home_appliances/notifications/presentation/pages/home_appliances_notifications_page.dart';
import 'package:market_space/features/home_appliances/orders/presentation/controllers/home_appliances_order_controller.dart';
import 'package:market_space/features/home_appliances/orders/presentation/pages/home_appliances_orders_page.dart';

void main() {
  group('Home Appliances Cart Controller Tests', () {
    late HomeAppliancesCartController cartController;

    setUp(() {
      cartController = HomeAppliancesCartController();
    });

    tearDown(() {
      cartController.dispose();
    });

    test('loadCart fetches initial items and calculates subtotal', () async {
      await cartController.loadCart();

      expect(cartController.value.isLoading, isFalse);
      expect(cartController.value.cart.items.length, greaterThan(0));
      expect(cartController.value.cart.subtotal, greaterThan(0));
    });

    test('updateQuantity updates quantity and total', () async {
      await cartController.loadCart();

      final firstItem = cartController.value.cart.items.first;
      await cartController.updateQuantity(firstItem.id, 3);

      expect(cartController.value.cart.items.first.quantity, equals(3));
    });

    test('applyCoupon MARKET500 applies 500 EGP discount', () async {
      await cartController.loadCart();

      final success = await cartController.applyCoupon('MARKET500');

      expect(success, isTrue);
      expect(cartController.value.cart.discountAmount, equals(500.0));
      expect(cartController.value.cart.appliedCouponCode, equals('MARKET500'));
    });
  });

  group('Home Appliances Order Controller Tests', () {
    late HomeAppliancesOrderController orderController;

    setUp(() {
      orderController = HomeAppliancesOrderController();
    });

    tearDown(() {
      orderController.dispose();
    });

    test('loadOrders fetches user orders', () async {
      await orderController.loadOrders();

      expect(orderController.value.isLoading, isFalse);
      expect(orderController.value.orders.length, greaterThan(0));
    });
  });

  group('Home Appliances Page Widget Tests', () {
    testWidgets('renders HomeAppliancesCategoriesPage with categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeAppliancesCategoriesPage()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeAppliancesCategoriesPage), findsOneWidget);
      expect(find.text('أقسام الأجهزة المنزلية'), findsOneWidget);
    });

    testWidgets('renders HomeAppliancesCartPage with items and summary', (
      WidgetTester tester,
    ) async {
      final cartController = HomeAppliancesCartController();

      await tester.pumpWidget(
        MaterialApp(home: HomeAppliancesCartPage(controller: cartController)),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeAppliancesCartPage), findsOneWidget);
      expect(find.text('سلة تسوق الأجهزة'), findsOneWidget);
      expect(find.text('ملخص الطلب والحساب'), findsOneWidget);
    });

    testWidgets('renders HomeAppliancesOrdersPage with orders timeline', (
      WidgetTester tester,
    ) async {
      final orderController = HomeAppliancesOrderController();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeAppliancesOrdersPage(controller: orderController),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeAppliancesOrdersPage), findsOneWidget);
      expect(find.text('طلبات الأجهزة المنزلية'), findsOneWidget);
    });

    testWidgets('renders HomeAppliancesNotificationsPage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomeAppliancesNotificationsPage()),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HomeAppliancesNotificationsPage), findsOneWidget);
      expect(find.text('إشعارات الأجهزة المنزلية'), findsOneWidget);
    });
  });
}
