import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryDelay = const Duration(milliseconds: 1000),
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final isIdempotentMethod = requestOptions.method.toUpperCase() == 'GET' ||
        requestOptions.method.toUpperCase() == 'HEAD';

    final isTransientError = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;

    final currentRetryCount = requestOptions.extra['retry_count'] as int? ?? 0;

    if (isIdempotentMethod && isTransientError && currentRetryCount < maxRetries) {
      requestOptions.extra['retry_count'] = currentRetryCount + 1;
      await Future.delayed(retryDelay * (currentRetryCount + 1));

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } on DioException catch (retryError) {
        return handler.next(retryError);
      }
    }

    return handler.next(err);
  }
}
