library;

/// Strongly-typed models for Bazar Jo marketplace listings and providers.

class RealEstateItem {
  final String id;
  final String title;
  final String price;
  final String priceSuffix;
  final String type; // "للبيع" or "للإيجار"
  final bool isVerified;
  final String? badge; // "مفروشة بالكامل", "صكوك موثقة"
  final int beds;
  final int baths;
  final double? areaM2;
  final String location;
  final String timeAgo;
  final String imageUrl;

  const RealEstateItem({
    required this.id,
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.type,
    this.isVerified = true,
    this.badge,
    required this.beds,
    required this.baths,
    this.areaM2,
    required this.location,
    required this.timeAgo,
    required this.imageUrl,
  });
}

class BuildingMaterialItem {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String unit;
  final String tag;
  final String footerText;
  final bool hasCall;
  final bool hasChat;
  final String imageUrl;

  const BuildingMaterialItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.unit,
    required this.tag,
    required this.footerText,
    this.hasCall = true,
    this.hasChat = false,
    required this.imageUrl,
  });
}

class ServiceProviderItem {
  final String id;
  final String name;
  final String serviceDesc;
  final double rating;
  final int reviewsCount;
  final String perkText;
  final String actionLabel;
  final bool isVerified;
  final String categoryKey; // "finishing", "plumbing", "moving"

  const ServiceProviderItem({
    required this.id,
    required this.name,
    required this.serviceDesc,
    required this.rating,
    required this.reviewsCount,
    required this.perkText,
    required this.actionLabel,
    this.isVerified = true,
    required this.categoryKey,
  });
}

class InvestmentProjectItem {
  final String id;
  final String title;
  final String location;
  final String minInvestment;
  final String expectedReturn;
  final double progressPercent;
  final String imageUrl;

  const InvestmentProjectItem({
    required this.id,
    required this.title,
    required this.location,
    required this.minInvestment,
    required this.expectedReturn,
    required this.progressPercent,
    required this.imageUrl,
  });
}
