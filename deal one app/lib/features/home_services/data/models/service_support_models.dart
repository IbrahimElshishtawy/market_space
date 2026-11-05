enum ComplaintType {
  technicianDelay,
  technicianNoShow,
  workmanshipQuality,
  priceDiscrepancy,
  propertyDamage,
  paymentIssue,
  other,
}

extension ComplaintTypeX on ComplaintType {
  String get labelAr {
    switch (this) {
      case ComplaintType.technicianDelay:
        return 'تأخر الفني عن الموعد';
      case ComplaintType.technicianNoShow:
        return 'عدم حضور الفني';
      case ComplaintType.workmanshipQuality:
        return 'سوء جودة التنفيذ';
      case ComplaintType.priceDiscrepancy:
        return 'اختلاف في السعر المتفق عليه';
      case ComplaintType.propertyDamage:
        return 'تلفيات أثناء العمل';
      case ComplaintType.paymentIssue:
        return 'مشكلة في الدفع';
      case ComplaintType.other:
        return 'مشكلة أخرى';
    }
  }
}

enum ComplaintStatus {
  open,
  underInvestigation,
  actionRequired,
  resolved,
  closed,
}

extension ComplaintStatusX on ComplaintStatus {
  String get labelAr {
    switch (this) {
      case ComplaintStatus.open:
        return 'مفتوحة';
      case ComplaintStatus.underInvestigation:
        return 'قيد التحقيق والمراجعة';
      case ComplaintStatus.actionRequired:
        return 'مطلوب إجراء';
      case ComplaintStatus.resolved:
        return 'تم الحل';
      case ComplaintStatus.closed:
        return 'مغلقة';
    }
  }
}

class ServiceComplaintModel {
  final String id;
  final String bookingId;
  final String customerId;
  final ComplaintType type;
  final String description;
  final List<String> attachments;
  final ComplaintStatus status;
  final DateTime createdAt;
  final List<String> supportReplies;

  const ServiceComplaintModel({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.type,
    required this.description,
    this.attachments = const [],
    required this.status,
    required this.createdAt,
    this.supportReplies = const [],
  });
}

class ServiceReviewModel {
  final String id;
  final String bookingId;
  final String serviceId;
  final String? providerId;
  final String customerName;
  final double rating;
  final double punctualityRating;
  final double qualityRating;
  final double professionalismRating;
  final double valueForMoneyRating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;

  const ServiceReviewModel({
    required this.id,
    required this.bookingId,
    required this.serviceId,
    this.providerId,
    required this.customerName,
    required this.rating,
    this.punctualityRating = 5.0,
    this.qualityRating = 5.0,
    this.professionalismRating = 5.0,
    this.valueForMoneyRating = 5.0,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
  });
}

class ServicePromoBannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String discountTag;
  final String ctaText;
  final String imageUrl;
  final String? targetCategoryId;
  final String? targetServiceId;

  const ServicePromoBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountTag,
    required this.ctaText,
    required this.imageUrl,
    this.targetCategoryId,
    this.targetServiceId,
  });
}
