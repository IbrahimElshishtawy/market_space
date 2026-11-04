# 02 – Flutter Project Structure & Component Responsibilities

## 1. Directory Tree Overview

The Deal One mobile codebase (`market_space`) is organized using a **Hybrid Feature-First with Layered MVVM** structure. The repository isolates core infrastructure, shared UI widgets, and thirteen business features into clear boundaries:

```
market_space/
├── android/                           # Native Android project configuration
│   └── app/src/main/AndroidManifest.xml
├── ios/                               # Native iOS project configuration
│   └── Runner/Info.plist
├── assets/                            # Static media and mock assets
│   └── mock_data/                     # Raw JSON mock responses
├── lib/
│   ├── app/                           # Root application setup & DI container
│   ├── bootstrap/                     # Bootstrap entry, environment observer
│   ├── core/                          # Cross-cutting infrastructure & design system
│   │   ├── config/                    # Environment & configuration models
│   │   ├── constants/                 # Core system constants
│   │   ├── errors/                    # Exceptions, failures & error mapping
│   │   ├── localization/              # Locale controller & language management
│   │   ├── logging/                   # Logger implementation & sanitization
│   │   ├── mock_data/                 # Mock configuration & data provider
│   │   ├── navigation/                # Dynamic section navigation configuration
│   │   ├── network/                   # DioApiClient & interceptors pipeline
│   │   ├── notifications/             # Core notification models & repositories
│   │   ├── platform/                  # Device & OS platform detection
│   │   ├── routing/                   # Route names & route guard placeholders
│   │   ├── security/                  # Session states & token providers
│   │   ├── storage/                   # SharedPreferences & FlutterSecureStorage
│   │   ├── theme/                     # Colors, typography, spacing, radii, theme data
│   │   └── utils/                     # Formatting, input normalization, responsiveness
│   ├── features/                      # Thirteen (13) business feature modules
│   │   ├── activity/                  # Unified orders, bookings & inquiries timeline
│   │   ├── building_materials/        # Heavy materials, RFQs, shipping & staged delivery
│   │   ├── cars/                      # Automotive listings, brand filters & specs
│   │   ├── explore/                   # Cross-sector unified search engine
│   │   ├── fashion/                   # Apparel, departments, variants & cart
│   │   ├── favorites/                 # Cross-sector bookmark aggregator
│   │   ├── home/                      # Multi-sector discovery hub & dynamic carousels
│   │   ├── home_appliances/           # Electronics & decoration e-commerce
│   │   ├── home_services/             # Maintenance services, booking wizard & tracking
│   │   ├── navigation/                # Global scaffold with IndexedStack & bottom nav
│   │   ├── notifications/             # Sector-segmented alert feeds
│   │   ├── profile/                   # User profile, addresses, settings & preferences
│   │   └── real_estate/               # Property classifieds, map & multimedia reels
│   ├── l10n/                          # ARB translation sources & generated delegates
│   ├── shared/                        # Shared UI components, models, and legacy bridges
│   └── main.dart                      # Application binary entrypoint
├── test/                              # Automated test suites (38 test files)
│   ├── core/                          # Infrastructure & navigation tests
│   ├── features/                      # Feature controller and widget tests
│   └── unit/                          # Utility & configuration validator tests
├── analysis_options.yaml              # Static analysis and lint rules
├── devtools_options.yaml              # DevTools configuration
├── l10n.yaml                          # Flutter localization tool config
└── pubspec.yaml                       # Package manifest & asset declarations
```

---

## 2. Directory Responsibilities and Key File Breakdown

### 2.1 `lib/main.dart` & `lib/bootstrap/`
- **Responsibility**: Application startup, environment parameter injection, global uncaught error trapping, and asynchronous dependency initialization.
- **Key Files**:
  - [lib/main.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/main.dart): The root entrypoint. Invokes `bootstrap(AppConfig.development())`.
  - [lib/bootstrap/bootstrap.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/bootstrap/bootstrap.dart): Calls `WidgetsFlutterBinding.ensureInitialized()`, triggers `initializeDependencies(config)`, sets up fallback UI on fatal initialization crashes, and mounts `runApp(MarketSpaceApp(dependencies: dependencies))`.
  - [lib/bootstrap/bootstrap_observer.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/bootstrap/bootstrap_observer.dart): Binds to `WidgetsBindingObserver`, capturing Flutter lifecycle transitions (`resumed`, `inactive`, `paused`, `detached`) and installs `PlatformDispatcher.instance.onError` and `FlutterError.onError` global traps.

### 2.2 `lib/app/`
- **Responsibility**: Root application assembly, ambient dependency propagation via Flutter's element tree, theme control, and declarative router binding.
- **Key Files**:
  - [lib/app/app.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app.dart): Defines `MarketSpaceApp`, building `MaterialApp.router` with dynamic theme and locale observers.
  - [lib/app/app_dependencies.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_dependencies.dart): Houses the `AppDependencies` container class and the `AppDependenciesScope` (`InheritedWidget`). Exposes `AppDependencies.of(context)` for ambient lookup.
  - [lib/app/app_router.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_router.dart): Configures `GoRouter` with all declarative routes, parameter parsing, error builders (`AppErrorView`), and route guard integration.
  - [lib/app/app_theme.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_theme.dart): Houses `ThemeController` (`ValueNotifier<ThemeMode>`) which loads and persists `ThemeMode.light`, `ThemeMode.dark`, or `ThemeMode.system`.
  - [lib/app/app_localization.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_localization.dart): Convenience accessor for `AppLocalizations.of(context)`.

---

### 2.3 `lib/core/` (Cross-Cutting Infrastructure)

| Subdirectory | Core Responsibility | Key Implementation Files |
|---|---|---|
| `config/` | Environment flavors, timeouts, base URLs, and runtime validation | `app_config.dart`, `environment.dart`, `config_validator.dart` |
| `constants/` | System-wide static constants | `app_constants.dart` |
| `errors/` | Exceptions, failure representations, and error mapping | `app_exception.dart`, `app_failure.dart`, `error_mapper.dart` |
| `localization/` | Language switching, locale controller, and supported locales | `locale_controller.dart`, `supported_locales.dart` |
| `logging/` | Logger abstraction and PII/sensitive data redaction | `app_logger.dart`, `log_sanitizer.dart` |
| `mock_data/` | Global mock data provider and toggle flags | `mock_data_provider.dart`, `mock_data_config.dart` |
| `navigation/` | Dynamic bottom navigation bar configurations per sector | `section_navigation_registry.dart`, `section_navigation_config.dart`, `navigation_item_config.dart` |
| `network/` | Dio HTTP client wrapper, headers, and interceptor pipeline | `api_client.dart`, `api_endpoints.dart`, `api_headers.dart`, `network_info.dart`, `interceptors/` |
| `notifications/` | Core notification models and in-memory repository | `app_notification.dart`, `notification_repository.dart`, `notification_controller.dart` |
| `platform/` | Native platform capabilities and OS identification | `platform_info.dart` |
| `routing/` | Route constants and session guard interfaces | `route_names.dart`, `route_guards.dart` |
| `security/` | Token management abstractions and session states | `token_provider.dart`, `secure_token_provider.dart`, `session_state.dart` |
| `storage/` | Key-value and encrypted keychain storage wrappers | `preferences_service.dart`, `secure_storage_service.dart`, `storage_keys.dart` |
| `theme/` | High-contrast monochrome design tokens and theme data | `app_colors.dart`, `app_radii.dart`, `app_spacing.dart`, `app_text_styles.dart`, `app_theme_data.dart`, `theme_context_extensions.dart` |
| `utils/` | Formatting utilities, input sanitization, and responsive helpers | `date_time_utils.dart`, `input_normalizers.dart`, `responsive_utils.dart` |

---

### 2.4 `lib/features/` (Business Modules Breakdown)

Each feature adheres to a structured separation:
- `data/`: Mock datasets, serialization models, and repository implementations.
- `presentation/`: UI screens (`pages/`), UI sub-components (`widgets/`), and controllers (`controllers/`).
- `domain/`: (Present in select modules like `home_services`) Entity models and abstract repository contracts.

```
lib/features/
├── activity/
│   ├── data/ (models/unified_activity_model.dart, repositories/unified_activity_repository.dart)
│   └── presentation/ (controllers/unified_activity_controller.dart, pages/my_activity_page.dart)
├── building_materials/
│   ├── data/ (mock/, models/, repositories/)
│   └── presentation/ (controllers/, pages/, services/shipping_calculator.dart, unit_converter.dart)
├── cars/
│   ├── data/ (mock/mock_cars_data.dart, models/, repositories/cars_repository.dart)
│   └── presentation/ (controllers/cars_controller.dart, pages/, widgets/)
├── explore/
│   ├── data/ (repositories/explore_repository.dart)
│   └── presentation/ (controllers/explore_controller.dart, pages/explore_page.dart, widgets/)
├── fashion/
│   ├── data/ (mock/mock_fashion_data.dart, models/, repositories/fashion_repository.dart)
│   └── presentation/ (controllers/fashion_controller.dart, fashion_cart_controller.dart, pages/, widgets/)
├── favorites/
│   ├── data/ (models/, repositories/unified_favorites_repository.dart)
│   └── presentation/ (controllers/unified_favorites_controller.dart, pages/global_favorites_page.dart)
├── home/
│   ├── data/ (mock/mock_home_data.dart, models/)
│   └── presentation/ (pages/home_page.dart, widgets/hero_carousel/, home_header/, home_nav_bar/, main_categories/)
├── home_appliances/
│   ├── cart/ (data/, presentation/pages/home_appliances_cart_page.dart)
│   ├── categories/ (presentation/pages/home_appliances_categories_page.dart)
│   ├── checkout/ (presentation/pages/home_appliances_checkout_page.dart)
│   ├── notifications/ (data/, presentation/pages/home_appliances_notifications_page.dart)
│   ├── orders/ (data/, presentation/pages/home_appliances_orders_page.dart)
│   └── presentation/ (pages/home_appliances_page.dart, appliance_category_listing_page.dart)
├── home_services/
│   ├── data/ (mock/, models/, repositories/)
│   └── presentation/ (controllers/, pages/booking_wizard/, technician_tracking_page.dart)
├── navigation/
│   └── presentation/ (pages/global_navigation_scaffold.dart)
├── notifications/
│   └── presentation/ (pages/global_notifications_page.dart)
├── profile/
│   ├── data/ (models/user_profile_model.dart, repositories/profile_repository.dart)
│   └── presentation/ (controllers/profile_controller.dart, pages/profile_page.dart)
└── real_estate/
    ├── data/ (mock/mock_real_estate_data.dart, models/, repositories/real_estate_repository.dart)
    ├── favorites/ (presentation/pages/real_estate_favorites_page.dart)
    ├── map/ (presentation/pages/real_estate_map_page.dart)
    ├── notifications/ (presentation/pages/real_estate_notifications_page.dart)
    ├── reels/ (data/, presentation/pages/reels_page.dart, reel_publish_page.dart, reel_analytics_page.dart)
    └── presentation/ (controllers/real_estate_controller.dart, pages/, widgets/)
```

---

### 2.5 `lib/shared/` (Cross-Feature Shared Assets)
- **Responsibility**: Holds shared UI components, shared sector state controllers, and backward-compatibility prototype widgets.
- **Key Files**:
  - [lib/shared/models/market_sector.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/models/market_sector.dart): The core `MarketSector` enum (`all`, `realEstate`, `buildingMaterials`, `services`, `homeAppliances`, `cars`, `fashion`, `investments`).
  - [lib/shared/state/sector_controller.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/state/sector_controller.dart): Manages the currently selected market sector and persists it via `PreferencesService`.
  - [lib/shared/widgets/](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/): Reusable UI primitives: `AppLoadingIndicator`, `AppEmptyState`, `AppErrorView`, `SafeNetworkImage`, `MaterialProductCard`, `RealEstateCard`, `ServiceProviderCard`, `TrustGuaranteeCard`, `ContractorPromoBanner`.
  - [lib/shared/widgets/market_home_screen.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/widgets/market_home_screen.dart): Unrouted legacy prototype screen (contains deprecated UAE currency formatting and older color styling).

---

### 2.6 Assets, Native Platforms & Tests

- **Assets (`assets/`)**:
  - Declared in `pubspec.yaml`: `- assets/mock_data/`.
  - Contains JSON response fixtures.
- **Android (`android/`)**:
  - Standard Flutter Android embedding.
  - Manifest (`android/app/src/main/AndroidManifest.xml`) currently omits the `<uses-permission android:name="android.permission.INTERNET"/>` tag in main.
- **iOS (`ios/`)**:
  - Standard Xcode project. `Info.plist` lacks camera, location, and photo library usage descriptions.
- **Tests (`test/`)**:
  - Contains 38 automated test files covering unit normalizers, config validation, repository logic, and widget trees across all 13 features.
