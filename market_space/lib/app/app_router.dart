import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/routing/route_guards.dart';
import '../core/routing/route_names.dart';
import '../core/theme/app_spacing.dart';
import '../shared/widgets/app_error_view.dart';
import 'app_dependencies.dart';
import 'app_localization.dart';

class AppRouter {
  static GoRouter createRouter({
    RouteGuard? routeGuard,
    String initialLocation = RouteNames.root,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      redirect: (context, state) async {
        if (routeGuard != null) {
          return await routeGuard.evaluateRedirect(context, state.uri.path);
        }
        return null;
      },
      errorBuilder: (context, state) {
        final strings = AppLocalization.of(context);
        return Scaffold(
          body: AppErrorView(
            title: strings.pageNotFound,
            message: state.uri.path,
            retryButtonLabel: strings.backToHome,
            onRetry: () => context.go(RouteNames.root),
          ),
        );
      },
      routes: [
        GoRoute(
          path: RouteNames.root,
          name: RouteNames.rootName,
          builder: (context, state) {
            return const FoundationRootPlaceholder();
          },
        ),
      ],
    );
  }
}

class FoundationRootPlaceholder extends StatelessWidget {
  const FoundationRootPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependencies.of(context);
    final strings = AppLocalization.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: 'Language',
            onPressed: () => dependencies.localeController.toggleLocale(),
          ),
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Theme',
            onPressed: () => dependencies.themeController.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 64.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                strings.appTitle,
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Environment: ${dependencies.appConfig.environment.identifierName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
