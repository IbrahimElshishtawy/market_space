# 01 – Mobile System Overview: Deal One MVP

## 1. Executive Summary & Application Purpose

The **Deal One Mobile MVP** (internal Flutter application identifier: `market_space`) is a multi-sector commercial classifieds and e-commerce mobile application targeting the Egyptian marketplace. Built with the Flutter framework on Dart SDK `>=3.13.3 <4.0.0`, the platform aggregates six major economic sectors into a single mobile interface:

1. **Real Estate** (`/real-estate`) – Residential & commercial property listings, interactive map browsing, broker contacts, and short-form video reels.
2. **Building Materials & Electrical Supplies** (`/building-materials`) – Heavy construction materials (steel rebar, cement, bricks), daily factory price ticker, RFQ (Request For Quotation) creation, freight shipping calculation, staged deliveries, and wholesale ordering.
3. **Home & Engineering Services** (`/home-services`) – On-demand technical and maintenance services (AC maintenance, plumbing, electrical, carpentry), multi-step booking wizard, and live technician dispatch tracking.
4. **Home Appliances & Decoration** (`/home-appliances`) – Consumer electronics and home furnishings catalog, specification filtering, cart, and checkout flow.
5. **Cars & Automotive** (`/cars`) – Automotive marketplace with multi-parameter filtering (brand, model, price, year, mileage, transmission, governorate), vehicle specifications, and seller contacts.
6. **Clothes & Fashion Accessories** (`/fashion`) – Multi-department apparel shopping (Men, Women, Kids), size/color variant selection, cart, and order placement.

The current implementation represents a **fully navigable, UI-complete functional prototype with in-memory mock data**. While all screens, controllers, models, and mock repositories are implemented and interactive, the underlying network layer is currently decoupled from live backend servers.

---

## 2. Architectural Style Analysis

The codebase follows a **Hybrid Feature-First with Layered MVVM** (Model-View-ViewModel / Model-View-Controller) architecture.

| Architectural Dimension | Identified Implementation | Evidence / Primary Source Files |
|---|---|---|
| **Primary Architectural Pattern** | Hybrid Feature-First Layered MVVM | [market_space/lib/features/](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/) containing isolated domain modules with `presentation/`, `data/`, and in some cases `domain/` sub-layers |
| **Dependency Injection / Ambient Scope** | Custom `InheritedWidget` (`AppDependenciesScope`) | [lib/app/app_dependencies.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_dependencies.dart#L10-L160) |
| **State Management** | Native `ValueNotifier<T>` + `ListenableBuilder` / `ValueListenableBuilder` (with select `ChangeNotifier` controllers) | [real_estate_controller.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/real_estate/presentation/controllers/real_estate_controller.dart), [home_page.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/home/presentation/pages/home_page.dart), [sector_controller.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/shared/state/sector_controller.dart) |
| **Routing & Navigation** | Declarative routing with `GoRouter` + persistent `IndexedStack` global shell | [app_router.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_router.dart), [global_navigation_scaffold.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/features/navigation/presentation/pages/global_navigation_scaffold.dart) |
| **HTTP Networking Engine** | Scaffolding using `dio` v5.11.1 (`DioApiClient`) with custom interceptors | [api_client.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/network/api_client.dart#L25) |
| **Local Persistence** | `shared_preferences` (v2.5.6) & `flutter_secure_storage` (v11.2.0) | [preferences_service.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/storage/preferences_service.dart), [secure_storage_service.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/storage/secure_storage_service.dart) |
| **Internationalization (i18n)** | Official `flutter_localizations` + `intl` (Arabic default `ar_EG`, English fallback `en_US`) | [l10n.yaml](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/l10n.yaml), [app_ar.arb](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/l10n/app_ar.arb) |
| **Design System** | High-contrast Monochrome system with WCAG 2.2 AA semantic states | [app_colors.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_colors.dart), [app_theme_data.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/theme/app_theme_data.dart) |

### Key Architectural Characteristics

1. **Feature Encapsulation**: Each business sector resides in its own isolated folder under `lib/features/<feature_name>/`. Features own their data contracts, mock datasets, models, presentation pages, and specialized controllers.
2. **Ambient Dependency Propagation**: Rather than introducing external DI frameworks (e.g., `get_it`, `injectable`), the application initializes an immutable `AppDependencies` container in `lib/bootstrap/bootstrap.dart` and injects it above `MaterialApp.router` using `AppDependenciesScope` (an `InheritedWidget`).
3. **Dynamic Section Navigation Registry**: The platform uses `SectionNavigationRegistry` ([section_navigation_registry.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/core/navigation/config/section_navigation_registry.dart)) allowing different verticals to customize bottom bars, search filters, and floating actions while maintaining a unified global scaffold.
4. **Decoupled Data Layer**: The HTTP networking client (`DioApiClient`) is fully implemented with error mapping, retry interceptors, request tracing, and authentication token injection, but **feature repositories currently bypass it**, reading directly from mock datasets.

---

## 3. Technology Stack Inventory

The technology inventory is verified strictly from [market_space/pubspec.yaml](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/pubspec.yaml) and [market_space/pubspec.lock](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/pubspec.lock):

### 3.1 Runtime Dependencies

| Package | Declared Version | Resolved Version | Functional Purpose | Usage Status |
|---|---|---|---|---|
| `flutter` | SDK | `>=3.47.0` | Core framework runtime | **IMPLEMENTED** |
| `flutter_localizations` | SDK | `flutter` | Multi-language localization support | **IMPLEMENTED** |
| `cupertino_icons` | `^1.0.8` | `1.0.8` | iOS Cupertino icon set | **IMPLEMENTED** |
| `dio` | `^5.11.1` | `5.11.1` | HTTP client wrapper (`DioApiClient`) | **PARTIALLY IMPLEMENTED** (Core coded, unwired to repositories) |
| `go_router` | `^18.0.2` | `18.0.2` | Declarative routing and deep linking | **IMPLEMENTED** |
| `shared_preferences` | `^2.5.6` | `2.5.6` | Key-value persistent storage | **IMPLEMENTED** |
| `flutter_secure_storage` | `^11.2.0` | `11.2.0` | Encrypted keychain/keystore token storage | **IMPLEMENTED** |
| `connectivity_plus` | `^7.3.2` | `7.3.2` | Real-time network interface monitor | **IMPLEMENTED** |
| `intl` | `^0.20.3` | `0.20.3` | Date, number, and string formatting | **IMPLEMENTED** |
| `flutter_map` | `^7.0.2` | `7.0.2` | OpenStreetMap interactive map renderer | **IMPLEMENTED** |
| `latlong2` | `^0.9.1` | `0.9.1` | Geographic coordinates calculations | **IMPLEMENTED** |

### 3.2 Development Dependencies

| Package | Declared Version | Resolved Version | Functional Purpose |
|---|---|---|---|
| `flutter_test` | SDK | `flutter` | Unit and widget test runner |
| `flutter_lints` | `^6.0.0` | `6.0.0` | Official static analysis lint rules |

### 3.3 Critical Package Absences (Verified Absences)

The following packages are **NOT** installed or present in `pubspec.yaml`:
- **Firebase** (`firebase_core`, `firebase_auth`, `firebase_messaging`, `cloud_firestore`): **0% present**.
- **External DI** (`get_it`, `injectable`): Not used (custom `InheritedWidget` used instead).
- **External State Management** (`flutter_bloc`, `provider`, `riverpod`): Not used (native `ValueNotifier` used).
- **Persistent Image Caching** (`cached_network_image`): Not used (`Image.network` used).
- **Embedded Database** (`sqflite`, `hive`, `drift`, `isar`): Not installed.
- **Biometric Auth** (`local_auth`): Not installed.

---

## 4. High-Level System Architecture Diagram

```mermaid
graph TD
    subgraph UI_Layer [Presentation Layer - lib/features & lib/shared]
        A1[GlobalNavigationScaffold<br/>Persistent IndexedStack: 5 Tabs]
        A2[Home Hub Page<br/>Multi-Sector Selector]
        A3[Sector Modules<br/>Real Estate | Materials | Services | Appliances | Cars | Fashion]
        A4[Explore & Activity Pages<br/>Unified Search & Orders/Bookings]
        A5[Profile & Settings Page<br/>Account, Theme, Language]
    end

    subgraph State_Layer [State Management Layer]
        B1[SectorController<br/>ValueNotifier: Active Market Sector]
        B2[Feature Controllers<br/>RealEstate, Cars, Fashion, Materials, Services]
        B3[Core Controllers<br/>LocaleController, ThemeController, NotificationController]
    end

    subgraph Ambient_DI [Ambient Dependency Injection Scope - lib/app]
        C1[AppDependenciesScope<br/>InheritedWidget holding AppDependencies container]
    end

    subgraph Data_Layer [Data & Persistence Layer]
        D1[Repositories Contract Interfaces<br/>RealEstateRepository, CarsRepository, etc.]
        D2[In-Memory Mock Implementations<br/>MockRealEstateRepository, MockCarsRepository, etc.]
        D3[PreferencesService<br/>SharedPreferences: Theme, Locale, Selected Sector]
        D4[SecureStorageService<br/>FlutterSecureStorage: Access & Refresh Tokens]
    end

    subgraph Network_Core [Networking Core - lib/core/network - UNWIRED]
        E1[DioApiClient<br/>BaseOptions, Timeouts, ErrorMapper]
        E2[Interceptor Pipeline<br/>RequestId, Auth, Retry, Logging]
    end

    A1 --> A2 & A3 & A4 & A5
    A2 & A3 & A4 & A5 --> B1 & B2 & B3
    B1 & B2 & B3 --> C1
    C1 --> D1
    D1 -.->|Currently Connected| D2
    D2 --> D3 & D4
    C1 -.->|Instantiated but Uncalled| E1
    E1 --> E2
```

---

## 5. Cross-Cutting Design Patterns

### 5.1 Ambient Dependency Injection (InheritedWidget Pattern)
The application avoids third-party DI containers by implementing `AppDependenciesScope` ([lib/app/app_dependencies.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_dependencies.dart)). All services, controllers, and repositories are initialized asynchronously in `initializeDependencies()` ([lib/bootstrap/bootstrap.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/bootstrap/bootstrap.dart)) and placed at the root of the widget tree:
```dart
AppDependencies.of(context) // Throws StateError if scope is missing
AppDependencies.maybeOf(context) // Safe nullable lookup
```

### 5.2 Declarative Router Pattern (GoRouter)
The navigation tree is constructed declaratively in [lib/app/app_router.dart](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/market_space/lib/app/app_router.dart) with custom URL paths (`/real-estate`, `/building-materials`, `/cars`, etc.) and parameterized query routes (`/real-estate/detail?id=aqar-1`).

### 5.3 Reactive State Notifier Pattern (ValueNotifier / ListenableBuilder)
State classes are immutable models wrapped in `ValueNotifier<T>`. UI widgets consume states via `ValueListenableBuilder<T>` or `ListenableBuilder`, minimizing widget subtree re-renders without adding heavyweight external state libraries.

---

## 6. Current System Readiness & Reality Check

- **Presentation Layer**: **90% Complete** – 13 feature modules fully designed with responsive UI, Arabic typography, dark/light theme support, and interactive widgets.
- **Navigation Flow**: **85% Complete** – Full tab switching, deep sub-route navigation, back-stack handling, and interactive dialogs. Missing: authentication screens and general ad creation/editing forms.
- **State Management**: **80% Complete** – Controllers handle loading, filtering, searching, and cart state in memory.
- **Data Persistence**: **40% Complete** – `SharedPreferences` persists theme, locale, and selected sector. `FlutterSecureStorage` persists token placeholders. In-memory repositories do not persist data to disk across app restarts.
- **Backend API Integration**: **10% Complete** – Networking client infrastructure is coded, but **0% of feature modules connect to remote APIs**.
- **Security & Auth**: **15% Complete** – Token storage and refresh interceptor are coded; login/OTP screens and route guard redirects are unactivated placeholders.

