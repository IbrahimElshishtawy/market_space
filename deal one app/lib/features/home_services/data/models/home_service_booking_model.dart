import 'package:flutter/material.dart';

enum BookingStatus {
  pendingConfirmation,
  accepted,
  providerAssignment,
  technicianAssigned,
  technicianOnTheWay,
  technicianArrived,
  serviceInProgress,
  awaitingCustomerConfirmation,
  completed,
  cancelled,
  reschedulingRequested,
  rejected,
}

extension BookingStatusX on BookingStatus {
  String get labelAr {
    switch (this) {
      case BookingStatus.pendingConfirmation:
        return 'قيد انتظار التأكيد';
      case BookingStatus.accepted:
        return 'تم قبول الحجز';
      case BookingStatus.providerAssignment:
        return 'جارٍ تعيين المزود';
      case BookingStatus.technicianAssigned:
        return 'تم تعيين الفني';
      case BookingStatus.technicianOnTheWay:
        return 'الفني في الطريق إليك';
      case BookingStatus.technicianArrived:
        return 'وصل الفني';
      case BookingStatus.serviceInProgress:
        return 'الخدمة قيد التنفيذ';
      case BookingStatus.awaitingCustomerConfirmation:
        return 'بانتظار تأكيد العميل';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
      case BookingStatus.reschedulingRequested:
        return 'طلب إعادة جدولة';
      case BookingStatus.rejected:
        return 'مرفوض';
    }
  }

  Color get statusColor {
    switch (this) {
      case BookingStatus.pendingConfirmation:
      case BookingStatus.providerAssignment:
      case BookingStatus.reschedulingRequested:
        return Colors.amber.shade800;
      case BookingStatus.accepted:
      case BookingStatus.technicianAssigned:
      case BookingStatus.technicianOnTheWay:
      case BookingStatus.technicianArrived:
      case BookingStatus.serviceInProgress:
        return Colors.blue.shade700;
      case BookingStatus.awaitingCustomerConfirmation:
        return Colors.deepPurple.shade700;
      case BookingStatus.completed:
        return Colors.green.shade700;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return Colors.red.shade700;
    }
  }

  bool get isTerminal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.rejected;

  bool get canCancel =>
      this == BookingStatus.pendingConfirmation ||
      this == BookingStatus.accepted ||
      this == BookingStatus.technicianAssigned;

  bool get canReschedule =>
      this == BookingStatus.pendingConfirmation ||
      this == BookingStatus.accepted ||
      this == BookingStatus.technicianAssigned;
}

class BookingPricingModel {
  final double servicePrice;
  final double inspectionFee;
  final double transportationFee;
  final double discountAmount;
  final bool isFinalPricePendingInspection;

  const BookingPricingModel({
    required this.servicePrice,
    this.inspectionFee = 0.0,
    this.transportationFee = 30.0,
    this.discountAmount = 0.0,
    this.isFinalPricePendingInspection = false,
  });

  double get subtotal => servicePrice + inspectionFee + transportationFee;
  double get total => (subtotal - discountAmount).clamp(0.0, double.infinity);
}

class BookingAddressModel {
  final String city;
  final String district;
  final String street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? specialInstructions;
  final double? latitude;
  final double? longitude;

  const BookingAddressModel({
    required this.city,
    required this.district,
    required this.street,
    this.building,
    this.floor,
    this.apartment,
    this.specialInstructions,
    this.latitude,
    this.longitude,
  });

  String get fullAddress {
    final parts = [city, district, street];
    if (building != null && building!.isNotEmpty) parts.add('عمارة $building');
    if (floor != null && floor!.isNotEmpty) parts.add('طابق $floor');
    if (apartment != null && apartment!.isNotEmpty) parts.add('شقة $apartment');
    return parts.join('، ');
  }
}

class BookingTimelineEvent {
  final BookingStatus status;
  final DateTime timestamp;
  final String title;
  final String description;

  const BookingTimelineEvent({
    required this.status,
    required this.timestamp,
    required this.title,
    required this.description,
  });
}

class HomeServiceBookingModel {
  final String id;
  final String serviceId;
  final String serviceTitle;
  final String categoryId;
  final String categoryTitle;
  final String? serviceImageUrl;
  final String? providerId;
  final String? providerName;
  final String? providerLogo;
  final String? technicianId;
  final String? technicianName;
  final String? technicianAvatar;
  final String? technicianPhone;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final BookingAddressModel address;
  final String problemDescription;
  final List<String> problemImages;
  final DateTime scheduledDate;
  final String scheduledTimeSlot;
  final BookingPricingModel pricing;
  final BookingStatus status;
  final List<BookingTimelineEvent> timeline;
  final DateTime createdAt;
  final String? cancellationReason;
  final bool hasReview;
  final bool hasComplaint;

  const HomeServiceBookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.categoryId,
    required this.categoryTitle,
    this.serviceImageUrl,
    this.providerId,
    this.providerName,
    this.providerLogo,
    this.technicianId,
    this.technicianName,
    this.technicianAvatar,
    this.technicianPhone,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.problemDescription,
    this.problemImages = const [],
    required this.scheduledDate,
    required this.scheduledTimeSlot,
    required this.pricing,
    required this.status,
    required this.timeline,
    required this.createdAt,
    this.cancellationReason,
    this.hasReview = false,
    this.hasComplaint = false,
  });

  HomeServiceBookingModel copyWith({
    String? id,
    String? serviceId,
    String? serviceTitle,
    String? categoryId,
    String? categoryTitle,
    String? serviceImageUrl,
    String? providerId,
    String? providerName,
    String? providerLogo,
    String? technicianId,
    String? technicianName,
    String? technicianAvatar,
    String? technicianPhone,
    String? customerId,
    String? customerName,
    String? customerPhone,
    BookingAddressModel? address,
    String? problemDescription,
    List<String>? problemImages,
    DateTime? scheduledDate,
    String? scheduledTimeSlot,
    BookingPricingModel? pricing,
    BookingStatus? status,
    List<BookingTimelineEvent>? timeline,
    DateTime? createdAt,
    String? cancellationReason,
    bool? hasReview,
    bool? hasComplaint,
  }) {
    return HomeServiceBookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      categoryId: categoryId ?? this.categoryId,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      serviceImageUrl: serviceImageUrl ?? this.serviceImageUrl,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerLogo: providerLogo ?? this.providerLogo,
      technicianId: technicianId ?? this.technicianId,
      technicianName: technicianName ?? this.technicianName,
      technicianAvatar: technicianAvatar ?? this.technicianAvatar,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      problemDescription: problemDescription ?? this.problemDescription,
      problemImages: problemImages ?? this.problemImages,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTimeSlot: scheduledTimeSlot ?? this.scheduledTimeSlot,
      pricing: pricing ?? this.pricing,
      status: status ?? this.status,
      timeline: timeline ?? this.timeline,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      hasReview: hasReview ?? this.hasReview,
      hasComplaint: hasComplaint ?? this.hasComplaint,
    );
  }
}
