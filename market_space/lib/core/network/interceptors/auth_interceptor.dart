import 'package:dio/dio.dart';
import '../../security/token_provider.dart';
import '../api_headers.dart';

class AuthInterceptor extends Interceptor {
  final TokenProvider tokenProvider;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.tokenProvider,
    this.onSessionExpired,
  });

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuthorization = !options.headers.containsKey(ApiHeaders.authorization);
    if (requiresAuthorization) {
      final accessToken = await tokenProvider.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[ApiHeaders.authorization] = '${ApiHeaders.bearerPrefix}$accessToken';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
