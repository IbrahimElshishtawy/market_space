import 'package:flutter/widgets.dart';
import '../security/token_provider.dart';

abstract class RouteGuard {
  Future<String?> evaluateRedirect(BuildContext context, String currentRoute);
}

class SessionRouteGuard implements RouteGuard {
  final TokenProvider tokenProvider;

  SessionRouteGuard({
    required this.tokenProvider,
  });

  @override
  Future<String?> evaluateRedirect(BuildContext context, String currentRoute) async {
    return null;
  }
}
