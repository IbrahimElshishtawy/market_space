import 'package:flutter_test/flutter_test.dart';
import 'package:market_space/features/building_materials/data/mock/mock_building_materials_comprehensive_data.dart';
import 'package:market_space/features/building_materials/data/models/building_material_cart_model.dart';
import 'package:market_space/features/building_materials/data/models/building_material_order_model.dart';
import 'package:market_space/features/building_materials/data/models/rfq_model.dart';
import 'package:market_space/features/building_materials/data/models/staged_shipment_model.dart';
import 'package:market_space/features/building_materials/data/models/unit_of_measurement.dart';
import 'package:market_space/features/building_materials/data/repositories/building_materials_order_repository.dart';
import 'package:market_space/features/building_materials/presentation/controllers/building_materials_order_controller.dart';

void main() {
  group('BuildingMaterials Order Repository & Controller Tests', () {
    late BuildingMaterialsOrderRepository repository;
    late BuildingMaterialsOrderController controller;

    setUp(() {
      repository = BuildingMaterialsOrderRepositoryImpl();
      controller = BuildingMaterialsOrderController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Loads initial mock orders and RFQs', () async {
      await controller.loadOrders();
      await controller.loadRfqs();
      expect(controller.value.orders.isNotEmpty, isTrue);
      expect(controller.value.rfqs.isNotEmpty, isTrue);
    });

    test('createOrder splits staged shipments correctly according to selected count', () async {
      final product = MockBuildingMaterialsComprehensiveData.products.first;
      final cartItem = BuildingMaterialCartItemModel(
        id: 'cart-1',
        product: product,
        supplier: product.supplier,
        quantity: 30.0,
        selectedUnit: MaterialUnit.ton,
        unitPrice: 42000.0,
      );

      final cart = BuildingMaterialCartModel(
        id: 'cart-test-1',
        userId: 'user-test',
        items: [cartItem],
        targetGovernorate: 'الجيزة',
      );

      final newOrder = await controller.createOrder(
        cart: cart,
        supplier: product.supplier,
        recipientName: 'المهندس أحمد الهواري',
        recipientPhone: '01012345678',
        deliveryAddress: 'موقع الشيخ زايد الحي الرابع',
        city: 'الشيخ زايد',
        governorate: 'الجيزة',
        paymentMethod: 'تحويل بنكي رسمي معتمد',
        requestedDeliveryDate: DateTime.now().add(const Duration(days: 3)),
        numberOfStagedShipments: 3,
        deliveryNotes: 'برجاء الاتصال قبل وصول الونش بساعتين',
      );

      expect(newOrder, isNotNull);
      expect(newOrder!.shipments.length, 3);
      expect(newOrder.shipments.first.allocatedQuantity, 10.0);
      expect(newOrder.shipments[1].allocatedQuantity, 10.0);
      expect(newOrder.shipments[2].allocatedQuantity, 10.0);
      expect(newOrder.status, BuildingMaterialOrderStatus.confirmed);
      expect(newOrder.timeline.isNotEmpty, isTrue);
    });

    test('confirmShipmentDelivery updates shipment status and completes order when all delivered', () async {
      final product = MockBuildingMaterialsComprehensiveData.products.first;
      final cartItem = BuildingMaterialCartItemModel(
        id: 'cart-2',
        product: product,
        supplier: product.supplier,
        quantity: 10.0,
        selectedUnit: MaterialUnit.ton,
        unitPrice: 42000.0,
      );

      final cart = BuildingMaterialCartModel(
        id: 'cart-test-2',
        userId: 'user-test',
        items: [cartItem],
        targetGovernorate: 'القاهرة',
      );

      final newOrder = await controller.createOrder(
        cart: cart,
        supplier: product.supplier,
        recipientName: 'المهندس أحمد الهواري',
        recipientPhone: '01012345678',
        deliveryAddress: 'التجمع الخامس النرجس',
        city: 'القاهرة الجديدة',
        governorate: 'القاهرة',
        paymentMethod: 'دفع نقدي عند الاستلام في الموقع',
        requestedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
        numberOfStagedShipments: 1,
      );

      expect(newOrder, isNotNull);
      final shipmentId = newOrder!.shipments.first.id;

      final success = await controller.confirmShipmentDelivery(
        orderId: newOrder.id,
        shipmentId: shipmentId,
      );

      expect(success, isTrue);

      final updatedOrder = await repository.getOrderById(newOrder.id);
      expect(updatedOrder.shipments.first.status, ShipmentStatus.delivered);
      expect(updatedOrder.status, BuildingMaterialOrderStatus.delivered);
    });

    test('cancelOrder cancels an active order and records timeline event', () async {
      await controller.loadOrders();
      final orderToCancel = controller.value.orders.first;

      final success = await controller.cancelOrder(orderToCancel.id);
      expect(success, isTrue);

      final updated = await repository.getOrderById(orderToCancel.id);
      expect(updated.status, BuildingMaterialOrderStatus.cancelled);
      expect(updated.timeline.last.title, 'تم إلغاء الطلب');
    });

    test('createRfq and acceptQuote updates RFQ status to awarded', () async {
      final rfq = RfqRequestModel(
        id: 'rfq-test-1',
        rfqNumber: 'RFQ-9999',
        userId: 'user-test',
        materialName: 'حديد عز 12 مم',
        categoryId: 'cat-steel',
        quantity: 50.0,
        unit: MaterialUnit.ton,
        projectName: 'كمبوند النرجس فيلا 42',
        projectAddress: 'الحي الرابع - فيلا 42',
        governorate: 'القاهرة',
        city: 'القاهرة الجديدة',
        requestedDeliveryDate: DateTime.now().add(const Duration(days: 14)),
        notes: 'مطابق للمواصفات القياسية المصرية',
        createdAt: DateTime.now(),
        status: RfqStatus.open,
        technicalSpecs: const {'المواصفة': 'مطابق للمواصفات القياسية المصرية'},
      );

      final created = await controller.createRfq(rfq);
      expect(created, isTrue);

      final quote = SupplierQuoteModel(
        id: 'quote-test-1',
        rfqId: rfq.id,
        supplier: MockBuildingMaterialsComprehensiveData.suppliers.first,
        quotedUnitPrice: 41500.0,
        quotedFreightCost: 3500.0,
        unit: MaterialUnit.ton,
        quantity: 50.0,
        deliveryDurationDays: 2,
        notes: 'شامل التعتيق والتوريد',
        quoteDate: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 5)),
      );

      // Add quote to repository so it can be accepted
      await repository.addQuoteToRfq(rfq.id, quote);

      final accepted = await controller.acceptQuote(
        rfqId: rfq.id,
        quoteId: quote.id,
      );
      expect(accepted, isTrue);

      final updatedRfq = await repository.getRfqById(rfq.id);
      expect(updatedRfq, isNotNull);
      expect(updatedRfq!.status, RfqStatus.awarded);
      expect(updatedRfq.quotes.any((q) => q.isAccepted && q.id == quote.id), isTrue);
    });
  });
}
