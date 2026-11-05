import 'unit_of_measurement.dart';

enum ShipmentStatus {
  scheduled('مجدولة', 'scheduled'),
  preparing('جاري التجهيز بالمصنع', 'preparing'),
  loaded('تم التحميل على الشاحنة', 'loaded'),
  inTransit('في الطريق للموقع', 'in_transit'),
  arrivedAtSite('وصلت لموقع المشروع', 'arrived'),
  delivered('تم التفريغ والاستلام', 'delivered'),
  cancelled('ملغاة', 'cancelled');

  final String label;
  final String code;

  const ShipmentStatus(this.label, this.code);
}

class StagedShipmentModel {
  final String id;
  final String shipmentNumber;
  final int shipmentIndex; // الشحنة 1 من 3
  final int totalShipments;
  final double allocatedQuantity;
  final MaterialUnit unit;
  final DateTime scheduledDate;
  final DateTime? deliveredDate;
  final ShipmentStatus status;
  final String? driverName;
  final String? driverPhone;
  final String? truckPlateNumber;
  final String? deliveryNotes;
  final String? proofOfDeliveryUrl;
  final bool isConfirmedByBuyer;

  const StagedShipmentModel({
    required this.id,
    required this.shipmentNumber,
    required this.shipmentIndex,
    required this.totalShipments,
    required this.allocatedQuantity,
    required this.unit,
    required this.scheduledDate,
    this.deliveredDate,
    this.status = ShipmentStatus.scheduled,
    this.driverName,
    this.driverPhone,
    this.truckPlateNumber,
    this.deliveryNotes,
    this.proofOfDeliveryUrl,
    this.isConfirmedByBuyer = false,
  });

  StagedShipmentModel copyWith({
    String? id,
    String? shipmentNumber,
    int? shipmentIndex,
    int? totalShipments,
    double? allocatedQuantity,
    MaterialUnit? unit,
    DateTime? scheduledDate,
    DateTime? deliveredDate,
    ShipmentStatus? status,
    String? driverName,
    String? driverPhone,
    String? truckPlateNumber,
    String? deliveryNotes,
    String? proofOfDeliveryUrl,
    bool? isConfirmedByBuyer,
  }) {
    return StagedShipmentModel(
      id: id ?? this.id,
      shipmentNumber: shipmentNumber ?? this.shipmentNumber,
      shipmentIndex: shipmentIndex ?? this.shipmentIndex,
      totalShipments: totalShipments ?? this.totalShipments,
      allocatedQuantity: allocatedQuantity ?? this.allocatedQuantity,
      unit: unit ?? this.unit,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      truckPlateNumber: truckPlateNumber ?? this.truckPlateNumber,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      isConfirmedByBuyer: isConfirmedByBuyer ?? this.isConfirmedByBuyer,
    );
  }
}
