import '../../../data/models/real_estate_listing_model.dart';

class FavoritePropertyModel {
  final String id;
  final String userId;
  final RealEstateListingModel property;
  final DateTime createdAt;
  final String? note;

  const FavoritePropertyModel({
    required this.id,
    required this.userId,
    required this.property,
    required this.createdAt,
    this.note,
  });

  FavoritePropertyModel copyWith({
    String? id,
    String? userId,
    RealEstateListingModel? property,
    DateTime? createdAt,
    String? note,
  }) {
    return FavoritePropertyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      property: property ?? this.property,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}
