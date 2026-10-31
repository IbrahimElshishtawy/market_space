enum PricingType {
  fixed,
  startingFrom,
  hourly,
  inspectionRequired,
  customQuote,
}

extension PricingTypeX on PricingType {
  String get labelAr {
    switch (this) {
      case PricingType.fixed:
        return 'سعر ثابت';
      case PricingType.startingFrom:
        return 'يبدأ من';
      case PricingType.hourly:
        return 'بالساعة';
      case PricingType.inspectionRequired:
        return 'يتطلب معاينة';
      case PricingType.customQuote:
        return 'عرض سعر مخصص';
    }
  }
}

class HomeServiceCategoryModel {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int servicesCount;
  final String? imageUrl;

  const HomeServiceCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.servicesCount,
    this.imageUrl,
  });

  HomeServiceCategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? servicesCount,
    String? imageUrl,
  }) {
    return HomeServiceCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      servicesCount: servicesCount ?? this.servicesCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ServiceFaqModel {
  final String question;
  final String answer;

  const ServiceFaqModel({
    required this.question,
    required this.answer,
  });
}

class HomeServiceModel {
  final String id;
  final String categoryId;
  final String title;
  final String shortDescription;
  final String detailedDescription;
  final PricingType pricingType;
  final double basePrice;
  final String estimatedDuration;
  final double rating;
  final int reviewsCount;
  final List<String> coverageAreas;
  final List<String> availableProviderIds;
  final List<String> includedTasks;
  final List<String> excludedTasks;
  final String? requiredMaterials;
  final String cancellationPolicy;
  final String? warrantyText;
  final List<String> images;
  final List<ServiceFaqModel> faqs;
  final bool isPopular;
  final bool isNew;
  final bool isFeatured;

  const HomeServiceModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.shortDescription,
    required this.detailedDescription,
    required this.pricingType,
    required this.basePrice,
    required this.estimatedDuration,
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.coverageAreas = const [],
    this.availableProviderIds = const [],
    this.includedTasks = const [],
    this.excludedTasks = const [],
    this.requiredMaterials,
    this.cancellationPolicy = 'إلغاء مجاني حتى ساعتين قبل الموعد المحدد',
    this.warrantyText,
    this.images = const [],
    this.faqs = const [],
    this.isPopular = false,
    this.isNew = false,
    this.isFeatured = false,
  });

  String get formattedPrice {
    switch (pricingType) {
      case PricingType.fixed:
        return '${basePrice.toStringAsFixed(0)} ج.م';
      case PricingType.startingFrom:
        return 'يبدأ من ${basePrice.toStringAsFixed(0)} ج.م';
      case PricingType.hourly:
        return '${basePrice.toStringAsFixed(0)} ج.م / ساعة';
      case PricingType.inspectionRequired:
        return 'معاينة فنية (${basePrice.toStringAsFixed(0)} ج.م)';
      case PricingType.customQuote:
        return 'عرض سعر مخصص';
    }
  }
}
