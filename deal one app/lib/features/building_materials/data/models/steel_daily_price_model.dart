class SteelDailyPriceModel {
  final String id;
  final String title;
  final String priceText;
  final String trendText;
  final bool isTrendUp;
  final String subtitle;
  final String orderCtaText;
  final String priceLogCtaText;

  const SteelDailyPriceModel({
    required this.id,
    required this.title,
    required this.priceText,
    required this.trendText,
    this.isTrendUp = true,
    required this.subtitle,
    required this.orderCtaText,
    required this.priceLogCtaText,
  });
}
