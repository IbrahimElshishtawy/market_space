class PaginatedResponse<T> {
  final bool success;
  final List<T> items;
  final String? nextCursor;

  const PaginatedResponse({
    required this.success,
    required this.items,
    this.nextCursor,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic itemJson) fromItemJson,
  ) {
    final rawDataList = json['data'] as List<dynamic>? ?? [];
    final items = rawDataList.map((item) => fromItemJson(item)).toList();

    String? nextCursor;
    final meta = json['meta'];
    if (meta is Map<String, dynamic>) {
      nextCursor = meta['next_cursor'] as String?;
    }

    return PaginatedResponse<T>(
      success: json['success'] as bool? ?? true,
      items: items,
      nextCursor: nextCursor,
    );
  }
}
