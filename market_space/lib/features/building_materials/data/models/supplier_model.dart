class SupplierModel {
  final String id;
  final String name;
  final String companyType; // مصنع، موزع معتمد، تاجر جملة
  final double rating;
  final int reviewsCount;
  final String city;
  final String governorate;
  final double latitude;
  final double longitude;
  final List<String> coverageGovernorates;
  final double minOrderValue;
  final double fleetCapacityTons;
  final String contactPhone;
  final bool isVerified;
  final int averageDeliveryDays;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.companyType,
    required this.rating,
    required this.reviewsCount,
    required this.city,
    required this.governorate,
    required this.latitude,
    required this.longitude,
    required this.coverageGovernorates,
    required this.minOrderValue,
    required this.fleetCapacityTons,
    required this.contactPhone,
    this.isVerified = true,
    this.averageDeliveryDays = 2,
  });

  bool canDeliverTo(String targetGovernorate) {
    if (coverageGovernorates.contains('الجمهورية') ||
        coverageGovernorates.contains('كافة المحافظات')) {
      return true;
    }
    return coverageGovernorates.any(
      (g) => g.trim().toLowerCase() == targetGovernorate.trim().toLowerCase(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'companyType': companyType,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'city': city,
    'governorate': governorate,
    'latitude': latitude,
    'longitude': longitude,
    'coverageGovernorates': coverageGovernorates,
    'minOrderValue': minOrderValue,
    'fleetCapacityTons': fleetCapacityTons,
    'contactPhone': contactPhone,
    'isVerified': isVerified,
    'averageDeliveryDays': averageDeliveryDays,
  };

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      companyType: json['companyType'] as String? ?? 'مورد معتمد',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: json['reviewsCount'] as int? ?? 12,
      city: json['city'] as String? ?? 'القاهرة',
      governorate: json['governorate'] as String? ?? 'القاهرة',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
      coverageGovernorates:
          (json['coverageGovernorates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['القاهرة', 'الجيزة'],
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 5000.0,
      fleetCapacityTons:
          (json['fleetCapacityTons'] as num?)?.toDouble() ?? 50.0,
      contactPhone: json['contactPhone'] as String? ?? '01000000000',
      isVerified: json['isVerified'] as bool? ?? true,
      averageDeliveryDays: json['averageDeliveryDays'] as int? ?? 2,
    );
  }
}
