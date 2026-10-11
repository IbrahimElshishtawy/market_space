class ApiErrorDetail {
  final String? field;
  final String issue;

  const ApiErrorDetail({
    this.field,
    required this.issue,
  });

  factory ApiErrorDetail.fromJson(Map<String, dynamic> json) {
    return ApiErrorDetail(
      field: json['field'] as String?,
      issue: json['issue']?.toString() ?? json['message']?.toString() ?? '',
    );
  }
}

class ApiErrorResponse {
  final bool success;
  final String code;
  final String message;
  final List<ApiErrorDetail> details;
  final String? requestId;
  final String? timestamp;

  const ApiErrorResponse({
    required this.success,
    required this.code,
    required this.message,
    required this.details,
    this.requestId,
    this.timestamp,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final errorObject = json['error'] as Map<String, dynamic>? ?? {};
    final rawDetails = errorObject['details'] as List<dynamic>? ?? [];

    final detailsList = rawDetails.map((item) {
      if (item is Map<String, dynamic>) {
        return ApiErrorDetail.fromJson(item);
      }
      return ApiErrorDetail(issue: item.toString());
    }).toList();

    return ApiErrorResponse(
      success: json['success'] as bool? ?? false,
      code: errorObject['code']?.toString() ?? 'UNKNOWN_ERROR',
      message: errorObject['message']?.toString() ?? 'An error occurred',
      details: detailsList,
      requestId: errorObject['requestId']?.toString(),
      timestamp: errorObject['timestamp']?.toString(),
    );
  }
}
