class AcServiceItemModel {
  final String id;
  final String title;
  final String description;
  final double rating;
  final int reviewsCount;
  final int durationMinutes;
  final String priceText;
  final String imageUrl;
  final String category;

  const AcServiceItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewsCount,
    required this.durationMinutes,
    required this.priceText,
    required this.imageUrl,
    this.category = 'all',
  });
}
