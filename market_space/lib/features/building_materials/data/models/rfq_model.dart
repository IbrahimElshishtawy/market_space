import 'supplier_model.dart';
import 'unit_of_measurement.dart';

enum RfqStatus {
  open('مفتوح للعروض', 'open'),
  underReview('جاري مراجعة العروض', 'under_review'),
  awarded('تم ترسية الطلب', 'awarded'),
  closed('مغلق', 'closed'),
  cancelled('ملغي', 'cancelled');

  final String label;
  final String code;

  const RfqStatus(this.label, this.code);
}

class SupplierQuoteModel {
  final String id;
  final String rfqId;
  final SupplierModel supplier;
  final double quotedUnitPrice;
  final double quotedFreightCost;
  final MaterialUnit unit;
  final double quantity;
  final int deliveryDurationDays;
  final String notes;
  final DateTime quoteDate;
  final DateTime validUntil;
  final bool isAccepted;

  const SupplierQuoteModel({
    required this.id,
    required this.rfqId,
    required this.supplier,
    required this.quotedUnitPrice,
    required this.quotedFreightCost,
    required this.unit,
    required this.quantity,
    required this.deliveryDurationDays,
    required this.notes,
    required this.quoteDate,
    required this.validUntil,
    this.isAccepted = false,
  });

  double get subtotal => UnitConverter.roundCurrency(quantity * quotedUnitPrice);
  double get grandTotal => UnitConverter.roundCurrency(subtotal + quotedFreightCost);
}

class RfqRequestModel {
  final String id;
  final String rfqNumber;
  final String userId;
  final String materialName;
  final String categoryId;
  final double quantity;
  final MaterialUnit unit;
  final Map<String, String> technicalSpecs;
  final String projectName;
  final String projectAddress;
  final String city;
  final String governorate;
  final DateTime requestedDeliveryDate;
  final String notes;
  final DateTime createdAt;
  final RfqStatus status;
  final List<SupplierQuoteModel> quotes;

  const RfqRequestModel({
    required this.id,
    required this.rfqNumber,
    required this.userId,
    required this.materialName,
    required this.categoryId,
    required this.quantity,
    required this.unit,
    this.technicalSpecs = const {},
    required this.projectName,
    required this.projectAddress,
    required this.city,
    required this.governorate,
    required this.requestedDeliveryDate,
    required this.notes,
    required this.createdAt,
    this.status = RfqStatus.open,
    this.quotes = const [],
  });

  RfqRequestModel copyWith({
    String? id,
    String? rfqNumber,
    String? userId,
    String? materialName,
    String? categoryId,
    double? quantity,
    MaterialUnit? unit,
    Map<String, String>? technicalSpecs,
    String? projectName,
    String? projectAddress,
    String? city,
    String? governorate,
    DateTime? requestedDeliveryDate,
    String? notes,
    DateTime? createdAt,
    RfqStatus? status,
    List<SupplierQuoteModel>? quotes,
  }) {
    return RfqRequestModel(
      id: id ?? this.id,
      rfqNumber: rfqNumber ?? this.rfqNumber,
      userId: userId ?? this.userId,
      materialName: materialName ?? this.materialName,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      projectName: projectName ?? this.projectName,
      projectAddress: projectAddress ?? this.projectAddress,
      city: city ?? this.city,
      governorate: governorate ?? this.governorate,
      requestedDeliveryDate: requestedDeliveryDate ?? this.requestedDeliveryDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
    );
  }
}
