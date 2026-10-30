import '../../../data/models/real_estate_filter_model.dart';

class SavedSearchModel {
  final String id;
  final String name;
  final String userId;
  final RealEstateFilterModel filter;
  final bool isNotificationsEnabled;
  final DateTime createdAt;

  const SavedSearchModel({
    required this.id,
    required this.name,
    required this.userId,
    required this.filter,
    this.isNotificationsEnabled = true,
    required this.createdAt,
  });

  SavedSearchModel copyWith({
    String? id,
    String? name,
    String? userId,
    RealEstateFilterModel? filter,
    bool? isNotificationsEnabled,
    DateTime? createdAt,
  }) {
    return SavedSearchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      filter: filter ?? this.filter,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
