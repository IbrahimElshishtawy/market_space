class BuildingMaterialProductModel {
  final String id;
  final String title;
  final String description;
  final String priceText;
  final double rating;
  final String categoryTag;
  final String imageUrl;
  final bool isAvailable;

  const BuildingMaterialProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceText,
    required this.rating,
    required this.categoryTag,
    required this.imageUrl,
    this.isAvailable = true,
  });
}
