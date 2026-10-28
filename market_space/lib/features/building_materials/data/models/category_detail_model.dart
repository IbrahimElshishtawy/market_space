import 'category_product_item_model.dart';

class CategoryDetailModel {
  final String id;
  final String title;
  final String subtitle;
  final String bannerTitle;
  final String bannerPriceText;
  final String bannerTrendText;
  final bool isTrendUp;
  final String bannerSubtitle;
  final String orderCtaText;
  final String priceLogCtaText;
  final List<String> filterChips;
  final List<CategoryProductItemModel> products;

  const CategoryDetailModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.bannerTitle,
    required this.bannerPriceText,
    required this.bannerTrendText,
    this.isTrendUp = true,
    required this.bannerSubtitle,
    required this.orderCtaText,
    required this.priceLogCtaText,
    required this.filterChips,
    required this.products,
  });
}
