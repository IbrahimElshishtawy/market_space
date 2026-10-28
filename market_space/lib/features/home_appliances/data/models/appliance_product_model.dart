class ApplianceProductModel {
  final String id;
  final String title;
  final String subtitle;
  final String brandName;
  final String? badgeText;
  final String priceFormatted;
  final String? oldPriceFormatted;
  final String? monthlyInstallmentFormatted;
  final String imageUrl;
  final bool isFavorite;
  final bool inCart;
  final String categoryKey;

  const ApplianceProductModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.brandName,
    this.badgeText,
    required this.priceFormatted,
    this.oldPriceFormatted,
    this.monthlyInstallmentFormatted,
    required this.imageUrl,
    this.isFavorite = false,
    this.inCart = false,
    required this.categoryKey,
  });

  ApplianceProductModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? brandName,
    String? badgeText,
    String? priceFormatted,
    String? oldPriceFormatted,
    String? monthlyInstallmentFormatted,
    String? imageUrl,
    bool? isFavorite,
    bool? inCart,
    String? categoryKey,
  }) {
    return ApplianceProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      brandName: brandName ?? this.brandName,
      badgeText: badgeText ?? this.badgeText,
      priceFormatted: priceFormatted ?? this.priceFormatted,
      oldPriceFormatted: oldPriceFormatted ?? this.oldPriceFormatted,
      monthlyInstallmentFormatted:
          monthlyInstallmentFormatted ?? this.monthlyInstallmentFormatted,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      inCart: inCart ?? this.inCart,
      categoryKey: categoryKey ?? this.categoryKey,
    );
  }
}
