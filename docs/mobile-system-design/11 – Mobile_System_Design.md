# 11 – Deal One Mobile System Design: Consolidated Master Specification

## 1. Document Purpose & Master Index

This document serves as the **Consolidated Master System Design Specification** for the **Deal One Mobile MVP** (Flutter package: `market_space`). It synthesizes the reverse-engineered architectural records into an authoritative, evidence-backed technical manual.

### Master Documentation Index

| Part | Document Title | Primary Focus |
|---|---|---|
| **01** | [01 – Mobile System Overview](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/01%20–%20Mobile_System_Overview.md) | High-level system architecture, technology stack, and execution summary |
| **02** | [02 – Flutter Project Structure](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/02%20–%20Flutter_Project_Structure.md) | Directory hierarchy, layer responsibilities, and file locations |
| **03** | [03 – Application Modules](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/03%20–%20Application_Modules.md) | Detailed breakdown of all 13 feature modules and the 6 core business verticals |
| **04** | [04 – Navigation and User Flows](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/04%20–%20Navigation_and_User_Flows.md) | GoRouter routes, tab shell, deep links, and Mermaid user journeys |
| **05** | [05 – State Management and Data Flow](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/05%20–%20State_Management_and_Data_Flow.md) | ValueNotifier architecture, lifecycle, and end-to-end data sequence diagrams |
| **06** | [06 – API Integration Design](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/06%20–%20API_Integration_Design.md) | DioApiClient, interceptor pipeline, error mapping, and API inventory table |
| **07** | [07 – Local Data and Caching](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/07%20–%20Local_Data_and_Caching.md) | SharedPreferences, FlutterSecureStorage, and memory image cache analysis |
| **08** | [08 – UI/UX Design System](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/08%20–%20UI_UX_Design_System.md) | Monochrome palette, WCAG 2.2 AA semantic states, typography, and widgets |
| **09** | [09 – Authentication and Security](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/09%20–%20Authentication_and_Security.md) | Auth matrix, token encryption, session persistence, and OS permissions |
| **10** | [10 – Mobile Architecture Audit](file:///home/ibrahim-elshishtawy/flutter%20project/market_space/docs/mobile-system-design/10%20–%20Mobile_Architecture_Audit.md) | Critical defects, test failure analysis, technical debt, and recommendations |

---

## 2. System Architecture Synthesis

```mermaid
graph TD
    subgraph Client_Bootstrap [Application Bootstrap - lib/bootstrap]
        Main[main.dart] --> Boot[bootstrap.dart]
        Boot --> Obs[BootstrapObserver<br/>Global Error Traps & Lifecycle]
        Boot --> InitDeps[initializeDependencies]
    end

    subgraph Ambient_Container [Ambient Service Locator - lib/app]
        InitDeps --> AppDeps[AppDependencies]
        AppDeps --> Scope[AppDependenciesScope<br/>InheritedWidget]
        Scope --> RootApp[MarketSpaceApp<br/>MaterialApp.router]
    end

    subgraph Presentation_Layer [Presentation Layer - lib/features]
        RootApp --> Router[AppRouter: GoRouter]
        Router --> Shell[GlobalNavigationScaffold<br/>IndexedStack: 5 Persistent Tabs]
        
        Shell --> Tab0[Tab 0: HomePage]
        Shell --> Tab1[Tab 1: ExplorePage]
        Shell --> Tab2[Tab 2: MyActivityPage]
        Shell --> Tab3[Tab 3: GlobalFavoritesPage]
        Shell --> Tab4[Tab 4: ProfilePage]

        Tab0 --> Verticals[6 Core Business Verticals]
        Verticals --> V1[Real Estate: /real-estate]
        Verticals --> V2[Building Materials: /building-materials]
        Verticals --> V3[Home Services: /home-services]
        Verticals --> V4[Home Appliances: /home-appliances]
        Verticals --> V5[Cars: /cars]
        Verticals --> V6[Fashion: /fashion]
    end

    subgraph Reactive_State [State Management Layer - lib/features/*/controllers]
        V1 & V2 & V3 & V4 & V5 & V6 --> Notifiers[ValueNotifier Controllers<br/>RealEstate, Cars, Fashion, Materials, Services]
        Tab0 & Tab4 --> CoreNotifiers[SectorController | ThemeController | LocaleController]
    end

    subgraph Data_Layer [Data & Persistence Layer]
        Notifiers --> Repos[Repository Contract Interfaces]
        Repos -.->|Active Runtime| MockData[In-Memory Mock Repositories<br/>MockRealEstateData, MockCarsData, etc.]
        
        CoreNotifiers --> Prefs[PreferencesService<br/>SharedPreferences: Theme, Locale, Sector]
        AppDeps --> SecStore[SecureStorageService<br/>FlutterSecureStorage: Keystore / Keychain]
        
        Repos -.->|Designed but Unwired| NetClient[DioApiClient<br/>lib/core/network]
        NetClient --> NetInterceptors[Interceptor Pipeline<br/>RequestId, Auth, Retry, Logging]
    end
```

---

## 3. Technology Stack Inventory

| Component / Layer | Selected Technology | Version in Lockfile | Implementation Reality |
|---|---|---|---|
| **Core Framework** | Flutter SDK (Material 3) | `>=3.47.0` | Root widget tree, theme, animations |
| **Language** | Dart SDK | `>=3.13.3 <4.0.0` | Null-safe Dart with pattern matching |
| **Declarative Router** | `go_router` | `18.0.2` | Route hierarchy, sub-routes, error views |
| **HTTP Client** | `dio` | `5.11.1` | Complete interceptor pipeline; unwired to repositories |
| **Plaintext Storage** | `shared_preferences` | `2.5.6` | Theme, locale, and active sector persistence |
| **Encrypted Storage** | `flutter_secure_storage` | `11.2.0` | Android Keystore / iOS Keychain token storage |
| **Network Monitor** | `connectivity_plus` | `7.3.2` | Connectivity checks before HTTP requests |
| **Formatting / i18n** | `intl` + `flutter_localizations` | `0.20.3` | Arabic (RTL) default, English fallback |
| **Interactive Maps** | `flutter_map` + `latlong2` | `7.0.2` / `0.9.1` | OpenStreetMap tile viewer in Real Estate |

---

## 4. Architectural Strengths

1. **Clean Separation of Features**: The feature-first folder structure cleanly isolates business logic into 13 distinct directories, preventing cross-module spaghetti code.
2. **Lightweight Reactive State Management**: By utilizing native `ValueNotifier` and `ValueListenableBuilder` instead of heavyweight third-party libraries, the app achieves optimal render performance with minimal memory overhead.
3. **Robust Theme & Accessibility Tokens**: The design system strictly follows WCAG 2.2 AA contrast guidelines, providing seamless, flicker-free switching between light and dark monochrome themes.
4. **Pre-engineered Network Infrastructure**: The `DioApiClient` includes production-grade interceptors (exponential backoff retry, request tracing IDs, auth token headers, error mapping), ready to connect to real endpoints with zero architectural rewriting.
5. **Comprehensive UI Feature Coverage**: All six primary commercial sectors possess fully implemented, responsive screens, carousels, specification tables, and interactive calculators.

---

## 5. Critical Technical Debt & Architectural Weaknesses

1. **The Network / Repository Disconnect**: 100% of feature repositories query static Dart mock datasets. No feature makes live HTTP calls.
2. **Missing Android `INTERNET` Permission**: `AndroidManifest.xml` lacks the internet permission in main, blocking release builds from network access.
3. **Broken Automated Test Suite**: 6 unit/widget tests are failing due to out-of-sync navigation configs and mutable mock datasets.
4. **Absence of Authentication UI**: No login, registration, or OTP verification screens exist; the app operates in persistent guest mode.
5. **No Persistent Disk Image Caching**: Images are cached only in volatile RAM; cold app launches repeatedly re-download multi-megabyte photo galleries.
6. **Dead Prototype Code**: Legacy files (`market_home_screen.dart`, `market_repository.dart`) contain obsolete UAE currency codes (`AED`) and deprecated styling.

---

## 6. Gap Analysis: Current Prototype vs Scalable Production Architecture

```
Current Deal One Prototype                         Scalable Production Target
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ Feature Repositories            │               │ Feature Remote Repositories     │
│ (Mock datasets in RAM)          │  ──Refactor─► │ (Injected with DioApiClient)    │
└─────────────────────────────────┘               └─────────────────────────────────┘
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ Public Guest-Only Navigation    │               │ Protected Route Navigation      │
│ (SessionRouteGuard: null)       │  ──Activate─► │ (Enforced by TokenProvider)     │
└─────────────────────────────────┘               └─────────────────────────────────┘
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ Missing Auth & Ad Post Screens  │               │ Full Auth & Multi-Step Wizards  │
│ (No login or listing creation)  │  ──Implement─►│ (OTP auth + Category Ad Forms)  │
└─────────────────────────────────┘               └─────────────────────────────────┘
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ RAM-Only Image Loading          │               │ Persistent Disk Image Caching   │
│ (Image.network memory cache)    │  ──Upgrade──► │ (cached_network_image on disk)  │
└─────────────────────────────────┘               └─────────────────────────────────┘
┌─────────────────────────────────┐               ┌─────────────────────────────────┐
│ Missing Native Manifest Tags    │               │ Hardened OS Permissions         │
│ (No INTERNET, CAMERA, LOCATION) │  ──Configure─►│ (Android Manifest & Info.plist) │
└─────────────────────────────────┘               └─────────────────────────────────┘
```

---

## 7. Actionable Production Readiness Roadmap

### Phase 1: Immediate Mandatory Fixes (Hotfixes)
- [ ] **Fix 1.1**: Add `<uses-permission android:name="android.permission.INTERNET"/>` to `android/app/src/main/AndroidManifest.xml`.
- [ ] **Fix 1.2**: Update test expectations in `test/core/navigation/app_bottom_navigation_test.dart`, `real_estate_page_test.dart`, and `real_estate_detail_page_test.dart` to restore a 100% green test suite.
- [ ] **Fix 1.3**: Wire the logout button in `ProfilePage` to `await tokenProvider.clearTokens()` and update `SessionState`.

### Phase 2: Security & Permissions Configuration
- [ ] **Fix 2.1**: Add camera, photo library, and location permissions to `AndroidManifest.xml` and `ios/Runner/Info.plist`.
- [ ] **Fix 2.2**: Implement `/login`, `/register`, and `/otp-verify` screens.
- [ ] **Fix 2.3**: Activate `SessionRouteGuard` to protect checkout, activity, and profile management routes.

### Phase 3: Data Layer Wiring & Performance Optimization
- [ ] **Fix 3.1**: Create `Remote` implementations for all 13 repositories, wiring them to `DioApiClient` and backend REST endpoints.
- [ ] **Fix 3.2**: Add `cached_network_image` to `pubspec.yaml` and integrate it into `AppNetworkImage` for persistent disk caching.
- [ ] **Fix 3.3**: Delete dead legacy prototype files (`market_home_screen.dart`, `market_repository.dart`).
- [ ] **Fix 3.4**: Implement unified classified ad creation and editing wizards for cars, real estate, and merchandise.

