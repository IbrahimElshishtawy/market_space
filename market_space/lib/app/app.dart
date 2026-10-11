import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme_data.dart';
import 'app_dependencies.dart';
import 'app_localization.dart';
import 'app_router.dart';

class MarketSpaceApp extends StatefulWidget {
  final AppDependencies dependencies;
  final GoRouter? customRouter;

  const MarketSpaceApp({
    super.key,
    required this.dependencies,
    this.customRouter,
  });

  @override
  State<MarketSpaceApp> createState() => _MarketSpaceAppState();
}

class _MarketSpaceAppState extends State<MarketSpaceApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = widget.customRouter ?? AppRouter.createRouter();
  }

  @override
  Widget build(BuildContext context) {
    return AppDependenciesScope(
      dependencies: widget.dependencies,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          widget.dependencies.localeController,
          widget.dependencies.themeController,
        ]),
        builder: (context, _) {
          final currentLocale = widget.dependencies.localeController.value;
          final currentThemeMode = widget.dependencies.themeController.value;

          return MaterialApp.router(
            title: 'Market Space',
            debugShowCheckedModeBanner: false,
            routerConfig: _router,
            locale: currentLocale,
            themeMode: currentThemeMode,
            theme: AppThemeData.lightTheme,
            darkTheme: AppThemeData.darkTheme,
            localizationsDelegates: AppLocalization.localizationsDelegates,
            supportedLocales: AppLocalization.supportedLocales,
          );
        },
      ),
    );
  }
}
