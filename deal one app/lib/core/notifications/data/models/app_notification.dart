class AppNotification {
  final String id;
  final String sectionId;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? targetId;
  final String? targetRoute;

  const AppNotification({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.targetId,
    this.targetRoute,
  });

  AppNotification copyWith({
    String? id,
    String? sectionId,
    String? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? targetId,
    String? targetRoute,
  }) {
    return AppNotification(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      targetId: targetId ?? this.targetId,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}
